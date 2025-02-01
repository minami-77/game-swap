import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sort-listing"
export default class extends Controller {
  static targets = ["searchCard", "searchResultsContainer", "sortDropdownInput", "sortDropdown"];

  connect() {
    document.addEventListener("click", this.closeInput.bind(this));
  }

  closeInput(event) {
    if (event.target !== this.sortDropdownTarget && event.target !== this.sortDropdownInputTarget) {
      this.sortDropdownTarget.classList.add("d-none");
    }
  }

  openInput() {
    if (this.sortDropdownTarget.classList.contains("d-none")) {
      this.sortDropdownTarget.classList.remove("d-none");
    } else {
      this.sortDropdownTarget.classList.add("d-none");
    }
  }

  sort(event) {
    event.preventDefault();
    const selectedSortMethod = event.target.innerText.toLowerCase();
    const listings = this.searchCardTargets;
    switch (selectedSortMethod) {
      case "price (low to high)":
        this.#priceSort("lth", listings);
        break;
      case "price (high to low)":
        this.#priceSort("htl", listings);
        break;
      case "maximum rental period":
        this.#rentalPeriodSort(listings);
        break;
    }
    this.#updateListingsContainer(listings, this.searchResultsContainerTarget);
  }

  #updateListingsContainer(listings, container) {
    container.innerHTML = "";
    listings.forEach(listing => {
      container.append(listing);
    })
  }

  #priceSort(sortMethod, listings) {
    listings.sort((a, b) => {
      // .replace is needed because of how the price is displayed in the view with the rails method number_to_currency
      const aPrice = parseFloat(a.querySelector(".listing-price").innerText.replace(/[^\d.-]/g, ""));
      const bPrice = parseFloat(b.querySelector(".listing-price").innerText.replace(/[^\d.-]/g, ""));
      return sortMethod === "lth" ? this.#sortBy(aPrice, bPrice) : this.#sortBy(bPrice, aPrice);
    });
  }

  #rentalPeriodSort(listings) {
    listings.sort((b, a) => {
      const aMax = parseInt(a.querySelector(".rental-period").innerText);
      const bMax = parseInt(b.querySelector(".rental-period").innerText);
      console.log(aMax, bMax);

      return this.#sortBy(aMax, bMax)
    })
  }

  #sortBy(a, b) {
    if (a == b) {
      return 0;
    } else {
      return a < b ? -1 : 1;
    }
  }
}
