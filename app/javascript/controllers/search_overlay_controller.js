import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "input", "results"]
  static values = { url: String }

  connect() {
    this.debounceTimer = null
    this.boundKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  handleKeydown(event) {
    // Cmd+K or Ctrl+K to open search
    if ((event.metaKey || event.ctrlKey) && event.key === "k") {
      event.preventDefault()
      this.open()
      return
    }

    // Escape to close search when overlay is visible
    if (event.key === "Escape" && !this.overlayTarget.classList.contains("hidden")) {
      event.preventDefault()
      this.close()
    }
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    // Focus the input after a brief delay for the modal to render
    requestAnimationFrame(() => {
      this.inputTarget.focus()
      this.inputTarget.select()
    })
  }

  close() {
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    this.inputTarget.value = ""
    this.resultsTarget.innerHTML = '<div class="px-4 py-6 text-center text-sm text-gray-500">Start typing to search...</div>'
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    if (query.length === 0) {
      this.resultsTarget.innerHTML = '<div class="px-4 py-6 text-center text-sm text-gray-500">Start typing to search...</div>'
      return
    }

    if (query.length < 2) {
      return
    }

    this.debounceTimer = setTimeout(() => {
      this.performSearch(query)
    }, 200)
  }

  async performSearch(query) {
    const url = `${this.urlValue}?q=${encodeURIComponent(query)}`

    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const html = await response.text()
        // Process the turbo stream response manually
        const template = document.createElement("template")
        template.innerHTML = html

        // Extract the content from the turbo-stream tag
        const turboStream = template.content.querySelector("turbo-stream")
        if (turboStream) {
          const templateContent = turboStream.querySelector("template")
          if (templateContent) {
            this.resultsTarget.innerHTML = templateContent.innerHTML
          }
        }
      }
    } catch (error) {
      // Silently fail on network errors
    }
  }

  navigateToResult(event) {
    if (event.key === "Enter") {
      const link = event.currentTarget
      if (link.href) {
        this.close()
        window.location.href = link.href
      }
    }
  }
}
