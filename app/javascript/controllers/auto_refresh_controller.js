import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 5000 },
    url: String
  }

  static targets = ["indicator", "status"]

  connect() {
    this.startRefreshing()
  }

  disconnect() {
    this.stopRefreshing()
  }

  startRefreshing() {
    this.refreshTimer = setInterval(() => {
      this.refresh()
    }, this.intervalValue)
  }

  stopRefreshing() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
    }
  }

  async refresh() {
    try {
      const response = await fetch(this.urlValue, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html, text/html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const html = await response.text()
        const frame = document.querySelector("turbo-frame#variant-stats")
        if (frame) {
          frame.innerHTML = html
        }
      }
    } catch (error) {
      console.error("Auto-refresh failed:", error)
    }
  }
}
