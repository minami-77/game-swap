class GamesController < ApplicationController
  def search
    query = params[:query].downcase
    @games = Game.where("search_name LIKE ?", "%#{query}%")
    render json: @games.pluck(:name)
  end
end
