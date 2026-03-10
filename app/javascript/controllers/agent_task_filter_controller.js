import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["stageFilter", "agentFilter", "tableBody"]

  filter() {
    const stage = this.hasStageFilterTarget ? this.stageFilterTarget.value : ""
    const agent = this.hasAgentFilterTarget ? this.agentFilterTarget.value : ""

    // Card-based filtering (Kanban board)
    const cards = this.element.querySelectorAll('[data-kanban-board-target="card"]')
    if (cards.length > 0) {
      cards.forEach(card => {
        const cardAgent = card.dataset.agent
        const agentMatch = !agent || cardAgent === agent
        card.style.display = agentMatch ? "" : "none"
      })
      return
    }

    // Table row filtering (fallback)
    if (!this.hasTableBodyTarget) return

    const rows = this.tableBodyTarget.querySelectorAll("tr[data-stage]")
    rows.forEach(row => {
      const rowStage = row.dataset.stage
      const rowAgent = row.dataset.agent

      const stageMatch = !stage || rowStage === stage
      const agentMatch = !agent || rowAgent === agent

      row.style.display = (stageMatch && agentMatch) ? "" : "none"
    })
  }
}
