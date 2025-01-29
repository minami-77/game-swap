class ChatsController < ApplicationController
  def index
    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
    puts @chats
    puts 
  end
end
