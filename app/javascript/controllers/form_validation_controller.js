import { Controller } from "@hotwired/stimulus"

// Client-side form validation before submit.
// Validates required fields and email format, showing inline error messages.
export default class extends Controller {
  static targets = ["field", "error"]

  validate(event) {
    let valid = true

    // Clear previous errors
    this.errorTargets.forEach(el => {
      el.classList.add("hidden")
      el.textContent = ""
    })

    this.fieldTargets.forEach(field => {
      const name = field.name
      const value = field.value.trim()
      const errorEl = this.errorTargets.find(e => e.dataset.field === name)

      if (!errorEl) return

      // Check required
      if (field.dataset.validationRequired === "true" && value === "") {
        errorEl.textContent = "is required"
        errorEl.classList.remove("hidden")
        valid = false
        return
      }

      // Check email format
      if (field.dataset.validationEmail === "true" && value !== "") {
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        if (!emailPattern.test(value)) {
          errorEl.textContent = "must be a valid email"
          errorEl.classList.remove("hidden")
          valid = false
        }
      }
    })

    if (!valid) {
      event.preventDefault()
    }
  }
}
