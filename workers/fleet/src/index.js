// workers/fleet — the local fleet: hosts, system generation, the land gate, worker health.
// Plain ESM, no build step: the UI assets are read from disk on every request so an edit
// only needs a page reload.
import { readFile } from 'node:fs/promises'
import { registerWorker } from 'iii-sdk'

const WORKER = 'fleet'
const NAMESPACE = 'default'
const REPO = process.env.FLEET_REPO ?? process.env.III_COMPOSE_DIR ?? '/home/aniket/my-nix'
const TAIL_CHARS = 4000

const iii = registerWorker(process.env.III_ENGINE_URL ?? process.env.III_URL, {
  workerName: WORKER,
  workerDescription: 'The local fleet: hosts, system generation, the land gate and worker health.',
  invocationTimeoutMs: 30000,
})

const call = (function_id, payload, timeoutMs = 25000) =>
  iii.trigger({ function_id, namespace: NAMESPACE, payload, timeoutMs })

// Everything the page needs comes out of one shell probe plus one engine call.
const STATUS_SCRIPT = String.raw`
set -u
REPO=${JSON.stringify(REPO)}
printf 'hostname=%s\n' "$(hostname 2>/dev/null || echo unknown)"
printf 'kernel=%s\n' "$(uname -r 2>/dev/null || echo unknown)"
printf 'uptime_s=%s\n' "$(cut -d. -f1 /proc/uptime 2>/dev/null || echo 0)"
printf 'generation=%s\n' "$(readlink /nix/var/nix/profiles/system 2>/dev/null | sed -n 's|^system-\([0-9][0-9]*\)-link$|\1|p')"
printf 'generations=%s\n' "$(ls -1 /nix/var/nix/profiles 2>/dev/null | grep -c '^system-[0-9][0-9]*-link$')"
printf 'running=%s\n' "$(readlink -f /run/current-system 2>/dev/null)"
printf 'profile=%s\n' "$(readlink -f /nix/var/nix/profiles/system 2>/dev/null)"
printf 'head=%s\n' "$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo none)"
printf 'branch=%s\n' "$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo none)"
printf 'dirty=%s\n' "$(if [ -n "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]; then echo yes; else echo no; fi)"
printf 'hosts=%s\n' "$(ls -1 "$REPO/modules/hosts" 2>/dev/null | tr '\n' ',' )"
`

function parseKeyValues(text) {
  const out = {}
  for (const line of String(text ?? '').split('\n')) {
    const at = line.indexOf('=')
    if (at > 0) out[line.slice(0, at)] = line.slice(at + 1).trim()
  }
  return out
}

function tail(text, limit = TAIL_CHARS) {
  const value = String(text ?? '')
  return value.length <= limit ? value : `…\n${value.slice(-limit)}`
}

function number(value, fallback) {
  const parsed = Number(value)
  return Number.isFinite(parsed) ? parsed : fallback
}

async function readFleet() {
  const [shell, workers] = await Promise.all([
    call('shell::exec', { command: 'sh', args: ['-c', STATUS_SCRIPT], cwd: REPO, timeout_ms: 20000 }),
    call('engine::workers::list', {}),
  ])
  const probe = parseKeyValues(shell?.stdout)
  const hostname = probe.hostname ?? 'unknown'
  const list = Array.isArray(workers?.workers) ? workers.workers : []
  return {
    repo: REPO,
    local: {
      hostname,
      kernel: probe.kernel ?? '',
      uptime_s: number(probe.uptime_s, 0),
      generation: probe.generation ? number(probe.generation, null) : null,
      generations: number(probe.generations, 0),
      running: probe.running ?? '',
      profile: probe.profile ?? '',
      pending_rebuild: Boolean(probe.running && probe.profile && probe.running !== probe.profile),
      branch: probe.branch ?? '',
      head: probe.head ?? '',
      dirty: probe.dirty === 'yes',
      probe_exit_code: shell?.exit_code ?? null,
    },
    hosts: String(probe.hosts ?? '')
      .split(',')
      .filter(Boolean)
      .map((name) => ({ name, local: name === hostname })),
    workers: {
      total: list.length,
      connected: list.filter((worker) => worker.status === 'connected').length,
      list: list.slice(0, 40).map((worker) => ({
        name: worker.name,
        version: worker.version ?? '',
        status: worker.status ?? '',
        functions: worker.function_count ?? 0,
      })),
    },
    fetched_at: new Date().toISOString(),
  }
}

let lastCheck = null

iii.registerFunction(
  `${WORKER}::status`,
  async () => readFleet(),
  {
    description:
      'Read the local fleet: this host’s system generation and rebuild state, the flake’s hosts, git state and the connected workers.',
    request_format: { type: 'object', properties: {}, additionalProperties: false },
    response_format: {
      type: 'object',
      properties: {
        repo: { type: 'string' },
        local: { type: 'object' },
        hosts: { type: 'array' },
        workers: { type: 'object' },
        fetched_at: { type: 'string' },
      },
      required: ['repo', 'local', 'hosts', 'workers', 'fetched_at'],
    },
  },
)

iii.registerFunction(
  `${WORKER}::check::run`,
  async () => {
    const job = await call('shell::exec_bg', {
      command: 'nix',
      args: ['flake', 'check', '--no-build', '--accept-flake-config'],
      cwd: REPO,
    })
    lastCheck = { job_id: job?.job_id ?? null, started_at: new Date().toISOString() }
    return { ...lastCheck }
  },
  {
    description:
      'Start `nix flake check --no-build` in the repository as a background job and return its job id.',
    request_format: { type: 'object', properties: {}, additionalProperties: false },
    response_format: {
      type: 'object',
      properties: { job_id: { type: ['string', 'null'] }, started_at: { type: 'string' } },
      required: ['job_id', 'started_at'],
    },
  },
)

iii.registerFunction(
  `${WORKER}::check::status`,
  async ({ job_id } = {}) => {
    const id = job_id || lastCheck?.job_id
    if (!id) {
      return {
        job_id: null,
        status: 'idle',
        exit_code: null,
        duration_ms: null,
        stdout_tail: '',
        stderr_tail: '',
      }
    }
    const result = await call('shell::status', { job_id: id })
    const job = result?.job ?? {}
    const started = number(job.started_at_ms, null)
    const finished = number(job.finished_at_ms, null)
    return {
      job_id: id,
      status: job.status ?? 'unknown',
      exit_code: job.exit_code ?? null,
      duration_ms: started && finished ? finished - started : null,
      stdout_tail: tail(job.stdout),
      stderr_tail: tail(job.stderr),
    }
  },
  {
    description:
      'Read the outcome of the most recent flake check (or a named job): status, exit code, duration and the tail of both streams.',
    request_format: {
      type: 'object',
      properties: { job_id: { type: ['string', 'null'] } },
      additionalProperties: false,
    },
    response_format: {
      type: 'object',
      properties: {
        job_id: { type: ['string', 'null'] },
        status: { type: 'string' },
        exit_code: { type: ['integer', 'null'] },
        duration_ms: { type: ['integer', 'null'] },
        stdout_tail: { type: 'string' },
        stderr_tail: { type: 'string' },
      },
      required: ['job_id', 'status'],
    },
  },
)

// ---- injectable console UI --------------------------------------------------

const UI_CONTENT_FUNCTION = `${WORKER}::ui-content`

const uiAssets = {
  [`${WORKER}/page.js`]: { file: new URL('../ui/page.js', import.meta.url), content_type: 'text/javascript' },
  [`${WORKER}/styles.css`]: { file: new URL('../ui/styles.css', import.meta.url), content_type: 'text/css' },
}

iii.registerFunction(
  UI_CONTENT_FUNCTION,
  async ({ path }) => {
    const asset = uiAssets[path]
    if (!asset) throw new Error(`Unknown UI asset: ${path}`)
    return { content: await readFile(asset.file, 'utf8'), content_type: asset.content_type }
  },
  {
    description: 'Serve this worker’s injectable console UI assets.',
    request_format: {
      type: 'object',
      properties: { path: { type: 'string' } },
      required: ['path'],
      additionalProperties: false,
    },
    response_format: {
      type: 'object',
      properties: { content: { type: 'string' }, content_type: { type: 'string' } },
      required: ['content', 'content_type'],
    },
  },
)

// Message-path registrations: replayed on reconnect, removed on disconnect.
iii.registerTrigger({ type: 'console:script', function_id: UI_CONTENT_FUNCTION, config: { path: `${WORKER}/page.js` } })
iii.registerTrigger({ type: 'console:style', function_id: UI_CONTENT_FUNCTION, config: { path: `${WORKER}/styles.css` } })

const shutdown = async () => {
  try {
    await iii.shutdown()
  } finally {
    process.exit(0)
  }
}

process.on('SIGINT', shutdown)
process.on('SIGTERM', shutdown)
