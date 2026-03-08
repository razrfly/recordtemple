import { Controller } from "@hotwired/stimulus"
import { getSearchValue } from "./search_param_utils"

export default class extends Controller {
  submit() {
    this.#syncSearchParam(this.element)
    this.element.requestSubmit()
  }

  #syncSearchParam(form) {
    form.querySelectorAll('[data-url-sync]').forEach(el => el.remove())
    const search = getSearchValue()
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
