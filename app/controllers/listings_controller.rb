class ListingsController < ApplicationController
  def index
  end

  def show
    @listing = Listing.find(params[:id])
    @offer = @listing.offers.new
  end

  def create
  end

  def destroy
  end

  def update
  end

  private

  def listing_params
  end
end
