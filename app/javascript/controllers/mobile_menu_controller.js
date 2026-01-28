import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    this.openIconTarget.classList.toggle("hidden")
    this.closeIconTarget.classList.toggle("hidden")

    const button = this.element.querySelector("[data-testid='mobile-menu-button']")
    const isExpanded = !this.menuTarget.classList.contains("hidden")
    button.setAttribute("aria-expanded", isExpanded.toString())
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")

    const button = this.element.querySelector("[data-testid='mobile-menu-button']")
    button.setAttribute("aria-expanded", "false")
  }
}
