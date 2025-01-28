class PlatformsController < ApplicationController
  def get_platforms
    game_name = params[:query].gsub(/[^a-z0-9]/i, '').downcase
    game = Game.where("search_name = ?", game_name)[0]
    platform_ids = JSON.parse(game.platforms)
    platforms = []
    platform_ids.each do |platform_id|
      platforms << Platform.find_by(platform_id: platform_id).name
    end
    render json: { platforms: platforms }
  end
end
