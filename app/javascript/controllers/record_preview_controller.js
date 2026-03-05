import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.card = null
    this.timer = null
    this.abortController = null
  }

  disconnect() {
    this.cleanup()
  }

  show() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.fetchCard(), 120)
  }

  hide() {
    clearTimeout(this.timer)
    this.removeCard()
  }

  async fetchCard() {
    if (this.abortController) this.abortController.abort()
    this.abortController = new AbortController()
    try {
      const response = await fetch(this.urlValue, {
        signal: this.abortController.signal,
        headers: { Accept: "text/html", "X-Requested-With": "XMLHttpRequest" }
      })
      if (!response.ok) return
      const html = await response.text()
      this.showCard(html)
    } catch (e) {
      if (e.name !== "AbortError") console.error("Record preview error:", e)
    }
  }

  showCard(html) {
    this.removeCard()
    const wrapper = document.createElement("div")
    wrapper.innerHTML = html.trim()
    this.card = wrapper.firstElementChild
    if (!this.card) return

    const rect = this.element.getBoundingClientRect()
    const cardWidth = 256 // 256px card
    const margin = 8

    this.card.style.position = "fixed"
    this.card.style.zIndex = "9999"
    this.card.style.left = `${Math.min(rect.left, window.innerWidth - cardWidth - margin)}px`

    // Show below row; flip above if near bottom of viewport
    if (window.innerHeight - rect.bottom > 240) {
      this.card.style.top = `${rect.bottom + margin}px`
    } else {
      this.card.style.top = "auto"
      this.card.style.bottom = `${window.innerHeight - rect.top + margin}px`
    }

    document.body.appendChild(this.card)
  }

  removeCard() {
    if (this.card) { this.card.remove(); this.card = null }
    if (this.abortController) { this.abortController.abort(); this.abortController = null }
  }

  cleanup() {
    clearTimeout(this.timer)
    this.removeCard()
  }
}
