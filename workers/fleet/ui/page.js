// The fleet page, injected into the console. Plain ESM + createElement: the console's
// import map serves `react` and `@iii-dev/console-ui`, so no bundler is involved. The
// /hooks and /format subpaths are NOT in the import map (they bundle in a built worker),
// so the two formatters this page needs are written here.
import { createElement as h, useCallback, useEffect, useRef, useState } from 'react'
import { PageHeader, PageMain, PageShell } from '@iii-dev/console-ui'

const PAGE_ID = 'fleet-overview'
const FLEET_POLL_MS = 15000
const CHECK_POLL_MS = 2500
const WORKER_ROWS = 12

function trigger(host, functionId, payload) {
  return host.iii.trigger(functionId, payload ?? {}, { timeoutMs: 30000 })
}

function formatUptime(seconds) {
  const value = Number(seconds)
  if (!Number.isFinite(value) || value <= 0) return '—'
  const days = Math.floor(value / 86400)
  const hours = Math.floor((value % 86400) / 3600)
  const minutes = Math.floor((value % 3600) / 60)
  if (days > 0) return `${days}d ${hours}h`
  if (hours > 0) return `${hours}h ${minutes}m`
  return `${minutes}m`
}

function formatDuration(ms) {
  const value = Number(ms)
  if (!Number.isFinite(value) || value < 0) return '—'
  if (value < 1000) return `${value} ms`
  const seconds = value / 1000
  if (seconds < 60) return `${seconds.toFixed(1)} s`
  return `${Math.floor(seconds / 60)}m ${Math.round(seconds % 60)}s`
}

function formatClock(iso) {
  if (!iso) return '—'
  const date = new Date(iso)
  return Number.isNaN(date.getTime()) ? '—' : date.toLocaleTimeString()
}

function errorText(error) {
  if (!error) return 'unknown error'
  return error.message || error.code || String(error)
}

function Dot({ tone }) {
  return h('span', { className: `fleet-dot fleet-dot-${tone}`, 'aria-hidden': true })
}

function Badge({ tone = 'neutral', children }) {
  return h('span', { className: `fleet-badge fleet-badge-${tone}` }, children)
}

function Stat({ label, value, tone, hint }) {
  return h(
    'div',
    { className: 'fleet-stat' },
    h('div', { className: 'fleet-stat-label' }, label),
    h('div', { className: 'fleet-stat-value' }, value),
    hint ? h('div', { className: `fleet-stat-hint fleet-text-${tone ?? 'ghost'}` }, hint) : null,
  )
}

function Row({ label, value, mono = true }) {
  return h(
    'div',
    { className: 'fleet-row' },
    h('span', { className: 'fleet-row-label' }, label),
    h('span', { className: mono ? 'fleet-row-value' : 'fleet-row-value fleet-sans' }, value),
  )
}

function Card({ title, aside, children, className }) {
  return h(
    'section',
    { className: `fleet-card ${className ?? ''}` },
    h(
      'header',
      { className: 'fleet-card-head' },
      h('h2', { className: 'fleet-card-title' }, title),
      aside ? h('div', { className: 'fleet-card-aside' }, aside) : null,
    ),
    h('div', { className: 'fleet-card-body' }, children),
  )
}

function FleetPage({ host, onRequestClose }) {
  const [fleet, setFleet] = useState(null)
  const [fleetError, setFleetError] = useState(null)
  const [loading, setLoading] = useState(true)
  const [check, setCheck] = useState(null)
  const [starting, setStarting] = useState(false)
  const [checkError, setCheckError] = useState(null)
  const requestSeq = useRef(0)

  const loadFleet = useCallback(async () => {
    const seq = ++requestSeq.current
    try {
      const next = await trigger(host, 'fleet::status')
      if (seq !== requestSeq.current) return
      setFleet(next)
      setFleetError(null)
    } catch (error) {
      if (seq !== requestSeq.current) return
      setFleetError(errorText(error))
    } finally {
      if (seq === requestSeq.current) setLoading(false)
    }
  }, [host])

  const loadCheck = useCallback(
    async (jobId) => {
      try {
        const next = await trigger(host, 'fleet::check::status', jobId ? { job_id: jobId } : {})
        setCheck(next)
        setCheckError(null)
      } catch (error) {
        setCheckError(errorText(error))
      }
    },
    [host],
  )

  const runCheck = useCallback(async () => {
    setStarting(true)
    setCheckError(null)
    try {
      const started = await trigger(host, 'fleet::check::run')
      await loadCheck(started?.job_id)
    } catch (error) {
      setCheckError(errorText(error))
    } finally {
      setStarting(false)
    }
  }, [host, loadCheck])

  useEffect(() => {
    loadFleet()
    loadCheck()
    const timer = setInterval(loadFleet, FLEET_POLL_MS)
    return () => clearInterval(timer)
  }, [loadFleet, loadCheck])

  const checkRunning = check?.status === 'running'

  useEffect(() => {
    if (!checkRunning) return undefined
    const timer = setInterval(() => loadCheck(check?.job_id), CHECK_POLL_MS)
    return () => clearInterval(timer)
  }, [checkRunning, check?.job_id, loadCheck])

  const local = fleet?.local
  const checkTone = checkError
    ? 'alert'
    : !check || check.status === 'idle'
      ? 'neutral'
      : check.status === 'running'
        ? 'accent'
        : check.exit_code === 0
          ? 'ok'
          : 'alert'

  const header = h(PageHeader, {
    title: 'Fleet',
    description: fleet ? `Hosts, generations and the land gate for ${fleet.repo}` : 'Hosts, generations and the land gate for this repository',
    onClose: onRequestClose,
    actions: h(
      'button',
      { type: 'button', className: 'fleet-button', onClick: loadFleet, disabled: loading },
      loading ? 'Reading…' : 'Refresh',
    ),
  })

  if (loading && !fleet) {
    return h(
      PageShell,
      { className: 'fleet-shell' },
      header,
      h(PageMain, { className: 'fleet-main' }, h('p', { className: 'fleet-quiet' }, 'Reading the fleet…')),
    )
  }

  if (!fleet) {
    return h(
      PageShell,
      { className: 'fleet-shell' },
      header,
      h(
        PageMain,
        { className: 'fleet-main' },
        h('div', { className: 'fleet-panel fleet-panel-alert' }, `Could not read the fleet: ${fleetError ?? 'unknown error'}`),
      ),
    )
  }

  const hostCount = fleet.hosts.length
  const workers = fleet.workers

  return h(
    PageShell,
    { className: 'fleet-shell' },
    header,
    h(
      PageMain,
      { className: 'fleet-main' },
      fleetError ? h('div', { className: 'fleet-panel fleet-panel-alert' }, `Last refresh failed: ${fleetError}`) : null,

      h(
        'div',
        { className: 'fleet-stats' },
        h(Stat, {
          label: 'Hosts',
          value: String(hostCount),
          hint: fleet.hosts.map((entry) => entry.name).join(', ') || 'none',
        }),
        h(Stat, {
          label: 'Workers',
          value: `${workers.connected}/${workers.total}`,
          hint: 'connected',
          tone: workers.connected === workers.total ? 'ok' : 'warn',
        }),
        h(Stat, {
          label: 'Generation',
          value: local?.generation ? `#${local.generation}` : '—',
          hint: local?.generations ? `of ${local.generations} kept` : 'unknown',
        }),
        h(Stat, {
          label: 'Branch',
          value: local?.branch || '—',
          hint: local?.head ? `${local.head}${local.dirty ? ' · dirty' : ''}` : 'unknown',
          tone: local?.dirty ? 'warn' : 'ok',
        }),
      ),

      h(
        'div',
        { className: 'fleet-grid' },
        h(
          Card,
          {
            title: 'This host',
            aside: local?.pending_rebuild
              ? h(Badge, { tone: 'warn' }, 'rebuild pending')
              : h(Badge, { tone: 'ok' }, 'up to date'),
          },
          h(Row, { label: 'Hostname', value: local?.hostname ?? '—' }),
          h(Row, { label: 'Kernel', value: local?.kernel || '—' }),
          h(Row, { label: 'Uptime', value: formatUptime(local?.uptime_s) }),
          h(Row, { label: 'Running', value: local?.running || '—' }),
          h(Row, { label: 'Profile', value: local?.profile || '—' }),
          local?.pending_rebuild
            ? h(
                'p',
                { className: 'fleet-note' },
                'The booted system differs from the current system profile — the last rebuild has not been activated.',
              )
            : null,
        ),

        h(
          Card,
          { title: 'Flake check', aside: h(Badge, { tone: checkTone }, check?.status ?? 'not run') },
          h(
            'div',
            { className: 'fleet-actions' },
            h(
              'button',
              { type: 'button', className: 'fleet-button fleet-button-primary', onClick: runCheck, disabled: starting || checkRunning },
              starting ? 'Starting…' : checkRunning ? 'Checking…' : 'Run flake check',
            ),
            check?.duration_ms ? h('span', { className: 'fleet-quiet' }, formatDuration(check.duration_ms)) : null,
            check?.exit_code !== null && check?.exit_code !== undefined && check?.status !== 'running'
              ? h('span', { className: 'fleet-quiet' }, `exit ${check.exit_code}`)
              : null,
            check?.started_at || check?.job_id ? h('span', { className: 'fleet-quiet' }, `job ${String(check.job_id).slice(0, 12)}`) : null,
          ),
          checkError ? h('div', { className: 'fleet-panel fleet-panel-alert' }, checkError) : null,
          h(
            'p',
            { className: 'fleet-note' },
            'Runs `nix flake check --no-build` in the repository: every output is evaluated, nothing is built. The full build check stays in CI.',
          ),
          check?.stderr_tail || check?.stdout_tail
            ? h('pre', { className: 'fleet-log' }, `${check.stdout_tail ?? ''}${check.stderr_tail ?? ''}`.trim())
            : null,
        ),

        h(
          Card,
          { title: 'Hosts' },
          fleet.hosts.length === 0
            ? h('p', { className: 'fleet-quiet' }, 'No host directories under modules/hosts.')
            : h(
                'ul',
                { className: 'fleet-list' },
                fleet.hosts.map((entry) =>
                  h(
                    'li',
                    { key: entry.name, className: 'fleet-list-item' },
                    h(Dot, { tone: entry.local ? 'accent' : 'neutral' }),
                    h('span', { className: 'fleet-list-name' }, entry.name),
                    entry.local ? h('span', { className: 'fleet-quiet' }, 'this host') : null,
                  ),
                ),
              ),
        ),

        h(
          Card,
          { title: 'Workers', aside: h('span', { className: 'fleet-quiet' }, `${workers.total} connected` ) },
          workers.list.length === 0
            ? h('p', { className: 'fleet-quiet' }, 'No workers are connected.')
            : h(
                'ul',
                { className: 'fleet-list' },
                workers.list.slice(0, WORKER_ROWS).map((worker) =>
                  h(
                    'li',
                    { key: worker.name, className: 'fleet-list-item' },
                    h(Dot, { tone: worker.status === 'connected' ? 'ok' : 'warn' }),
                    h('span', { className: 'fleet-list-name' }, worker.name),
                    h('span', { className: 'fleet-list-meta' }, `${worker.functions} fn`),
                    h('span', { className: 'fleet-list-meta' }, worker.version || '—'),
                  ),
                ),
                workers.list.length > WORKER_ROWS
                  ? h('li', { className: 'fleet-list-item fleet-quiet' }, `+${workers.list.length - WORKER_ROWS} more`)
                  : null,
              ),
        ),
      ),

      h('p', { className: 'fleet-footnote' }, `Read at ${formatClock(fleet.fetched_at)}`),
    ),
  )
}

export default function setup(host) {
  host.pages.register({
    id: PAGE_ID,
    title: 'Fleet',
    render: (props) => h(FleetPage, { host, ...props }),
  })
}
