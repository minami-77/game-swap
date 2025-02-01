import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dashboardTabs", "listings", "offers", "settings"];
  static values ={
    tab: String
  }

  connect() {
    // Initialize the first tab as active
    // if the default tab is set we make the default tab as active
    // if not we run code below

    if (this.tabValue == "Offers"){
      this.hideAllTabs();
      this.showTab(this.offersTarget);
      //put a highlight to offers tab
      //get the offers tab element and apply active class
      //remove active from other tabs
      this.dashboardTabsTargets.forEach(tab => {
        tab.classList.remove("active")
      })
      const offersTab = this.dashboardTabsTargets.find(tab => tab.innerText.trim() === "Offers");
      if (offersTab) {
        offersTab.classList.add("active");
      }

    }else{
      this.showTab(this.dashboardTabsTargets[0]);
    }

  }

  tab(event) {
    this.dashboardTabsTargets.forEach(tab => {
      tab.classList.remove("active")
    })
    event.currentTarget.classList.add("active")

    const tabName = event.currentTarget.innerText.trim();
    this.hideAllTabs();
    if (tabName === "My Games") {
      this.showTab(this.listingsTarget);
    } else if (tabName === "My Rentals") {
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
