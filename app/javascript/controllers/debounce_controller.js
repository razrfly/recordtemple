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
        form.requestSubmit()
      }
    }, this.waitValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
