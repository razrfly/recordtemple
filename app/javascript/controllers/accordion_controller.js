import { Controller } from "@hotwired/stimulus"

// Simple accordion controller for expandable sections
export default class extends Controller {
  static targets = ["icon", "content", "label"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    // Set initial state based on open value
    if (this.openValue) {
      this.expand()
    }
  }

  toggle() {
    if (this.contentTarget.classList.contains("hidden")) {
      this.expand()
    } else {
      this.collapse()
    }
  }

  expand() {
    this.contentTarget.classList.remove("hidden")
    this.iconTarget.classList.add("rotate-180")
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = "Hide"
    }
    this.openValue = true
  }

  collapse() {
    this.contentTarget.classList.add("hidden")
    this.iconTarget.classList.remove("rotate-180")
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = "Show"
    }
    this.openValue = false
  }
}
