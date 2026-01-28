import { Controller } from "@hotwired/stimulus"

// Auto-submits a filter form when any of its inputs change.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
