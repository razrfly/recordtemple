import { Controller } from "@hotwired/stimulus"

// View toggle controller for switching between grid and list views
// Persists user preference in localStorage
export default class extends Controller {
  static targets = ["gridView", "listView", "gridButton", "listButton"]
  static values = {
    storageKey: { type: String, default: "recordViewPreference" },
    defaultView: { type: String, default: "grid" }
  }

  connect() {
    this.applyView(this.currentView)
  }

  get currentView() {
    return localStorage.getItem(this.storageKeyValue) || this.defaultViewValue
  }

  set currentView(view) {
    localStorage.setItem(this.storageKeyValue, view)
  }

  showGrid() {
    this.currentView = "grid"
    this.applyView("grid")
  }

  showList() {
    this.currentView = "list"
    this.applyView("list")
  }

  applyView(view) {
    if (view === "grid") {
      this.gridViewTarget.classList.remove("hidden")
      this.listViewTarget.classList.add("hidden")
      this.gridButtonTarget.classList.add("bg-olive-950", "text-white")
      this.gridButtonTarget.classList.remove("bg-white", "text-olive-700", "hover:bg-olive-50")
      this.listButtonTarget.classList.remove("bg-olive-950", "text-white")
      this.listButtonTarget.classList.add("bg-white", "text-olive-700", "hover:bg-olive-50")
    } else {
      this.gridViewTarget.classList.add("hidden")
      this.listViewTarget.classList.remove("hidden")
      this.listButtonTarget.classList.add("bg-olive-950", "text-white")
      this.listButtonTarget.classList.remove("bg-white", "text-olive-700", "hover:bg-olive-50")
      this.gridButtonTarget.classList.remove("bg-olive-950", "text-white")
      this.gridButtonTarget.classList.add("bg-white", "text-olive-700", "hover:bg-olive-50")
    }
  }
}
