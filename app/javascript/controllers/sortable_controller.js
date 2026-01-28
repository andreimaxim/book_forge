import { Controller } from "@hotwired/stimulus"

// Drag-and-drop reordering for list items.
// Each list item needs draggable="true" and the appropriate data-action bindings.
export default class extends Controller {
  static targets = ["list"]
  static values = { url: String }

  dragstart(event) {
    this.draggedItem = event.currentTarget
    this.draggedItem.classList.add("opacity-50")
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", "")
  }

  dragover(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const target = event.currentTarget
    if (target === this.draggedItem) return

    const list = this.listTarget
    const items = [...list.children]
    const draggedIndex = items.indexOf(this.draggedItem)
    const targetIndex = items.indexOf(target)

    if (draggedIndex < targetIndex) {
      list.insertBefore(this.draggedItem, target.nextSibling)
    } else {
      list.insertBefore(this.draggedItem, target)
    }
  }

  dragend() {
    if (this.draggedItem) {
      this.draggedItem.classList.remove("opacity-50")
      this.draggedItem = null
    }
    this.saveOrder()
  }

  drop(event) {
    event.preventDefault()
  }

  async saveOrder() {
    if (!this.hasUrlValue || this.urlValue === "") return

    const items = [...this.listTarget.children]
    const order = items.map((item, index) => ({
      id: item.dataset.sortableId,
      position: index
    }))

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken || ""
        },
        body: JSON.stringify({ order: order })
      })
    } catch {
      // Silently fail
    }
  }
}
