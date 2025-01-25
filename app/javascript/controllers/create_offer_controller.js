import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["createOfferForm"];

  connect() {
    console.log("hello from create_offer_controller")
  }

  renderForm() {
    const form = this.createOfferFormTarget;
    if (form.classList.contains("d-none")) {
      form.classList.remove("d-none")
    } else {
      form.classList.add("d-none")
    }
  }
}
