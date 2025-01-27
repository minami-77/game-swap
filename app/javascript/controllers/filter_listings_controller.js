import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter-listings"
export default class extends Controller {
  static targets = ["submitForm"]

  connect() {
    this.submitFormTarget.addEventListener("submit", (event) => this.#submitForm(event));
  }

  #submitForm(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const query = formData.get("search[query]");

    const filterParams = this.#getFilterParams();
    const params = new URLSearchParams({ name: query, ...filterParams }).toString();
    window.location.href = `/listings?${params}`
  }

  #getFilterParams() {
    const filterObject = {};

    this.#platformCheckboxes(filterObject);
    return filterObject;
  }

  #platformCheckboxes(filterObject) {
    const platformCheckboxes = document.querySelectorAll(".platform-checkboxes");
    filterObject.platforms = [];
    platformCheckboxes.forEach((platformCheckbox) => {
      if (platformCheckbox.checked) {
        filterObject.platforms.push(platformCheckbox.name);
      }
    })
  }
}
