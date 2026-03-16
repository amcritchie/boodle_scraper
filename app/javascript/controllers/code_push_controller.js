import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["btn", "label", "spinner", "status"]

  async push() {
    this.btnTarget.disabled = true
    this.labelTarget.textContent = "Pushing…"
    this.spinnerTarget.classList.remove("hidden")
    this.statusTarget.classList.add("hidden")

    try {
      const res = await fetch("/api/agents/push", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
      })
      const data = await res.json()

      this.spinnerTarget.classList.add("hidden")
      this.statusTarget.classList.remove("hidden")

      if (data.ok) {
        this.statusTarget.textContent = `✅ Pushed: ${data.triggered.join(", ")}`
        this.labelTarget.textContent = "🚀 Code Push"
      } else {
        const errMsg = data.errors?.map(e => `${e.agent}: ${e.error}`).join("; ") || "Unknown error"
        this.statusTarget.textContent = `⚠️ Partial: ${data.triggered.join(", ")} (errors: ${errMsg})`
        this.labelTarget.textContent = "🚀 Code Push"
      }

      setTimeout(() => {
        this.statusTarget.classList.add("hidden")
        this.btnTarget.disabled = false
      }, 5000)
    } catch (err) {
      console.error("[CodePush] Error:", err)
      this.spinnerTarget.classList.add("hidden")
      this.statusTarget.classList.remove("hidden")
      this.statusTarget.textContent = "❌ Push failed"
      this.labelTarget.textContent = "🚀 Code Push"
      this.btnTarget.disabled = false

      setTimeout(() => this.statusTarget.classList.add("hidden"), 5000)
    }
  }
}
