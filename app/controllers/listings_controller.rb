class ListingsController < ApplicationController
  def index
  end

  def show
    @listing = Listing.find(params[:id])
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
