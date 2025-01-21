class OffersController < ApplicationController

  def index
    @listing = Listing.find(params[:listing_id])
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
