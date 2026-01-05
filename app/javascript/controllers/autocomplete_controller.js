import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "selected", "hiddenInputs"]
  static values = {
    url: String,
    paramName: String,
    minLength: { type: Number, default: 2 },
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.selectedItems = new Map()
    this.highlightedIndex = -1
    this.abortController = null
    this.debounceTimer = null

    this.restoreSelections()

    this.boundHandleKeydown = this.handleKeydown.bind(this)
    this.inputTarget.addEventListener("keydown", this.boundHandleKeydown)

    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  disconnect() {
    this.inputTarget.removeEventListener("keydown", this.boundHandleKeydown)
    document.removeEventListener("click", this.boundHandleClickOutside)
    if (this.abortController) {
      this.abortController.abort()
    }
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  restoreSelections() {
    const hiddenInputs = this.hiddenInputsTarget.querySelectorAll('input[type="hidden"]')
    hiddenInputs.forEach(input => {
      const id = input.value
      const name = input.dataset.name
      const count = input.dataset.count
      if (id && name) {
        this.selectedItems.set(id, { id, name, count: count || 0 })
      }
    })
    this.renderSelected()
  }

  search() {
    clearTimeout(this.debounceTimer)

    const query = this.inputTarget.value.trim()

    if (query.length < this.minLengthValue) {
      this.hideResults()
      return
    }

    this.debounceTimer = setTimeout(() => {
      this.fetchResults(query)
    }, this.debounceValue)
  }

  async fetchResults(query) {
    if (this.abortController) {
      this.abortController.abort()
    }
    this.abortController = new AbortController()

    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set("q", query)

      const response = await fetch(url, {
        signal: this.abortController.signal,
        headers: {
          "Accept": "application/json"
        }
      })

      if (!response.ok) throw new Error("Network response was not ok")

      const results = await response.json()
      this.renderResults(results)
    } catch (error) {
      if (error.name !== "AbortError") {
        console.error("Autocomplete error:", error)
        this.hideResults()
      }
    }
  }

  renderResults(results) {
    const filteredResults = results.filter(r => !this.selectedItems.has(String(r.id)))

    if (filteredResults.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-olive-500 italic">
          No results found
        </div>
      `
    } else {
      this.resultsTarget.innerHTML = filteredResults.map((item, index) => `
        <button type="button"
                class="w-full px-4 py-2.5 text-left flex items-center justify-between hover:bg-olive-50 dark:hover:bg-olive-800 focus:bg-olive-50 dark:focus:bg-olive-800 focus:outline-none transition-colors ${index === this.highlightedIndex ? 'bg-olive-50 dark:bg-olive-800' : ''}"
                data-action="click->autocomplete#select"
                data-id="${item.id}"
                data-name="${this.escapeHtml(item.name)}"
                data-count="${item.count}"
                data-index="${index}">
          <span class="text-sm text-olive-900 dark:text-olive-100 truncate">${this.escapeHtml(item.name)}</span>
          <span class="text-xs text-olive-400 ml-2 shrink-0">${item.count}</span>
        </button>
      `).join("")
    }

    this.highlightedIndex = -1
    this.showResults()
  }

  renderSelected() {
    if (this.selectedItems.size === 0) {
      this.selectedTarget.innerHTML = ""
      this.selectedTarget.classList.add("hidden")
      return
    }

    this.selectedTarget.classList.remove("hidden")
    this.selectedTarget.innerHTML = Array.from(this.selectedItems.values()).map(item => `
      <span class="inline-flex items-center gap-1.5 px-2.5 py-1 bg-olive-100 dark:bg-olive-800 text-olive-700 dark:text-olive-200 text-sm rounded-full">
        <span class="truncate max-w-32">${this.escapeHtml(item.name)}</span>
        <button type="button"
                class="shrink-0 hover:text-olive-900 dark:hover:text-white transition-colors"
                data-action="click->autocomplete#remove"
                data-id="${item.id}"
                aria-label="Remove ${this.escapeHtml(item.name)}">
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </span>
    `).join("")

    this.hiddenInputsTarget.innerHTML = Array.from(this.selectedItems.values()).map(item => `
      <input type="hidden"
             name="q[${this.paramNameValue}][]"
             value="${item.id}"
             data-name="${this.escapeHtml(item.name)}"
             data-count="${item.count}">
    `).join("")
  }

  select(event) {
    event.preventDefault()
    const button = event.currentTarget
    const item = {
      id: button.dataset.id,
      name: button.dataset.name,
      count: button.dataset.count
    }

    this.selectedItems.set(item.id, item)
    this.renderSelected()
    this.inputTarget.value = ""
    this.hideResults()
    this.inputTarget.focus()

    this.announceToScreenReader(`${item.name} selected`)
  }

  remove(event) {
    event.preventDefault()
    const id = event.currentTarget.dataset.id
    const item = this.selectedItems.get(id)
    this.selectedItems.delete(id)
    this.renderSelected()

    if (item) {
      this.announceToScreenReader(`${item.name} removed`)
    }
  }

  handleKeydown(event) {
    const results = this.resultsTarget.querySelectorAll("button[data-index]")

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        if (!this.resultsTarget.classList.contains("hidden") && results.length > 0) {
          this.highlightedIndex = Math.min(this.highlightedIndex + 1, results.length - 1)
          this.updateHighlight(results)
        }
        break

      case "ArrowUp":
        event.preventDefault()
        if (!this.resultsTarget.classList.contains("hidden") && results.length > 0) {
          this.highlightedIndex = Math.max(this.highlightedIndex - 1, 0)
          this.updateHighlight(results)
        }
        break

      case "Enter":
        event.preventDefault()
        if (this.highlightedIndex >= 0 && results[this.highlightedIndex]) {
          results[this.highlightedIndex].click()
        }
        break

      case "Escape":
        this.hideResults()
        break
    }
  }

  updateHighlight(results) {
    results.forEach((button, index) => {
      if (index === this.highlightedIndex) {
        button.classList.add("bg-olive-50", "dark:bg-olive-800")
        button.scrollIntoView({ block: "nearest" })
      } else {
        button.classList.remove("bg-olive-50", "dark:bg-olive-800")
      }
    })
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.highlightedIndex = -1
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  announceToScreenReader(message) {
    let announcer = document.getElementById("autocomplete-announcer")
    if (!announcer) {
      announcer = document.createElement("div")
      announcer.id = "autocomplete-announcer"
      announcer.setAttribute("aria-live", "polite")
      announcer.setAttribute("aria-atomic", "true")
      announcer.className = "sr-only"
      document.body.appendChild(announcer)
    }
    announcer.textContent = message
  }
}
