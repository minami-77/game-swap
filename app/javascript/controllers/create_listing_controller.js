import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["createListingForm"];

  connect() {

  }

  renderForm() {
    const form = this.createListingFormTarget;
    if (form.classList.contains("d-none")) {
      form.classList.remove("d-none")
    } else {
      form.classList.add("d-none")
    }

  }
}
