import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tableBody"]
  
  connect() {
    this.setupDragAndDrop()
  }
  
  setupDragAndDrop() {
    const rows = this.element.querySelectorAll('.draggable-row')
    
    rows.forEach(row => {
      row.addEventListener('dragstart', this.handleDragStart.bind(this))
      row.addEventListener('dragover', this.handleDragOver.bind(this))
      row.addEventListener('drop', this.handleDrop.bind(this))
      row.addEventListener('dragend', this.handleDragEnd.bind(this))
      row.addEventListener('dragenter', this.handleDragEnter.bind(this))
      row.addEventListener('dragleave', this.handleDragLeave.bind(this))
      
      // Make drag handle more prominent on hover
      const dragHandle = row.querySelector('.drag-handle')
      if (dragHandle) {
        row.addEventListener('mouseenter', () => {
          dragHandle.classList.add('text-gray-600', 'dark:text-gray-300')
        })
        row.addEventListener('mouseleave', () => {
          dragHandle.classList.remove('text-gray-600', 'dark:text-gray-300')
        })
      }
    })
  }
  
  handleDragStart(e) {
    this.draggedRow = e.target
    this.draggedRow.classList.add('opacity-50', 'bg-blue-100', 'dark:bg-blue-900')
    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('text/html', e.target.outerHTML)
  }
  
  handleDragOver(e) {
    e.preventDefault()
    e.dataTransfer.dropEffect = 'move'
  }
  
  handleDragEnter(e) {
    e.preventDefault()
    if (e.target.closest('.draggable-row') && e.target.closest('.draggable-row') !== this.draggedRow) {
      e.target.closest('.draggable-row').classList.add('border-t-2', 'border-blue-500', 'bg-blue-50', 'dark:bg-blue-900')
    }
  }
  
  handleDragLeave(e) {
    if (e.target.closest('.draggable-row') && e.target.closest('.draggable-row') !== this.draggedRow) {
      e.target.closest('.draggable-row').classList.remove('border-t-2', 'border-blue-500', 'bg-blue-50', 'dark:bg-blue-900')
    }
  }
  
  handleDrop(e) {
    e.preventDefault()
    
    const dropTarget = e.target.closest('.draggable-row')
    if (!dropTarget || dropTarget === this.draggedRow) return
    
    // Remove visual feedback
    dropTarget.classList.remove('border-t-2', 'border-blue-500', 'bg-blue-50', 'dark:bg-blue-900')
    
    // Get the table body
    const tableBody = this.element.querySelector('tbody')
    
    // Determine if we're dropping above or below the target
    const rect = dropTarget.getBoundingClientRect()
    const dropY = e.clientY
    const targetY = rect.top + rect.height / 2
    
    if (dropY < targetY) {
      // Insert above
      tableBody.insertBefore(this.draggedRow, dropTarget)
    } else {
      // Insert below
      tableBody.insertBefore(this.draggedRow, dropTarget.nextSibling)
    }
    
    // Update rank numbers
    this.updateRankNumbers()
    
    // Add a subtle animation to show the change
    this.draggedRow.classList.add('animate-pulse')
    setTimeout(() => {
      this.draggedRow.classList.remove('animate-pulse')
    }, 500)
  }
  
  handleDragEnd(e) {
    // Clean up visual feedback
    this.draggedRow.classList.remove('opacity-50', 'bg-blue-100', 'dark:bg-blue-900')
    
    // Remove any remaining drop indicators
    const rows = this.element.querySelectorAll('.draggable-row')
    rows.forEach(row => {
      row.classList.remove('border-t-2', 'border-blue-500', 'bg-blue-50', 'dark:bg-blue-900')
    })
    
    this.draggedRow = null
  }
  
  updateRankNumbers() {
    const rows = this.element.querySelectorAll('.draggable-row')
    
    rows.forEach((row, index) => {
      // Update desktop rank number
      const rankNumber = row.querySelector('.rank-number')
      if (rankNumber) {
        rankNumber.textContent = index + 1
      }
      
      // Update mobile rank number
      const mobileRank = row.querySelector('.md\\:hidden .bg-\\[\\#4BAF50\\]')
      if (mobileRank) {
        mobileRank.textContent = index + 1
      }
      
      // Update data attribute
      row.setAttribute('data-original-rank', index + 1)
    })
  }
  
  // Method to get current ranking order (for potential future use)
  getCurrentRanking() {
    const rows = this.element.querySelectorAll('.draggable-row')
    return Array.from(rows).map(row => ({
      playerId: row.getAttribute('data-player-id'),
      rank: parseInt(row.getAttribute('data-original-rank'))
    }))
  }
}
