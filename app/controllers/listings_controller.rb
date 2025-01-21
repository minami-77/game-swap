class ListingsController < ApplicationController
  def index
  end

  def show
    @game = Game.find(params[:id])
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
