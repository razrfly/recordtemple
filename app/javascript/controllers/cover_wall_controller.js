import { Controller } from "@hotwired/stimulus"

// Handles the cover wall masonry grid with infinite scroll and quick-view modal
export default class extends Controller {
  static targets = ["grid", "loading", "sentinel", "modal", "modalContent"]
  static values = {
    cursor: String,
    loading: { type: Boolean, default: false },
    hasMore: { type: Boolean, default: true }
  }

  connect() {
    this.setupIntersectionObserver()
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  setupIntersectionObserver() {
    if (!this.hasSentinelTarget) return

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting && !this.loadingValue && this.hasMoreValue) {
            this.loadMore()
          }
        })
      },
      { rootMargin: "400px" }
    )

    this.observer.observe(this.sentinelTarget)
  }

  async loadMore() {
    if (this.loadingValue || !this.hasMoreValue || !this.cursorValue) return

    this.loadingValue = true
    this.showLoading()

    try {
      const response = await fetch(`/discovery/wall?cursor=${this.cursorValue}`, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)

        // Update cursor and hasMore from the meta element after render
        requestAnimationFrame(() => {
          const meta = document.getElementById("cover-wall-meta")
          if (meta) {
            this.cursorValue = meta.dataset.cursor || ""
            this.hasMoreValue = meta.dataset.hasMore === "true"
          }
        })
      }
    } catch (error) {
      console.error("Error loading more covers:", error)
    } finally {
      this.loadingValue = false
      this.hideLoading()
    }
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden")
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add("hidden")
    }
  }

  // Quick view modal
  async openQuickView(event) {
    event.preventDefault()
    const recordId = event.currentTarget.dataset.recordId

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
