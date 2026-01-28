import { Controller } from "@hotwired/stimulus"

// Displays a live character count with warning when nearing the limit.
export default class extends Controller {
  static targets = ["input", "count"]
  static values = { max: { type: Number, default: 200 } }

  connect() {
    this.update()
  }

  update() {
    const current = this.inputTarget.value.length
    const max = this.maxValue
    const remaining = max - current

    this.countTarget.textContent = `${current} / ${max}`

    // Remove all state classes first
    this.countTarget.classList.remove("text-gray-500", "text-amber-600", "text-red-600")

    if (remaining <= 0) {
      this.countTarget.classList.add("text-red-600")
    } else if (remaining <= max * 0.1) {
      // Warning when within 10% of the limit
      this.countTarget.classList.add("text-amber-600")
    } else {
      this.countTarget.classList.add("text-gray-500")
    }
  }
}
