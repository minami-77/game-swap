import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chats"
export default class extends Controller {
  static targets = ["messageText", "messageForm", "messagesSection"]

  connect() {
  }

  selectChat() {
    

  }
}
