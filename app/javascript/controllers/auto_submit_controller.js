import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    this.#syncSearchParam(this.element)
    this.element.requestSubmit()
  }

  #syncSearchParam(form) {
    form.querySelectorAll('[data-url-sync]').forEach(el => el.remove())
    const liveInput = document.querySelector('input[name="search"]')
    const search = (liveInput && liveInput.value.trim()) || new URLSearchParams(window.location.search).get('search')
    if (search) {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'search'
      input.value = search
      input.dataset.urlSync = 'true'
      form.appendChild(input)
    }
  }
}
