import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["board", "column", "dropZone", "card", "toastContainer", "columnCount"]
  static values = {
    transitionUrl: String,
    updateUrl: String,
    deleteUrl: String,
    contentDetailUrl: String
  }

  // Transition map: fromStage -> toStage -> transition name
  static TRANSITIONS = {
    idea:          { refined: "refine" },
    refined:       { video_created: "video_create" },
    video_created: { edited: "edit" },
    edited:        { queued: "queue", posted: "post" },
    queued:        { posted: "post" }
  }

  connect() {
    this.draggedCard = null
    this.wasDragging = false
  }

  // ─── Drag Events ──────────────────────────────────────────────

  dragStart(event) {
    this.draggedCard = event.currentTarget
    this.wasDragging = false
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.contentId)

    requestAnimationFrame(() => {
      this.draggedCard.classList.add("opacity-40", "scale-95")
    })
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  dragEnter(event) {
    event.preventDefault()
    const dropZone = event.currentTarget
    if (dropZone.dataset.contentKanbanTarget === "dropZone") {
      dropZone.classList.add("border-emerald-400", "bg-emerald-50", "dark:bg-emerald-900/20")
      dropZone.classList.remove("theme-border-primary")
    }
  }

  dragLeave(event) {
    const dropZone = event.currentTarget
    if (dropZone.dataset.contentKanbanTarget === "dropZone" && !dropZone.contains(event.relatedTarget)) {
      dropZone.classList.remove("border-emerald-400", "bg-emerald-50", "dark:bg-emerald-900/20")
      dropZone.classList.add("theme-border-primary")
    }
  }

  drop(event) {
    event.preventDefault()
    this.wasDragging = true

    const dropZone = event.currentTarget
    dropZone.classList.remove("border-emerald-400", "bg-emerald-50", "dark:bg-emerald-900/20")
    dropZone.classList.add("theme-border-primary")

    if (!this.draggedCard) return

    const newStage = dropZone.dataset.stage
    const oldStage = this.draggedCard.dataset.stage

    if (newStage === oldStage) {
      this.clearDropIndicators()
      dropZone.appendChild(this.draggedCard)
      const contentId = this.draggedCard.dataset.contentId
      fetch(`/api/contents/${contentId}/rank`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({})
      })
      .then(r => r.json())
      .then(data => { if (data.content) this.showToast("Moved to end", "success") })
      .catch(() => this.showToast("Failed to reorder", "error"))
      return
    }

    const indicator = dropZone.querySelector("[data-drop-indicator]")
    let afterCard  = null
    let beforeCard = null

    if (indicator) {
      const prev = indicator.previousElementSibling
      const next = indicator.nextElementSibling
      if (prev && prev.dataset.contentId) afterCard  = prev
      if (next && next.dataset.contentId) beforeCard = next
    }

    this.clearDropIndicators()

    const placeholder = dropZone.querySelector(".flex.items-center.justify-center")
    if (placeholder) placeholder.remove()

    const originalParent = this.draggedCard.parentElement
    if (beforeCard) {
      dropZone.insertBefore(this.draggedCard, beforeCard)
    } else {
      dropZone.appendChild(this.draggedCard)
    }
    this.draggedCard.dataset.stage = newStage

    this.addPlaceholderIfEmpty(originalParent)
    this.updateColumnCounts()

    const contentId = this.draggedCard.dataset.contentId
    const card      = this.draggedCard
    const stageLabel = newStage.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase())

    const rankBody = {}
    if (afterCard)  rankBody.after_id  = afterCard.dataset.contentId
    if (beforeCard) rankBody.before_id = beforeCard.dataset.contentId
    const hasPosition = afterCard || beforeCard

    this.persistTransition(contentId, oldStage, newStage, card, originalParent)
      .then(() => {
        if (hasPosition) {
          return fetch(`/api/contents/${contentId}/rank`, {
            method: "PATCH",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(rankBody)
          }).then(r => r.json()).then(data => {
            if (data.content) card.dataset.rank = data.content.rank
          })
        }
      })
      .then(() => this.showToast(`Content moved to ${stageLabel}`, "success"))
      .catch((err) => {
        this.revertCard(card, originalParent, oldStage, dropZone)
        this.showToast(`Failed to move content: ${err.message}`, "error")
      })
  }

  dragEnd(event) {
    if (this.draggedCard) {
      this.draggedCard.classList.remove("opacity-40", "scale-95")
    }
    this.dropZoneTargets.forEach(zone => {
      zone.classList.remove("border-emerald-400", "bg-emerald-50", "dark:bg-emerald-900/20")
      if (!zone.classList.contains("theme-border-primary")) {
        zone.classList.add("theme-border-primary")
      }
    })
    this.clearDropIndicators()
    this.draggedCard = null
  }

  // ─── Within-Column Rank Reorder ───────────────────────────────

  cardDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const targetCard = event.currentTarget
    if (!this.draggedCard || targetCard === this.draggedCard) return

    this.clearDropIndicators()

    const rect = targetCard.getBoundingClientRect()
    const midY = rect.top + rect.height / 2

    const indicator = document.createElement("div")
    indicator.className = "drop-indicator h-0.5 bg-emerald-400 rounded mx-1 pointer-events-none"
    indicator.dataset.dropIndicator = "true"

    if (event.clientY < midY) {
      targetCard.parentElement.insertBefore(indicator, targetCard)
    } else {
      targetCard.parentElement.insertBefore(indicator, targetCard.nextSibling)
    }
  }

  cardDrop(event) {
    event.preventDefault()
    this.wasDragging = true

    const targetCard = event.currentTarget
    if (!this.draggedCard) return

    const isSameColumn = targetCard.parentElement === this.draggedCard.parentElement

    if (!isSameColumn) {
      return
    }

    event.stopPropagation()

    const indicator = targetCard.parentElement.querySelector("[data-drop-indicator]")
    let beforeCard = null
    let afterCard = null

    if (indicator) {
      const prev = indicator.previousElementSibling
      const next = indicator.nextElementSibling
      if (prev && prev.dataset.contentId) afterCard = prev
      if (next && next.dataset.contentId && next !== this.draggedCard) beforeCard = next
    }

    this.clearDropIndicators()

    if (beforeCard) {
      targetCard.parentElement.insertBefore(this.draggedCard, beforeCard)
    } else {
      targetCard.parentElement.appendChild(this.draggedCard)
    }

    const contentId = this.draggedCard.dataset.contentId
    const body = {}
    if (afterCard) body.after_id = afterCard.dataset.contentId
    if (beforeCard) body.before_id = beforeCard.dataset.contentId

    fetch(`/api/contents/${contentId}/rank`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    })
    .then(r => r.json())
    .then(data => {
      if (data.content) {
        this.draggedCard.dataset.rank = data.content.rank
        this.showToast("Order updated", "success")
      }
    })
    .catch(() => {
      this.showToast("Failed to update order", "error")
      window.location.reload()
    })
  }

  clearDropIndicators() {
    document.querySelectorAll("[data-drop-indicator]").forEach(el => el.remove())
  }

  // ─── Card Click ───────────────────────────────────────────────

  cardClick(event) {
    if (this.wasDragging) {
      this.wasDragging = false
      return
    }
    const contentId = event.currentTarget.dataset.contentId
    const url = this.contentDetailUrlValue.replace(":id", contentId)
    window.location.href = url
  }

  // ─── Delete ──────────────────────────────────────────────────

  async deleteCard(event) {
    event.stopPropagation()
    const card = event.currentTarget.closest([data-content-kanban-target=card])
    if (!card) return

    if (!confirm("Are you sure you want to delete this content item?")) return

    const contentId = card.dataset.contentId
    const dropZone = card.parentElement

    card.remove()
    this.addPlaceholderIfEmpty(dropZone)
    this.updateColumnCounts()

    try {
      const url = this.deleteUrlValue.replace(":id", contentId)
      const response = await fetch(url, {
        method: "DELETE",
        headers: { "Content-Type": "application/json" }
      })
      if (!response.ok) throw new Error("Delete failed")
      this.showToast("Content deleted", "success")
    } catch (err) {
      this.showToast(`Failed to delete: ${err.message}`, "error")
      window.location.reload()
    }
  }

  // ─── API Persistence ─────────────────────────────────────────

  async persistTransition(contentId, fromStage, toStage, card, originalParent) {
    const transitions = this.constructor.TRANSITIONS
    const transitionName = transitions[fromStage] && transitions[fromStage][toStage]

    if (transitionName) {
      const url = this.transitionUrlValue.replace(":id", contentId)
      const response = await fetch(url, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ transition: transitionName })
      })
      if (!response.ok) {
        const data = await response.json().catch(() => ({}))
        throw new Error(data.error || "Transition failed")
      }
    } else {
      const url = this.updateUrlValue.replace(":id", contentId)
      const response = await fetch(url, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ content: { stage: toStage } })
      })
      if (!response.ok) {
        const data = await response.json().catch(() => ({}))
        throw new Error(data.error || "Update failed")
      }
    }
  }

  // ─── Revert ───────────────────────────────────────────────────

  revertCard(card, originalParent, oldStage, currentDropZone) {
    const placeholder = originalParent.querySelector(".flex.items-center.justify-center")
    if (placeholder) placeholder.remove()

    originalParent.appendChild(card)
    card.dataset.stage = oldStage

    this.addPlaceholderIfEmpty(currentDropZone)
    this.updateColumnCounts()

    card.classList.add("ring-2", "ring-red-500")
    setTimeout(() => card.classList.remove("ring-2", "ring-red-500"), 1500)
  }

  // ─── Column Counts ────────────────────────────────────────────

  updateColumnCounts() {
    this.columnCountTargets.forEach(badge => {
      const stage = badge.dataset.stage
      const dropZone = this.dropZoneTargets.find(z => z.dataset.stage === stage)
      if (dropZone) {
        const count = dropZone.querySelectorAll([data-content-kanban-target=card]).length
        badge.textContent = count
      }
    })
  }

  // ─── Placeholders ─────────────────────────────────────────────

  addPlaceholderIfEmpty(dropZone) {
    const cards = dropZone.querySelectorAll([data-content-kanban-target=card])
    if (cards.length === 0 && !dropZone.querySelector(".flex.items-center.justify-center")) {
      const placeholder = document.createElement("div")
      placeholder.className = "flex items-center justify-center h-24 text-xs theme-text-secondary"
      placeholder.textContent = "Drop items here"
      dropZone.appendChild(placeholder)
    }
  }


  // Generate Video
  async generateVideo(event) {
    event.stopPropagation()
    const btn = event.currentTarget
    const contentId = btn.dataset.contentId
    if (!contentId) return
    btn.disabled = true
    btn.textContent = 'Queuing...'
    try {
      const url = this.transitionUrlValue.replace(':id', contentId)
      const res = await fetch(url, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ transition: 'video_create' })
      })
      if (!res.ok) throw new Error('HTTP ' + res.status)
      window.location.reload()
    } catch (err) {
      console.error('[ContentKanban] generateVideo error:', err)
      btn.disabled = false
      btn.textContent = 'Generate Video'
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  // Toast Notifications ──────────────────────────────────────

  showToast(message, type = "success") {
    if (!this.hasToastContainerTarget) return

    const toast = document.createElement("div")
    toast.className = `px-4 py-3 rounded-lg shadow-lg text-sm font-medium transform translate-x-full transition-transform duration-300 ${
      type === "success"
        ? "bg-emerald-600 text-white"
        : "bg-red-600 text-white"
    }`
    toast.textContent = message

    this.toastContainerTarget.appendChild(toast)

    requestAnimationFrame(() => {
      toast.classList.remove("translate-x-full")
      toast.classList.add("translate-x-0")
    })

    setTimeout(() => {
      toast.classList.remove("translate-x-0")
      toast.classList.add("translate-x-full")
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}
