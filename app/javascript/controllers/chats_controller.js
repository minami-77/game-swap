import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chats"
export default class extends Controller {
  static targets = ["messageInput", "messageForm", "messagesSection", "messages", "chatsSidebar", "chats"]

  connect() {
    this.interval = setInterval(() => {
      this.refreshMessages();
    }, 1000);
  }

  async selectChat(event) {
    const activeChat = document.querySelector(".active");
    if (activeChat) {
      activeChat.classList.remove("active");
    }
    event.target.classList.add("active");
    const chatId = event.currentTarget.dataset.id;
    const response = await fetch(`/get_messages?id=${chatId}`);
    const data = await response.json();
    this.renderMessagesPartial(data.messages, chatId);
  }

  async refreshMessages() {
    const chatId = document.querySelector(".active").dataset.id;
    if (chatId) {
      const response = await fetch(`/get_messages?id=${chatId}`);
      const data = await response.json();
      this.renderMessagesPartial(data.messages, chatId);
    }
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
    this.messageInputTarget.select();
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

  disconnect() {
    clearInterval(this.interval);
  }
}
