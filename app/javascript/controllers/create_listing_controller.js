import { Controller } from "@hotwired/stimulus"
// import TomSelect from "tom-select";

export default class extends Controller {
  static targets = ["createListingForm", "gameNameInput", "platformInput", "platformDropdown"];

  connect() {
    this.gameNameInputTarget.addEventListener('input', this.fetchOptions.bind(this));
    // this.gameNameInputTarget.addEventListener('input', this.fetchPlatforms.bind(this));
    console.log(this.platformInputTarget);

  }

  async fetchOptions(event) {
    const query = event.target.value;
    if (query.length > 2) {
      // return; // Don't fetch if the query is too short
      const response = await fetch(`/games/search?query=${query}`);
      const games = await response.json();
      const datalist = document.getElementById('game-list');
      datalist.innerHTML = ''; // Clear existing options

      games.forEach(game => {
        const option = document.createElement('option');
        option.value = game;
        datalist.appendChild(option);
      });
    }

    const inDatalist = Array.from(this.platformDropdownTarget.options).some(option => option.value === query);
    if (inDatalist) {
      this.#retrievePlatforms(query);
    }
  }

  async #retrievePlatforms(query) {
    const response = await fetch(`/get_platforms?query=${query}`);
    const platformsObject = await response.json();
    this.#displayPlatformDropdown(platformsObject.platforms);
  }

  #displayPlatformDropdown(platforms) {
    this.platformInputTarget.innerHTML = "";
    platforms.forEach((platform) => {
      const option = document.createElement('option');
      option.value = platform;
      option.textContent = platform;
      this.platformInputTarget.appendChild(option);
    })
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
