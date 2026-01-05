import { Controller } from "@hotwired/stimulus"

// Handles the cover wall grid and quick-view modal
export default class extends Controller {
  static targets = ["grid", "modal", "modalContent"]

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  // Quick view modal
  async openQuickView(event) {
    event.preventDefault()
    const recordId = event.currentTarget.dataset.recordId

    if (!recordId) {
      console.error("No record ID provided for quick view")
      return
    }

    try {
      const response = await fetch(`/discovery/quick_view/${recordId}`, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
        this.showModal()
      } else {
        console.error("Quick view failed:", response.status, response.statusText)
      }
    } catch (error) {
      console.error("Error loading quick view:", error)
    }
  }

  showModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("opacity-0", "pointer-events-none")
      this.modalTarget.classList.add("opacity-100")
      document.body.classList.add("overflow-hidden")

      // Focus the modal for accessibility
      if (this.hasModalContentTarget) {
        this.modalContentTarget.focus()
      }
    }
  }

  closeModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("opacity-0", "pointer-events-none")
      this.modalTarget.classList.remove("opacity-100")
      document.body.classList.remove("overflow-hidden")

      // Stop any playing audio
      const audio = this.modalTarget.querySelector("audio")
      if (audio) {
        audio.pause()
        audio.currentTime = 0
      }
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.hasModalTarget && !this.modalTarget.classList.contains("pointer-events-none")) {
      this.closeModal()
    }
  }

  // Prevent clicks inside modal content from closing the modal
  stopPropagation(event) {
    event.stopPropagation()
  }
}
