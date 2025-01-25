class GamesController < ApplicationController
  def search
    query = params[:query].gsub(/[^a-z0-9]/i, '').downcase
    @games = Game.where("search_name LIKE ?", "%#{query}%")
    render json: @games.pluck(:name)
  end
end
