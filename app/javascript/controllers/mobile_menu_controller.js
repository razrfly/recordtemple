import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "filterPanel", "backdrop"]

  toggle() {
    this.panelTarget.classList.toggle("hidden")
    document.body.classList.toggle("overflow-hidden")
  }

  close() {
    this.panelTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  openFilters() {
    this.filterPanelTarget.classList.remove("translate-x-full")
    this.backdropTarget.classList.remove("opacity-0", "pointer-events-none")
    document.body.classList.add("overflow-hidden")
  }

  closeFilters() {
    this.filterPanelTarget.classList.add("translate-x-full")
    this.backdropTarget.classList.add("opacity-0", "pointer-events-none")
    document.body.classList.remove("overflow-hidden")
  }

  // Close on escape key
  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      if (this.hasFilterPanelTarget && !this.filterPanelTarget.classList.contains("translate-x-full")) {
        this.closeFilters()
      } else if (this.hasPanelTarget && !this.panelTarget.classList.contains("hidden")) {
        this.close()
      }
    }
  }
}
