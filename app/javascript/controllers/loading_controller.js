import { Controller } from "@hotwired/stimulus"

// Loading state controller for buttons during form submission
export default class extends Controller {
  static targets = ["button"]

  start(event) {
    const button = this.buttonTarget

    // Store original text
    button.dataset.originalText = button.value || button.textContent

    // Update button to loading state
    if (button.tagName === "INPUT") {
      button.value = "Loading..."
    } else {
      button.textContent = "Loading..."
    }

    // Disable the button
    button.disabled = true
  }

  stop() {
    const button = this.buttonTarget

    // Restore original text
    if (button.tagName === "INPUT") {
      button.value = button.dataset.originalText
    } else {
      button.textContent = button.dataset.originalText
    }

    // Re-enable the button
    button.disabled = false
  }
}
