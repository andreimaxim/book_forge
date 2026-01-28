import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Lock body scroll when modal is open
    document.body.style.overflow = "hidden"

    // Listen for escape key on the document
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    // Restore body scroll when modal is closed
    document.body.style.overflow = ""

    // Clean up the document-level event listener
    if (this.boundHandleKeydown) {
      document.removeEventListener("keydown", this.boundHandleKeydown)
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  close() {
    // Remove the modal by clearing the turbo frame content
    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.innerHTML = ""
    } else {
      this.element.remove()
    }
  }
}
