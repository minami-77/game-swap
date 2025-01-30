class ChatsController < ApplicationController
  def index
    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
    puts @chats
    puts
  end

  def get_messages
    id = params[:id]
    @messages = Chat.find(id).messages.order(created_at: :asc)
    render partial: "chats/messages", locals: { chat: @messages }
  end

  def new_message
    chat_id = params[:id]
    @chat = Chat.find(chat_id)
    new_message = @chat.messages.create!(
      message: params[:message],
      user: current_user
    )
    @chat.last_message = new_message.created_at
    @messages = @chat.messages.order(created_at: :asc)
    render partial: "chats/messages", locals: { chat: @messages }
  end
end
