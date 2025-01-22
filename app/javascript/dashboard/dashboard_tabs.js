var dashboardTabs = document.querySelectorAll(".dashboard-tabs");
var dashboardListings = document.querySelector("div[data-display='listings']");
var dashboardOffers = document.querySelector("div[data-display='offers']");

dashboardTabs.forEach((button) => {
  button.addEventListener("click", changeDisplay);
});

function changeDisplay(event) {
  if (event.target.innerText === "Listings") {
    dashboardOffers.classList.add("d-none");
    dashboardListings.classList.remove("d-none");
  } else {
    dashboardListings.classList.add("d-none");
    dashboardOffers.classList.remove("d-none");
  }
}
