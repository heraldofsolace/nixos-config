# Land runbook: manual fast-forward while `worktree::land` is broken

`worktree::land` cannot complete on this engine. **Do not call it.** Every land enqueues
`worktree::land-step` onto the `worktree-land` FIFO queue, the invocation fails at its first
`shell::exec` dispatch, retries 3x in place, is re-enqueued, fails again, then dead-letters; the
worktree record is left `W401`-poisoned. Until upstream fixes it (KAN-8), land by hand from the
primary checkout.

## 1. Detect the failure

Poll the queue's counters. One dead-letter per attempted land, and `delivered` never rises:

```text
engine::queue::topic_stats { "topic": "worktree-land" }
```

Healthy: `delivered` > 0. Broken (measured on this engine, 2026-10-10):

```json
{ "delivered": 0, "failed": 13, "dlq_depth": 12, "depth": 0, "consumer_count": 0 }
```

`delivered` has been 0 for the topic's entire lifetime, and `dlq_depth` is the live indicator of
how many lands have been lost. The queue worker logs one WARN per attempt, then the dead-letter:

```text
WARN iii_queue::runtime: FIFO function queue invocation failed; retrying in place
  queue=worktree-land function_id=worktree::land-step attempt=1 delay_ms=1000
  ... attempt=2 delay_ms=2000
  ... attempt=3 delay_ms=4000
```

Neither `worktree::landed` nor `worktree::land-blocked` ever fires, so a session waiting on a land
is never told it failed.

## 2. Land by hand

Three commands. Replace `<worktree>`, `<primary>` and `<branch>`.

```sh
git -C <worktree> rebase main      # only if the target moved
(cd <worktree> && just gate)       # the land gate, run in the worktree
git -C <primary> merge --ff-only <branch>
```

Worked example - the fast-forward that put this repo's `main` at `3813647` (KAN-7, branch
`feat/nix-topology-comin`):

```text
3813647 devshell: bump iii to 0.24.6-rc.3 to probe the engine/worker protocol skew
```

Constraints - each one is load-bearing:

- **Land from the primary checkout only.** `worktree::land` is the broken thing, so neither it nor
  `worktree::land-step` is in the path; the merge is a plain git command run in the primary.
- **One worktree per ticket, one owner.** Two sessions on one worktree contaminate each other's
  queue counters and edit files under each other (observed on KAN-10).
- **The gate needs a no-op `nix fmt` and a clean tree.** `just gate` is `nix fmt` followed by
  `test -z "$(git status --porcelain)"`, so the flake evaluates exactly what lands. Run `nix fmt`
  and commit *before* the gate.
- **Nobody edits the primary while a ticket is open.** The fast-forward refuses on a conflict, and
  uncommitted work there can be clobbered.

## 3. A bypass, not a repair

The manual path skips what the queue would have done:

- **The queue's own gate step never runs.** `land-step` is rebase -> gate -> merge; by hand we run
  the gate in the worktree and merge ourselves, so the queue emits nothing and clears nothing.

- **The worktree record stays poisoned.** The active-land flag is set when `worktree::land` is
  accepted and cleared only by a successful step, so after a dead-letter `worktree::remove` refuses:

  ```text
  W401: worktree wt_82138da6476a has an active land job "job_fe583481733f"
  ```

  `force` does not override `W401`.

- **The flag is not reachable from outside.** It lives in the worktree worker's private state
  namespace, so public `state::*` calls cannot read or clear `worktree_land_job` /
  `worktree_land_active`. Recovery needs a land step that succeeds, or a worker/engine restart; the
  affected worktrees stay on disk until then.

## 4. When upstream fixes this

Once a fix ships (the ask is on KAN-8):

1. Re-test with a **real** land on a clean scratch worktree. A bogus `job_id` returns `{done: true}`
   without exercising the dispatch and will fool you; arm `worktree::landed` and a `timer` backstop
   before calling `worktree::land`.
1. It is fixed when `engine::queue::topic_stats { "topic": "worktree-land" }` shows `delivered` > 0
   and a `worktree::landed` event fires.
1. Then delete this file, or mark it obsolete - the manual fast-forward is no longer the land path.

## 5. Pointers

- **KAN-8** - the reproduction, the refuted levers and the upstream ask (parked `blocked-upstream`).
- **KAN-9** - the `ide` pin, refuted in both directions (0.12.29 and 0.12.22).
- **KAN-10** - `worktree`/`ide` release pairs; both resolver-consistent pairs refuted.
- Live indicator: `engine::queue::topic_stats { "topic": "worktree-land" }` - `dlq_depth` counts the
  lands that have been lost.
