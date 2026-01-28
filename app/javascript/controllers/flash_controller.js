import { Controller } from "@hotwired/stimulus"

// Flash message controller for dismissing flash notifications
export default class extends Controller {
  dismiss() {
    this.element.remove()
  }
}
