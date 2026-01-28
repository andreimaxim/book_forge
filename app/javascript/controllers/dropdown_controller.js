import { Controller } from "@hotwired/stimulus"

// Dropdown menu controller.
// Opens on click, closes when clicking outside or pressing Escape.
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.boundClose = this.closeOnClickOutside.bind(this)
    this.boundEscape = this.closeOnEscape.bind(this)
    document.addEventListener("click", this.boundClose)
    document.addEventListener("keydown", this.boundEscape)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClose)
    document.removeEventListener("keydown", this.boundEscape)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
