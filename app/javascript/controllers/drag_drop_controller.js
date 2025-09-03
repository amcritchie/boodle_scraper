import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tableBody"]
  
  connect() {
    this.setupDragAndDrop()
    this.setupCopyToClipboard()
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
      const newRank = index + 1
      
      // Update desktop rank number
      const rankNumber = row.querySelector('.rank-number')
      if (rankNumber) {
        rankNumber.textContent = newRank
      }
      
      // Update mobile rank number
      const mobileRank = row.querySelector('.md\\:hidden .bg-\\[\\#4BAF50\\]')
      if (mobileRank) {
        mobileRank.textContent = newRank
      }
      
      // Update data attribute
      row.setAttribute('data-original-rank', newRank)
      
      // Update copy button data attributes
      const copyButton = row.querySelector('.copy-team-logo')
      if (copyButton) {
        copyButton.setAttribute('data-rank', newRank)
        // Update tooltip
        const emoji = copyButton.getAttribute('data-emoji')
        const firstName = copyButton.getAttribute('data-first-name')
        const lastName = copyButton.getAttribute('data-last-name')
        copyButton.setAttribute('title', `Click to copy: ${newRank} ${emoji} ${firstName} ${lastName}`)
      }
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
  
  setupCopyToClipboard() {
    const copyButtons = this.element.querySelectorAll('.copy-team-logo')
    
    copyButtons.forEach(button => {
      button.addEventListener('click', this.handleCopyToClipboard.bind(this))
    })
  }
  
  handleCopyToClipboard(e) {
    e.preventDefault()
    e.stopPropagation()
    
    const button = e.currentTarget
    const rank = button.getAttribute('data-rank')
    const emoji = button.getAttribute('data-emoji')
    const firstName = button.getAttribute('data-first-name')
    const lastName = button.getAttribute('data-last-name')
    
    const textToCopy = `${rank} ${emoji} ${firstName} ${lastName}`
    
    // Copy to clipboard
    navigator.clipboard.writeText(textToCopy).then(() => {
      // Visual feedback
      const originalBg = button.style.backgroundColor
      const originalText = button.textContent
      
      button.style.backgroundColor = '#10B981' // Green
      button.textContent = '✓'
      
      setTimeout(() => {
        button.style.backgroundColor = originalBg
        button.textContent = originalText
      }, 1000)
      
      // Show toast notification
      this.showToast(`Copied: ${textToCopy}`)
    }).catch(err => {
      console.error('Failed to copy text: ', err)
      this.showToast('Failed to copy to clipboard')
    })
  }
  
  showToast(message) {
    // Create toast element
    const toast = document.createElement('div')
    toast.className = 'fixed top-4 right-4 bg-gray-800 text-white px-4 py-2 rounded-lg shadow-lg z-50 transition-all duration-300'
    toast.textContent = message
    
    document.body.appendChild(toast)
    
    // Animate in
    setTimeout(() => {
      toast.style.transform = 'translateX(0)'
      toast.style.opacity = '1'
    }, 100)
    
    // Remove after 3 seconds
    setTimeout(() => {
      toast.style.transform = 'translateX(100%)'
      toast.style.opacity = '0'
      setTimeout(() => {
        if (toast.parentNode) {
          toast.parentNode.removeChild(toast)
        }
      }, 300)
    }, 3000)
  }
}
