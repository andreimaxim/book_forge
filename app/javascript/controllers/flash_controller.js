import { Controller } from "@hotwired/stimulus"

// Flash message controller for dismissing flash notifications
export default class extends Controller {
  connect() {
    // Auto-dismiss after 4 seconds
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 4000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.remove()
  }
}
