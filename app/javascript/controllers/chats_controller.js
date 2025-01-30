import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chats"
export default class extends Controller {
  static targets = ["messageText", "messageForm", "messagesSection", "messages"]

  connect() {
  }

  async selectChat(event) {
    const chatId = event.currentTarget.dataset.id;
    const response = await fetch(`/get_messages?id=${chatId}`);
    this.renderPartial(response);
  }

  async newMessage(event, chatId) {
    event.preventDefault();
    const params = { id: chatId, message: this.messageTextTarget.value }
    const response = await fetch(`/new_message`, {
      method: "POST",
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify(params)
    });
    this.renderPartial(response);
  }

  async renderPartial(response) {
    const partial = await response.text();
    this.messagesSectionTarget.innerHTML = "";
    this.messagesSectionTarget.innerHTML = partial;
    this.messageFormTarget.addEventListener("submit", (event) => this.newMessage(event, chatId))
    this.scrollToLastMessage();
  }

  scrollToLastMessage() {
    const lastMessage = this.messagesTarget.lastElementChild;
    console.log(lastMessage);
    if (lastMessage) {
      lastMessage.scrollIntoView();
    }
  }
}
