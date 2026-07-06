let turboLoadCount = 0
let domContentLoadedCount = 0

function randomBoxColor() {
  const box = document.querySelector("#turbo-demo .box")
  if (!box) return

  const hue = Math.floor(Math.random() * 360)
  box.style.backgroundColor = `hsl(${hue}, 70%, 80%)`
}

function updateCounters() {
  const turboCount = document.getElementById("turbo-load-count")
  const domCount = document.getElementById("dom-content-loaded-count")

  if (turboCount) turboCount.textContent = turboLoadCount
  if (domCount) domCount.textContent = domContentLoadedCount
}

document.addEventListener("DOMContentLoaded", () => {
  domContentLoadedCount++
  updateCounters()
})

document.addEventListener("turbo:load", () => {
  turboLoadCount++
  randomBoxColor()
  updateCounters()
})