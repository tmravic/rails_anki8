let eventSequence = 0
const eventCounts = {}
const MAX_LOG_ENTRIES = 25

const EVENT_ROLES = {
  "DOMContentLoaded": "Browser finished parsing HTML (full page load only)",
  "turbo:before-cache": "Old page about to be cached before you navigate away",
  "turbo:before-render": "New page HTML arrived; Turbo is about to swap the <body>",
  "turbo:render": "New <body> is in the DOM (scripts may not have run yet)",
  "turbo:load": "New page is ready — like DOMContentLoaded on every Turbo visit",
  "turbo:frame-render": "A <turbo-frame> finished updating (partial, not full page)"
}

function randomBoxColor() {
  const box = document.querySelector("#turbo-demo .box")
  if (!box) return

  const hue = Math.floor(Math.random() * 360)
  box.style.backgroundColor = `hsl(${hue}, 70%, 80%)`
}

function recordEvent(name, detail = "") {
  eventSequence++
  eventCounts[name] = (eventCounts[name] || 0) + 1

  const label = detail ? `${name} — ${detail}` : name
  console.log(`[turbo-demo #${eventSequence}] ${label}`)

  updateCounters()
  prependLogEntry(eventSequence, name, detail)
}

function updateCounters() {
  for (const [name, role] of Object.entries(EVENT_ROLES)) {
    const countEl = document.querySelector(`[data-event-count="${name}"]`)
    if (countEl) countEl.textContent = eventCounts[name] || 0
  }
}

function prependLogEntry(sequence, name, detail) {
  const log = document.getElementById("turbo-event-log")
  if (!log) return

  const entry = document.createElement("li")
  entry.innerHTML = `<strong>#${sequence}</strong> <code>${name}</code>${detail ? ` <span class="detail">— ${detail}</span>` : ""}`
  log.prepend(entry)

  while (log.children.length > MAX_LOG_ENTRIES) {
    log.lastElementChild.remove()
  }
}

document.addEventListener("DOMContentLoaded", () => {
  recordEvent("DOMContentLoaded")
})

document.addEventListener("turbo:before-cache", () => {
  recordEvent("turbo:before-cache", "snapshotting current page")
})

document.addEventListener("turbo:before-render", (event) => {
  const hasNewBody = Boolean(event.detail?.newBody)
  recordEvent("turbo:before-render", `newBody present: ${hasNewBody}`)
})

document.addEventListener("turbo:render", () => {
  recordEvent("turbo:render")
})

document.addEventListener("turbo:load", () => {
  recordEvent("turbo:load", "recoloring .box")
  randomBoxColor()
})

document.addEventListener("turbo:frame-render", (event) => {
  const frame = event.target
  const frameId = frame.id || frame.getAttribute("id") || "unnamed frame"
  recordEvent("turbo:frame-render", frameId)
})