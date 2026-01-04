import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon", "content", "moreContent", "showMoreBtn"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
    this.iconTarget.classList.toggle("rotate-180")
  }

  showMore() {
    this.moreContentTarget.classList.remove("hidden")
    this.showMoreBtnTarget.classList.add("hidden")
  }
}
