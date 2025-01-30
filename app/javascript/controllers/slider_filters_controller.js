import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="distance-filter"
export default class extends Controller {
  static targets = ["priceSlider", "distanceSlider", "price", "distance"]

  connect() {
    this.changePricePosition();
    this.changeDistancePosition();
    this.priceSliderTarget.addEventListener("input", this.changePricePosition.bind(this));
    this.distanceSliderTarget.addEventListener("input", this.changeDistancePosition.bind(this));
  }

  changePricePosition() {
    this.priceTarget.style.left = `${this.priceSliderTarget.value * 4}%`;
    this.priceTarget.innerText = this.priceSliderTarget.value * 100;
  }

  changeDistancePosition() {
    this.distanceTarget.style.left = `${this.distanceSliderTarget.value}%`;
    this.distanceTarget.innerText = this.distanceSliderTarget.value;
  }
}
