import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "picker", "customInput", "status"]
  static values = { slug: String }

  showPicker() {
    this.displayTarget.classList.add("hidden")
    this.pickerTarget.classList.remove("hidden")
  }

  async updateModel(event) {
    const selected = event.target.value

    if (selected === "") {
      // Show custom input
      this.customInputTarget.classList.remove("hidden")
      this.customInputTarget.focus()
      this.customInputTarget.onkeydown = (e) => {
        if (e.key === "Enter") this.saveModel(this.customInputTarget.value.trim())
        if (e.key === "Escape") this.cancel()
      }
      return
    }

    await this.saveModel(selected)
  }

  async saveModel(model) {
    if (!model) return

    this.showStatus("Saving…", "text-yellow-500")

    try {
      const res = await fetch(`/api/agents/${this.slugValue}/model`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ model })
      })

      const data = await res.json()

      if (res.ok) {
        // Update display label
        const shortName = model.split("/").pop()
        this.displayTarget.querySelector("span").textContent = shortName
        this.showStatus("✓ Saved", "text-emerald-500")
        setTimeout(() => this.cancel(), 800)
      } else {
        this.showStatus(`Error: ${data.error || "failed"}`, "text-red-500")
      }
    } catch (err) {
      this.showStatus("Network error", "text-red-500")
    }
  }

  cancel() {
    this.pickerTarget.classList.add("hidden")
    this.customInputTarget.classList.add("hidden")
    this.statusTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
  }

  showStatus(msg, colorClass) {
    this.statusTarget.textContent = msg
    this.statusTarget.className = `text-xs mt-1 ${colorClass}`
    this.statusTarget.classList.remove("hidden")
  }
}
