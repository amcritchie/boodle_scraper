import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    refreshInterval: { type: Number, default: 30000 },
    url: { type: String, default: "/api/agents/dashboard" }
  }

  connect() {
    if (this.refreshIntervalValue > 0) {
      this.startRefreshing()
    }
  }

  disconnect() {
    this.stopRefreshing()
  }

  startRefreshing() {
    this.timer = setInterval(() => this.refresh(), this.refreshIntervalValue)
  }

  stopRefreshing() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  async refresh() {
    try {
      const response = await fetch(this.urlValue)
      if (response.ok) {
        const data = await response.json()
        this.dispatch("refreshed", { detail: data })
      }
    } catch (error) {
      console.warn("Dashboard refresh failed:", error)
    }
  }
}
