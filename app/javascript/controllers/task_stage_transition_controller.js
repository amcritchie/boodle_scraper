import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["stageLabel"]
  static values = {
    taskId: Number,
    currentStage: String
  }

  async transition(event) {
    const transitionName = event.target.dataset.transition
    if (!transitionName) return

    const button = event.target
    button.disabled = true
    button.textContent = "..."

    try {
      const response = await fetch(`/api/agents/tasks/${this.taskIdValue}/transition`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ transition: transitionName })
      })

      if (response.ok) {
        window.location.reload()
      } else {
        const data = await response.json()
        alert(data.error || "Transition failed")
        button.disabled = false
        button.textContent = transitionName.charAt(0).toUpperCase() + transitionName.slice(1)
      }
    } catch (error) {
      console.error("Transition error:", error)
      alert("Network error")
      button.disabled = false
      button.textContent = transitionName.charAt(0).toUpperCase() + transitionName.slice(1)
    }
  }
}
