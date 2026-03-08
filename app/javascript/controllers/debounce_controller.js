import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    wait: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
  }

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const form = this.element.closest("form")
      if (form) {
        this.#syncFilterParams(form)
        form.requestSubmit()
      }
    }, this.waitValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  #syncFilterParams(form) {
    form.querySelectorAll('[data-url-sync]').forEach(el => el.remove())
    const transientParams = new Set(['search', 'page', 'per_page', 'sort', 'direction', 'cursor'])
    const params = new URLSearchParams(window.location.search)
    for (const [key, value] of params) {
      if (transientParams.has(key)) continue
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = key
      input.value = value
      input.dataset.urlSync = 'true'
      form.appendChild(input)
    }
  }
}
