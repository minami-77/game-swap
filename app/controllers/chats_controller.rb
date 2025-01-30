class ChatsController < ApplicationController
  def index
    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
      .order(last_message: :desc)
  end

  def update_unread_messages_in_frontend
    @chats = Chat.where(first_user_id: current_user.id)
    .or(Chat.where(second_user_id: current_user.id))

    @unread_messages_count = 0
    @chats.each do |chat|
      @unread_messages_count += chat.messages.where.not(user: current_user).where(read: false).count
    end
    render json: { unread: @unread_messages_count }
  end

  def get_messages
    id = params[:id]
    @messages = Chat.find(id).messages.order(created_at: :asc)
    message_partial = render_to_string(partial: "chats/messages", locals: { messages: @messages })

    update_read(@messages)
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

  def refresh_messages
    chat_id = params[:id]
    @chat = Chat.find(chat_id)
    @message = @chat.messages.order(created_at: :asc).last

    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
      .order(last_message: :desc)

    message_partial = render_to_string(partial: "chats/new_message", locals: { messages: @message })
    chats_partial = render_to_string(partial: "chats/chats", locals: { chats: @chats })

    render json: { chats: chats_partial, messages: message_partial }
  end

  def get_chats
    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
      .order(last_message: :desc)
    render partial: "chats/chats", locals: { chat: @chats }
  end

  def update_read(messages)
    @other_user_messages = messages.where.not(user: current_user)
    @other_user_messages.update_all(read: true)
  end
end
