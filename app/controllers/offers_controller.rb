class OffersController < ApplicationController
  def for_listing
    @listing = Listing.find(params[:id])
    @offers = @listing.offers
  end

  def create
  end

  def destroy
  end

  def update
  end

  private

  def offer_params
  end
end
