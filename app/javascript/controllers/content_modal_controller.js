import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "prompt", "caption", "script", "submitBtn"]
  static values = { createUrl: String }

  open() {
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    setTimeout(() => this.promptTarget.focus(), 50)
  }

  close() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    this.reset()
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.close()
  }

  keydown(event) {
    if (event.key === "Escape") this.close()
    if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
      event.preventDefault()
      this.submit()
    }
  }

  reset() {
    this.promptTarget.value = ""
    this.captionTarget.value = ""
    this.scriptTarget.value = ""
  }

  async submit() {
    const prompt = this.promptTarget.value.trim()
    if (!prompt) {
      this.promptTarget.focus()
      return
    }

    this.submitBtnTarget.disabled = true
    this.submitBtnTarget.textContent = "Saving..."

    try {
      const res = await fetch(this.createUrlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          content: {
            prompt,
            caption: this.captionTarget.value.trim(),
            script: this.scriptTarget.value.trim()
          }
        })
      })

      if (!res.ok) throw new Error(`HTTP ${res.status}`)

      // Reload the page so the new card appears at top of idea column
      this.close()
      window.location.reload()
    } catch (err) {
      console.error("[ContentModal] Error creating content:", err)
      this.submitBtnTarget.disabled = false
      this.submitBtnTarget.textContent = "Save Idea"
    }
  }
}
