import { Controller } from "@hotwired/stimulus"

// Handles tab switching and horizontal carousel for discovery pages
export default class extends Controller {
  static targets = ["tab", "panel", "carousel"]
  static values = {
    activeTab: { type: String, default: "popular" }
  }

  connect() {
    this.showTab(this.activeTabValue)
  }

  // Switch to a different tab
  switch(event) {
    event.preventDefault()
    const tabName = event.currentTarget.dataset.tab
    this.activeTabValue = tabName
    this.showTab(tabName)
  }

  showTab(tabName) {
    // Update tab button states
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tab === tabName
      tab.classList.toggle("bg-olive-900", isActive)
      tab.classList.toggle("text-white", isActive)
      tab.classList.toggle("bg-olive-100", !isActive)
      tab.classList.toggle("text-olive-700", !isActive)
      tab.setAttribute("aria-selected", isActive)
    })

    // Show/hide panels
    this.panelTargets.forEach(panel => {
      const isActive = panel.dataset.tab === tabName
      panel.classList.toggle("hidden", !isActive)
      panel.setAttribute("aria-hidden", !isActive)
    })
  }

  // Scroll carousel left
  scrollLeft(event) {
    const carousel = event.currentTarget.closest("[data-discovery-tabs-target='panel']")
                          ?.querySelector("[data-discovery-tabs-target='carousel']")
    if (carousel) {
      const scrollAmount = carousel.clientWidth * 0.8
      carousel.scrollBy({ left: -scrollAmount, behavior: "smooth" })
    }
  }

  // Scroll carousel right
  scrollRight(event) {
    const carousel = event.currentTarget.closest("[data-discovery-tabs-target='panel']")
                          ?.querySelector("[data-discovery-tabs-target='carousel']")
    if (carousel) {
      const scrollAmount = carousel.clientWidth * 0.8
      carousel.scrollBy({ left: scrollAmount, behavior: "smooth" })
    }
  }
}
