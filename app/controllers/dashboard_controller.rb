class DashboardController < ApplicationController
  def index
    @listings = current_user.listings
    @offers = current_user.offers
  end

end
