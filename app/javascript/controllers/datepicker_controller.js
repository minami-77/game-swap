import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr";

// Connects to data-controller="datepicker"
export default class extends Controller {
  connect() {
    const today = new Date();
    today.setHours(0, 0, 0, 0)

    flatpickr(this.element, {
      dateFormat: "Y-m-d",
      "disable": [
        function(date) {
          // return true to disable
          return date.getTime() < today.getTime();
        }
      ]
    });
  }
}
