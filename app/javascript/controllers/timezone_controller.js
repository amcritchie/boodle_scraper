import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["time"]
  static values = { 
    kickoff: String,
    timezone: { type: String, default: "America/New_York" }
  }

  connect() {
    this.convertTime()
  }

  convertTime() {
    if (!this.kickoffValue) return

    try {
      const serverTime = new Date(this.kickoffValue)
      const options = {
        weekday: 'long',
        hour: 'numeric',
        minute: '2-digit',
        month: 'long',
        day: 'numeric',
        year: 'numeric',
        timeZoneName: 'short',
        hour12: true
      }
      
      const localTimeString = serverTime.toLocaleString(undefined, options)
      this.timeTarget.textContent = localTimeString
    } catch (error) {
      console.error('Error parsing game time:', error)
    }
  }
}
