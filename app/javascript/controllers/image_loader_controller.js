import { Controller } from "@hotwired/stimulus"

// Handles image loading states with skeleton placeholder animation.
// Shows a pulsing placeholder while images load, then fades them in smoothly.
//
// Usage:
//   <img src="..." data-controller="image-loader" data-action="load->image-loader#loaded error->image-loader#error" class="image-loading">
//
export default class extends Controller {
  connect() {
    // If image is already cached/loaded, remove loading state immediately
    if (this.element.complete && this.element.naturalHeight !== 0) {
      this.loaded()
    }
  }

  loaded() {
    this.element.classList.remove("image-loading")
    this.element.classList.add("image-loaded")
  }

  error() {
    // On error, still remove loading state to show fallback/placeholder
    this.element.classList.remove("image-loading")
    this.element.classList.add("image-error")
  }
}
