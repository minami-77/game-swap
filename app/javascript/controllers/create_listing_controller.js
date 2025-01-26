import { Controller } from "@hotwired/stimulus"
// import TomSelect from "tom-select";

export default class extends Controller {
  static targets = ["createListingForm", "gameNameInput"];

  connect() {
    this.gameNameInputTarget.addEventListener('input', this.fetchOptions.bind(this));
    //this.gameNameInputTarget.addEventListener('input', this.filterOptions.bind(this));
  }

  async fetchOptions(event) {
    const query = event.target.value;
    if (query.length < 2) {
      return; // Don't fetch if the query is too short
    }
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

  // filterOptions(event) {
  //   const input = event.target.value.toLowerCase();
  //   const datalist = document.getElementById('game-list');
  //   const options = Array.from(datalist.options);

  //   options.forEach(option => {
  //     if (option.value.toLowerCase().includes(input)) {
  //       option.style.display = 'block';
  //     } else {
  //       option.style.display = 'none';
  //     }
  //   });
  // }

  renderForm() {
    const form = this.createListingFormTarget;
    if (form.classList.contains("d-none")) {
      form.classList.remove("d-none")
    } else {
      form.classList.add("d-none")
    }

  }
}
