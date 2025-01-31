import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dashboardTabs", "listings", "offers", "settings"];

  connect() {
    // Initialize the first tab as active
    this.showTab(this.dashboardTabsTargets[0]);
  }

  tab(event) {
    this.dashboardTabsTargets.forEach(tab => {
      tab.classList.remove("active")
    })
    event.currentTarget.classList.add("active")

    const tabName = event.currentTarget.innerText.trim();
    this.hideAllTabs();
    if (tabName === "Listings") {
      this.showTab(this.listingsTarget);
    } else if (tabName === "Offers") {
      this.showTab(this.offersTarget);
    } else if (tabName === "Settings") {
      this.showTab(this.settingsTarget);
    }
  }

  showTab(target) {
    target.classList.remove("d-none");
  }

  hideAllTabs() {
    this.listingsTarget.classList.add("d-none");
    this.offersTarget.classList.add("d-none");
    this.settingsTarget.classList.add("d-none");
  }
}
