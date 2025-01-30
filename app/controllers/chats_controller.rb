class ChatsController < ApplicationController
  def index
    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
      .order(last_message: :desc)
  end

  def get_messages
    id = params[:id]
    @messages = Chat.find(id).messages.order(created_at: :asc)
    message_partial = render_to_string(partial: "chats/messages", locals: { messages: @messages })
    render json: { messages: message_partial }
  end

  def new_message
    chat_id = params[:id]
    @chat = Chat.find(chat_id)
    new_message = @chat.messages.create!(
      message: params[:message],
      user: current_user
    )

    @chat.update(last_message: new_message.created_at)
    @messages = @chat.messages.order(created_at: :asc)

    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
      .order(last_message: :desc)

    message_partial = render_to_string(partial: "chats/messages", locals: { messages: @messages })
    chats_partial = render_to_string(partial: "chats/chats", locals: { chats: @chats })

    render json: { chats: chats_partial, messages: message_partial }
    # render partial: "chats/messages", locals: { chat: @messages }
  end

  def get_chats
    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
      .order(last_message: :desc)
    render partial: "chats/chats", locals: { chat: @chats }
  end
end
