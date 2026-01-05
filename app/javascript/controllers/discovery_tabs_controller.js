import { Controller } from "@hotwired/stimulus"

// Handles tab switching and horizontal carousel for discovery pages
export default class extends Controller {
  static targets = ["tab", "panel", "carousel"]
  static values = {
    activeTab: { type: String, default: "popular" }
  }

  connect() {
    this.showTab(this.activeTabValue)
    // Add keyboard navigation
    this.element.addEventListener("keydown", this.handleKeydown.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.handleKeydown.bind(this))
  }

  // Handle keyboard navigation for tabs
  handleKeydown(event) {
    if (!event.target.matches("[role='tab']")) return

    const tabs = this.tabTargets
    const currentIndex = tabs.indexOf(event.target)

    let newIndex
    switch (event.key) {
      case "ArrowLeft":
        newIndex = currentIndex > 0 ? currentIndex - 1 : tabs.length - 1
        break
      case "ArrowRight":
        newIndex = currentIndex < tabs.length - 1 ? currentIndex + 1 : 0
        break
      case "Home":
        newIndex = 0
        break
      case "End":
        newIndex = tabs.length - 1
        break
      default:
        return
    }

    event.preventDefault()
    tabs[newIndex].focus()
    tabs[newIndex].click()
  }

  // Switch to a different tab
  switch(event) {
    event.preventDefault()
    const tabName = event.currentTarget.dataset.tab
    this.activeTabValue = tabName
    this.showTab(tabName)
  }

  showTab(tabName) {
    // Update tab button states using inline styles (Tailwind v4 doesn't generate bg-olive-* classes)
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tab === tabName
      tab.style.backgroundColor = isActive ? 'var(--color-olive-900)' : 'var(--color-olive-200)'
      tab.style.color = isActive ? 'white' : 'var(--color-olive-900)'
      tab.setAttribute("aria-selected", isActive)
    })

    // Show/hide panels with animation
    this.panelTargets.forEach(panel => {
      const isActive = panel.dataset.tab === tabName

      if (isActive) {
        panel.classList.remove("hidden")
        // Trigger reflow for animation
        panel.offsetHeight
        panel.classList.add("animate-fade-in")
      } else {
        panel.classList.add("hidden")
        panel.classList.remove("animate-fade-in")
      }

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
