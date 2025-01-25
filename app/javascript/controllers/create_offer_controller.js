import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="create-offer"
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

  // fetch(listing_offers_path, {
  //   method: "POST",
  //   headers: {
  //     "Accept": "application/json"

  //   },
  //   body: {

  //   }
  // })
  // .then(response => response.json())
  // .then(data => {
  //   console.log(data);
  // })


}
