import { Controller } from "@hotwired/stimulus"

// Syncs the sort parameter from URL to hidden inputs in filter forms
// This ensures the sort is preserved when applying filters via Turbo Frames
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.boundSyncFromUrl = this.syncFromUrl.bind(this)
    this.boundSyncFromUrl()
    // Listen for Turbo navigation to keep in sync
    document.addEventListener("turbo:load", this.boundSyncFromUrl)
    document.addEventListener("turbo:frame-load", this.boundSyncFromUrl)
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.boundSyncFromUrl)
    document.removeEventListener("turbo:frame-load", this.boundSyncFromUrl)
  }

  syncFromUrl() {
    const url = new URL(window.location.href)
    const sortValue = url.searchParams.get("q[s]") || ""

    if (this.hasInputTarget) {
      this.inputTarget.value = sortValue
    }
  }
}
