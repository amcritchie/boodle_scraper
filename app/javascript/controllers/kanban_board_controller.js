import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["board", "column", "dropZone", "card", "toastContainer", "columnCount"]
  static values = {
    transitionUrl: String,
    updateUrl: String,
    taskDetailUrl: String
  }

  // Transition map: fromStage -> toStage -> transition name (for /transition endpoint)
  static TRANSITIONS = {
    new:          { queued: "queue", in_progress: "start", archived: "archive" },
    queued:       { in_progress: "start", archived: "archive" },
    in_progress:  { done: "complete", failed: "fail", archived: "archive" },
    done:         { archived: "archive" },
    failed:       { archived: "archive" }
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
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.taskId)

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
    if (dropZone.dataset.kanbanBoardTarget === "dropZone") {
      dropZone.classList.add("border-emerald-400", "bg-emerald-50", "dark:bg-emerald-900/20")
      dropZone.classList.remove("theme-border-primary")
    }
  }

  dragLeave(event) {
    const dropZone = event.currentTarget
    if (dropZone.dataset.kanbanBoardTarget === "dropZone" && !dropZone.contains(event.relatedTarget)) {
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

    if (newStage === oldStage) return

    // Remove "Drop tasks here" placeholder if present
    const placeholder = dropZone.querySelector(".flex.items-center.justify-center")
    if (placeholder) placeholder.remove()

    // Optimistic move
    const originalParent = this.draggedCard.parentElement
    dropZone.appendChild(this.draggedCard)
    this.draggedCard.dataset.stage = newStage

    // Add "Drop tasks here" back to source if now empty
    this.addPlaceholderIfEmpty(originalParent)

    this.updateColumnCounts()

    const taskId = this.draggedCard.dataset.taskId
    const card = this.draggedCard
    const stageLabel = newStage.replace("_", " ").replace(/\b\w/g, c => c.toUpperCase())

    this.persistTransition(taskId, oldStage, newStage, card, originalParent)
      .then(() => {
        this.showToast(`Task moved to ${stageLabel}`, "success")
      })
      .catch((err) => {
        // Revert on failure
        this.revertCard(card, originalParent, oldStage, dropZone)
        this.showToast(`Failed to move task: ${err.message}`, "error")
      })
  }

  dragEnd(event) {
    if (this.draggedCard) {
      this.draggedCard.classList.remove("opacity-40", "scale-95")
    }
    // Clean up all drop zone highlights
    this.dropZoneTargets.forEach(zone => {
      zone.classList.remove("border-emerald-400", "bg-emerald-50", "dark:bg-emerald-900/20")
      if (!zone.classList.contains("theme-border-primary")) {
        zone.classList.add("theme-border-primary")
      }
    })
    this.draggedCard = null
  }

  // ─── Card Click ───────────────────────────────────────────────

  cardClick(event) {
    // Don't navigate if we just finished a drag
    if (this.wasDragging) {
      this.wasDragging = false
      return
    }
    const taskId = event.currentTarget.dataset.taskId
    const url = this.taskDetailUrlValue.replace(":id", taskId)
    window.location.href = url
  }

  // ─── API Persistence ─────────────────────────────────────────

  async persistTransition(taskId, fromStage, toStage, card, originalParent) {
    const transitions = this.constructor.TRANSITIONS
    const transitionName = transitions[fromStage] && transitions[fromStage][toStage]

    if (transitionName) {
      // Use named transition endpoint (sets timestamps)
      const url = this.transitionUrlValue.replace(":id", taskId)
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
      // Fall back to general update endpoint (backward moves, etc.)
      const url = this.updateUrlValue.replace(":id", taskId)
      const response = await fetch(url, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ task: { stage: toStage } })
      })
      if (!response.ok) {
        const data = await response.json().catch(() => ({}))
        throw new Error(data.error || "Update failed")
      }
    }
  }

  // ─── Revert ───────────────────────────────────────────────────

  revertCard(card, originalParent, oldStage, currentDropZone) {
    // Remove placeholder from original if present
    const placeholder = originalParent.querySelector(".flex.items-center.justify-center")
    if (placeholder) placeholder.remove()

    originalParent.appendChild(card)
    card.dataset.stage = oldStage

    // Add placeholder to current drop zone if now empty
    this.addPlaceholderIfEmpty(currentDropZone)

    this.updateColumnCounts()

    // Flash red ring
    card.classList.add("ring-2", "ring-red-500")
    setTimeout(() => card.classList.remove("ring-2", "ring-red-500"), 1500)
  }

  // ─── Column Counts ────────────────────────────────────────────

  updateColumnCounts() {
    this.columnCountTargets.forEach(badge => {
      const stage = badge.dataset.stage
      const dropZone = this.dropZoneTargets.find(z => z.dataset.stage === stage)
      if (dropZone) {
        const count = dropZone.querySelectorAll('[data-kanban-board-target="card"]').length
        badge.textContent = count
      }
    })
  }

  // ─── Placeholders ─────────────────────────────────────────────

  addPlaceholderIfEmpty(dropZone) {
    const cards = dropZone.querySelectorAll('[data-kanban-board-target="card"]')
    if (cards.length === 0 && !dropZone.querySelector(".flex.items-center.justify-center")) {
      const placeholder = document.createElement("div")
      placeholder.className = "flex items-center justify-center h-24 text-xs theme-text-secondary"
      placeholder.textContent = "Drop tasks here"
      dropZone.appendChild(placeholder)
    }
  }

  // ─── Toast Notifications ──────────────────────────────────────

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

    // Slide in
    requestAnimationFrame(() => {
      toast.classList.remove("translate-x-full")
      toast.classList.add("translate-x-0")
    })

    // Remove after 3s
    setTimeout(() => {
      toast.classList.remove("translate-x-0")
      toast.classList.add("translate-x-full")
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }

  // ─── Archive Task ────────────────────────────────────────────

  async archiveTask(event) {
    event.stopPropagation()
    const card = event.currentTarget.closest('[data-kanban-board-target="card"]')
    const taskId = card?.dataset.taskId
    if (!taskId) return

    const url = this.transitionUrlValue.replace(":id", taskId)
    try {
      const response = await fetch(url, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ transition: "archive" })
      })
      if (!response.ok) {
        const data = await response.json().catch(() => ({}))
        throw new Error(data.error || "Archive failed")
      }

      const dropZone = card.closest('[data-kanban-board-target="dropZone"]')
      card.remove()
      if (dropZone) this.addPlaceholderIfEmpty(dropZone)
      this.updateColumnCounts()
      this.showToast("Task archived", "success")
    } catch (err) {
      this.showToast(`Failed to archive: ${err.message}`, "error")
    }
  }

  // ─── Delete Task ─────────────────────────────────────────────

  async deleteTask(event) {
    event.stopPropagation()
    const card = event.currentTarget.closest('[data-kanban-board-target="card"]')
    const taskId = card?.dataset.taskId
    if (!taskId) return

    if (!confirm("Delete this task?")) return

    const url = `/api/agents/tasks/${taskId}`
    try {
      const response = await fetch(url, { method: "DELETE" })
      if (!response.ok) {
        const data = await response.json().catch(() => ({}))
        throw new Error(data.error || "Delete failed")
      }

      const dropZone = card.closest('[data-kanban-board-target="dropZone"]')
      card.remove()
      if (dropZone) this.addPlaceholderIfEmpty(dropZone)
      this.updateColumnCounts()
      this.showToast("Task deleted", "success")
    } catch (err) {
      this.showToast(`Failed to delete: ${err.message}`, "error")
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
