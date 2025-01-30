import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chats"
export default class extends Controller {
  static targets = ["messageInput", "messageForm", "messagesSection", "messages", "chatsSidebar", "chats"]

  connect() {
  }

  async selectChat(event) {
    const chatId = event.currentTarget.dataset.id;
    const response = await fetch(`/get_messages?id=${chatId}`);
    const data = await response.json();
    this.renderMessagesPartial(data.messages, chatId);
  }

  async newMessage(event, chatId) {
    event.preventDefault();
    const params = { id: chatId, message: this.messageInputTarget.value }
    const response = await fetch(`/new_message`, {
      method: "POST",
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify(params)
    });
    const data = await response.json();
    this.renderMessagesPartial(data.messages, chatId);
    this.renderChatsPartial(data.chats, chatId);
  }

  async renderMessagesPartial(data, chatId) {
    this.messagesSectionTarget.innerHTML = data;
    this.messageFormTarget.addEventListener("submit", (event) => this.newMessage(event, chatId))
    this.scrollToLastMessage();
  }

  async renderChatsPartial(data) {
    this.chatsSidebarTarget.innerHTML = data;
  }

  scrollToLastMessage() {
    const lastMessage = this.messagesTarget.lastElementChild;
    if (lastMessage) {
      lastMessage.scrollIntoView();
    }
  }
}
