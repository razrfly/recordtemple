import { Controller } from "@hotwired/stimulus"

// Single-select autocomplete for form fields
// Usage:
//   <div data-controller="form-autocomplete"
//        data-form-autocomplete-url-value="/api/artists"
//        data-form-autocomplete-param-name-value="record[artist_id]">
//     <input type="hidden" name="record[artist_id]" data-form-autocomplete-target="hidden">
//     <input type="text" data-form-autocomplete-target="input" data-action="input->form-autocomplete#search focus->form-autocomplete#search">
//     <div data-form-autocomplete-target="results" class="hidden"></div>
//   </div>

export default class extends Controller {
  static targets = ["input", "results", "hidden"]
  static values = {
    url: String,
    minLength: { type: Number, default: 2 },
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.highlightedIndex = -1
    this.abortController = null
    this.debounceTimer = null

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
    if (results.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-olive-500 italic">
          No results found
        </div>
      `
    } else {
      // Build results using DOM APIs to prevent XSS
      this.resultsTarget.innerHTML = ""
      results.forEach((item, index) => {
        const button = document.createElement("button")
        button.type = "button"
        button.className = `w-full px-4 py-2.5 text-left flex items-center justify-between hover:bg-olive-50 focus:bg-olive-50 focus:outline-none transition-colors ${index === this.highlightedIndex ? 'bg-olive-50' : ''}`
        button.dataset.action = "click->form-autocomplete#select"
        button.dataset.id = item.id
        button.dataset.name = item.name
        button.dataset.index = index

        const nameSpan = document.createElement("span")
        nameSpan.className = "text-sm text-olive-900 truncate"
        nameSpan.textContent = item.name
        button.appendChild(nameSpan)

        if (item.count) {
          const countSpan = document.createElement("span")
          countSpan.className = "text-xs text-olive-400 ml-2 shrink-0"
          countSpan.textContent = `${item.count} records`
          button.appendChild(countSpan)
        }

        this.resultsTarget.appendChild(button)
      })
    }

    this.highlightedIndex = -1
    this.showResults()
  }

  select(event) {
    event.preventDefault()
    const button = event.currentTarget
    const id = button.dataset.id
    const name = button.dataset.name

    this.hiddenTarget.value = id
    this.inputTarget.value = name
    this.hideResults()
    this.inputTarget.focus()
  }

  clear() {
    this.hiddenTarget.value = ""
    this.inputTarget.value = ""
    this.inputTarget.focus()
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
        // Only prevent default and select when dropdown is active with a highlighted item
        if (this.highlightedIndex >= 0 && results[this.highlightedIndex]) {
          event.preventDefault()
          results[this.highlightedIndex].click()
        }
        // Otherwise, allow Enter to bubble for form submission
        break

      case "Escape":
        this.hideResults()
        break
    }
  }

  updateHighlight(results) {
    results.forEach((button, index) => {
      if (index === this.highlightedIndex) {
        button.classList.add("bg-olive-50")
        button.scrollIntoView({ block: "nearest" })
      } else {
        button.classList.remove("bg-olive-50")
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
}
