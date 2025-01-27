import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter-listings"
export default class extends Controller {
  static targets = ["submitForm"]

  connect() {
    this.submitFormTarget.addEventListener("submit", this.#submitForm);
  }

  #submitForm(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const query = formData.get("search[query]");
    const filterParams = this.#getFilterParams();
    const params = new URLSearchParams({ name: query, ...filterParams }).toString();
    console.log(params);

    fetch(`/listings?${params}`, {
      method: "GET",
      headers: {
        'Content-Type': 'application/json',
      }
    }).catch(error => console.error('Error:', error));
  }

  #getFilterParams() {
    
  }
}
