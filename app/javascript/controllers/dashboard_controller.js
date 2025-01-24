import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dashboard-tabs", "listings", "offers"];

  connect() {
  }

  tab(event) {
    if (event.target.innerText === "Listings") {
      this.offersTarget.classList.add("d-none");
      this.listingsTarget.classList.remove("d-none");
    } else {
      this.listingsTarget.classList.add("d-none");
      this.offersTarget.classList.remove("d-none");
    }
  }
}
