import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter-listings"
export default class extends Controller {
  static targets = ["submitForm"]

  connect() {
    // Selects the input field upon page load
    // Has to be a query selector not a target because of the partial being rendered on 2 different pages and not the same controller
    document.querySelector(".search-input").select();
    this.submitFormTarget.addEventListener("submit", (event) => this.#submitForm(event));
  }

  #submitForm(event) {
    event.preventDefault();
    const query = document.querySelector(".search-input").value;

    const filterParams = this.#getFilterParams();
    const params = new URLSearchParams({ name: query, ...filterParams }).toString();

    window.location.href = `/listings?${params}`;
  }

  #getFilterParams() {
    const filterObject = {};
    filterObject.distance = document.querySelector(".distance-slider").value;
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
