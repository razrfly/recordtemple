import { Controller } from "@hotwired/stimulus"

// Handles the shuffle machine with 4-record grid
export default class extends Controller {
  static targets = ["grid", "spinButton"]
  static values = { spinning: { type: Boolean, default: false } }

  async spin() {
    if (this.spinningValue) return

    this.spinningValue = true
    this.disableButton()

    // Add spinning animation to grid
    if (this.hasGridTarget) {
      this.gridTarget.classList.add("opacity-50", "scale-95", "transition-all", "duration-300")
    }

    try {
      const response = await fetch("/discovery/shuffle", {
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const html = await response.text()

        // Brief delay for visual effect
        await new Promise(resolve => setTimeout(resolve, 400))

        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Error shuffling:", error)
    } finally {
      // Remove spinning animation
      if (this.hasGridTarget) {
        this.gridTarget.classList.remove("opacity-50", "scale-95")
      }
      this.spinningValue = false
      this.enableButton()
    }
  }

  disableButton() {
    if (this.hasSpinButtonTarget) {
      this.spinButtonTarget.disabled = true
      this.spinButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.spinButtonTarget.innerHTML = `
        <svg class="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
        </svg>
        Shuffling...
      `
    }
  }

  enableButton() {
    if (this.hasSpinButtonTarget) {
      this.spinButtonTarget.disabled = false
      this.spinButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      this.spinButtonTarget.innerHTML = `
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
        </svg>
        Shuffle
      `
    }
  }
}
