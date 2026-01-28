import { Controller } from "@hotwired/stimulus"

// Auto-saves form data after typing stops.
// Uses a debounce timer to avoid saving on every keystroke.
export default class extends Controller {
  static targets = ["field", "status"]
  static values = { url: String, delay: { type: Number, default: 1000 } }

  connect() {
    this.debounceTimer = null
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  changed() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    this.statusTarget.textContent = "Saving..."
    this.statusTarget.classList.remove("text-green-600")
    this.statusTarget.classList.add("text-gray-500")

    this.debounceTimer = setTimeout(() => {
      this.save()
    }, this.delayValue)
  }

  async save() {
    const content = this.fieldTarget.value
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken || ""
        },
        body: JSON.stringify({ content: content })
      })

      if (response.ok) {
        this.statusTarget.textContent = "Saved"
        this.statusTarget.classList.remove("text-gray-500")
        this.statusTarget.classList.add("text-green-600")
      } else {
        this.statusTarget.textContent = "Save failed"
        this.statusTarget.classList.remove("text-gray-500")
        this.statusTarget.classList.add("text-red-600")
      }
    } catch {
      this.statusTarget.textContent = "Save failed"
      this.statusTarget.classList.remove("text-gray-500")
      this.statusTarget.classList.add("text-red-600")
    }
  }
}
