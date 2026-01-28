import { Controller } from "@hotwired/stimulus"

// Toast notification controller.
// Shows temporary notifications that auto-dismiss after a timeout.
export default class extends Controller {
  static targets = ["container"]
  static values = { duration: { type: Number, default: 3000 } }

  show(event) {
    const message = event.currentTarget.dataset.toastMessage || "Notification"

    const toast = document.createElement("div")
    toast.setAttribute("data-testid", "toast")
    toast.className = "flex items-center gap-3 px-4 py-3 rounded-lg border shadow-sm bg-green-50 border-green-200 text-green-800 transition-opacity duration-300"
    toast.innerHTML = `
      <span class="flex-1">${message}</span>
      <button type="button"
              data-testid="toast-dismiss"
              class="flex-shrink-0 p-1 rounded hover:bg-black/10 transition-colors"
              aria-label="Dismiss">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    `

    // Wire up the dismiss button
    const dismissBtn = toast.querySelector("[data-testid='toast-dismiss']")
    dismissBtn.addEventListener("click", () => this.dismiss(toast))

    this.containerTarget.appendChild(toast)

    // Auto-dismiss
    setTimeout(() => {
      this.dismiss(toast)
    }, this.durationValue)
  }

  dismiss(toast) {
    if (!toast || !toast.parentNode) return

    toast.style.opacity = "0"
    setTimeout(() => {
      toast.remove()
    }, 300)
  }
}
