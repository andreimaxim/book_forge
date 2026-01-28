import { Controller } from "@hotwired/stimulus"

// Copies text content to the clipboard and shows confirmation feedback.
export default class extends Controller {
  static targets = ["source", "button"]

  async copy() {
    const text = this.sourceTarget.textContent.trim()

    try {
      await navigator.clipboard.writeText(text)
      this.showCopied()
    } catch {
      // Fallback for environments where clipboard API is not available
      this.fallbackCopy(text)
    }
  }

  fallbackCopy(text) {
    const textarea = document.createElement("textarea")
    textarea.value = text
    textarea.style.position = "fixed"
    textarea.style.opacity = "0"
    document.body.appendChild(textarea)
    textarea.select()

    try {
      document.execCommand("copy")
      this.showCopied()
    } catch {
      // Silently fail
    } finally {
      document.body.removeChild(textarea)
    }
  }

  showCopied() {
    const button = this.buttonTarget
    const originalText = button.textContent

    button.textContent = "Copied!"
    button.classList.add("text-green-700", "border-green-300")

    setTimeout(() => {
      button.textContent = originalText
      button.classList.remove("text-green-700", "border-green-300")
    }, 2000)
  }
}
