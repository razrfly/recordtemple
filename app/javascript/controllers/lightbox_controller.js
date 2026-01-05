import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image", "backdrop", "counter", "thumbnail", "closeButton"]
  static values = {
    images: Array,
    currentIndex: { type: Number, default: 0 }
  }

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  open(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    if (isNaN(index) || index < 0 || index >= this.imagesValue.length) {
      this.currentIndexValue = 0
    } else {
      this.currentIndexValue = index
    }
    this.showImage()
    this.modalTarget.classList.remove("opacity-0", "pointer-events-none")
    this.modalTarget.classList.add("opacity-100")
    document.body.classList.add("overflow-hidden")
    document.addEventListener("keydown", this.boundHandleKeydown)
    this.updateThumbnails()

    // Focus management for accessibility
    this.previouslyFocused = document.activeElement
    setTimeout(() => {
      if (this.hasCloseButtonTarget) {
        this.closeButtonTarget.focus()
      }
    }, 100)

    // Announce to screen readers
    this.announceToScreenReader(`Image ${this.currentIndexValue + 1} of ${this.imagesValue.length}`)
  }

  close() {
    this.modalTarget.classList.add("opacity-0", "pointer-events-none")
    this.modalTarget.classList.remove("opacity-100")
    document.body.classList.remove("overflow-hidden")
    document.removeEventListener("keydown", this.boundHandleKeydown)

    // Restore focus
    if (this.previouslyFocused) {
      this.previouslyFocused.focus()
    }
  }

  next(event) {
    if (event) event.stopPropagation()
    if (this.currentIndexValue < this.imagesValue.length - 1) {
      this.currentIndexValue++
      this.showImage()
      this.updateThumbnails()
      this.announceToScreenReader(`Image ${this.currentIndexValue + 1} of ${this.imagesValue.length}`)
    }
  }

  previous(event) {
    if (event) event.stopPropagation()
    if (this.currentIndexValue > 0) {
      this.currentIndexValue--
      this.showImage()
      this.updateThumbnails()
      this.announceToScreenReader(`Image ${this.currentIndexValue + 1} of ${this.imagesValue.length}`)
    }
  }

  goTo(event) {
    event.stopPropagation()
    const index = parseInt(event.currentTarget.dataset.index, 10)
    if (isNaN(index) || index < 0 || index >= this.imagesValue.length) {
      return
    }
    this.currentIndexValue = index
    this.showImage()
    this.updateThumbnails()
    this.announceToScreenReader(`Image ${this.currentIndexValue + 1} of ${this.imagesValue.length}`)
  }

  showImage() {
    const image = this.imagesValue[this.currentIndexValue]
    if (image) {
      this.imageTarget.src = image.url
      this.imageTarget.alt = image.alt || `Image ${this.currentIndexValue + 1}`
      this.counterTarget.textContent = `${this.currentIndexValue + 1} / ${this.imagesValue.length}`
    }
  }

  updateThumbnails() {
    this.thumbnailTargets.forEach((thumb, i) => {
      if (i === this.currentIndexValue) {
        thumb.classList.remove("ring-olive-200", "opacity-60")
        thumb.classList.add("ring-white", "ring-2")
        thumb.setAttribute("aria-current", "true")
      } else {
        thumb.classList.add("ring-olive-200", "opacity-60")
        thumb.classList.remove("ring-white", "ring-2")
        thumb.removeAttribute("aria-current")
      }
    })
  }

  handleKeydown(event) {
    switch (event.key) {
      case "Escape":
        this.close()
        break
      case "ArrowRight":
        this.next()
        break
      case "ArrowLeft":
        this.previous()
        break
      case "Home":
        if (this.currentIndexValue !== 0) {
          this.currentIndexValue = 0
          this.showImage()
          this.updateThumbnails()
          this.announceToScreenReader(`Image 1 of ${this.imagesValue.length}`)
        }
        break
      case "End":
        if (this.currentIndexValue !== this.imagesValue.length - 1) {
          this.currentIndexValue = this.imagesValue.length - 1
          this.showImage()
          this.updateThumbnails()
          this.announceToScreenReader(`Image ${this.imagesValue.length} of ${this.imagesValue.length}`)
        }
        break
    }
  }

  // Prevent closing when clicking on the image
  stopPropagation(event) {
    event.stopPropagation()
  }

  // Announce changes to screen readers
  announceToScreenReader(message) {
    let announcer = document.getElementById("lightbox-announcer")
    if (!announcer) {
      announcer = document.createElement("div")
      announcer.id = "lightbox-announcer"
      announcer.setAttribute("aria-live", "polite")
      announcer.setAttribute("aria-atomic", "true")
      announcer.className = "sr-only"
      document.body.appendChild(announcer)
    }
    announcer.textContent = message
  }
}
