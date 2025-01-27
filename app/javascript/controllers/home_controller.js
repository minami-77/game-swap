import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {
  static targets = [ "controls" ]
  connect() {
    console.log("Hello, Stimulus!")
  }

  show() {
    this.element.classList.add('hovered')
  }

  hide() {
    this.element.classList.remove('hovered')
  }
}
