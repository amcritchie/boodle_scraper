import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "benchTable", "benchSearch", "benchPositionFilter", "benchGradeFilter", "benchCount",
    "benchContent", "substitutionModal", "selectedPlayerName", "selectedPlayerPosition", "positionDropdown",
    "offenseSubstitutionText", "defenseSubstitutionText", "benchToggleText"
  ]
  static values = {
    showOffenseSubstitution: { type: Boolean, default: false },
    showDefenseSubstitution: { type: Boolean, default: false },
    showBench: { type: Boolean, default: false },
    showSubstitutionModal: { type: Boolean, default: false }
  }

  connect() {
    this.selectedPlayerSlug = null
    this.selectedPlayerName = ''
    this.selectedPlayerPosition = ''
    this.selectedPosition = ''
    
    // Initialize bench player count
    this.filterBenchPlayers()
  }

  // Bench filtering methods
  filterBenchPlayers() {
    const searchTerm = this.benchSearchTarget.value.toLowerCase()
    const positionFilter = this.benchPositionFilterTarget.value
    const gradeFilter = this.benchGradeFilterTarget.value

    const rows = this.benchTableTarget.querySelectorAll('tbody tr[data-player-name]')
    let visibleCount = 0

    rows.forEach(row => {
      const playerName = row.getAttribute('data-player-name')
      const position = row.getAttribute('data-position')
      const grade = parseInt(row.getAttribute('data-grade'))

      const isVisible = this.benchPlayerVisible(playerName, position, grade, searchTerm, positionFilter, gradeFilter)
      
      if (isVisible) {
        row.style.display = ''
        visibleCount++
      } else {
        row.style.display = 'none'
      }
    })

    // Update count display
    if (this.hasBenchCountTarget) {
      this.benchCountTarget.textContent = `${visibleCount} players found`
    }
  }

  benchPlayerVisible(playerName, position, grade, searchTerm, positionFilter, gradeFilter) {
    // Search filter
    if (searchTerm && !playerName.includes(searchTerm)) {
      return false
    }
    
    // Position filter
    if (positionFilter && position !== positionFilter) {
      return false
    }
    
    // Grade filter
    if (gradeFilter && grade < parseInt(gradeFilter)) {
      return false
    }
    
    return true
  }

  // Substitution methods
  selectPlayerForSubstitution(event) {
    const playerSlug = event.currentTarget.getAttribute('data-player-slug')
    
    this.selectedPlayerSlug = playerSlug
    
    // Find player data from the row
    const row = event.currentTarget.closest('tr')
    const playerNameElement = row.querySelector('.text-sm')
    const positionElement = row.querySelector('td:nth-child(2) span')
    
    if (playerNameElement) {
      this.selectedPlayerNameTarget.textContent = playerNameElement.textContent.trim()
    }
    if (positionElement) {
      this.selectedPlayerPositionTarget.textContent = positionElement.textContent.trim()
    }
    
    // Reset position dropdown
    this.positionDropdownTarget.value = ''
    
    this.showSubstitutionModalValue = true
  }

  async confirmSubstitution() {
    const selectedPosition = this.positionDropdownTarget.value
    
    if (!selectedPosition) {
      alert('Please select a position to replace')
      return
    }
    
    if (!this.selectedPlayerSlug) {
      alert('No player selected')
      return
    }
    
    try {
      // Get the team slug from the URL
      const teamSlug = window.location.pathname.split('/').pop()
      
      const response = await fetch(`/teams/${teamSlug}/substitute`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({
          new_player_slug: this.selectedPlayerSlug,
          position: selectedPosition
        })
      })
      
      const result = await response.json()
      
      if (response.ok) {
        // Success - reload the page
        window.location.reload()
      } else {
        alert(`Error: ${result.error || 'Substitution failed'}`)
      }
    } catch (error) {
      console.error('Substitution error:', error)
      alert('An error occurred while making the substitution')
    }
    
    // Close modal
    this.showSubstitutionModalValue = false
  }

  closeSubstitutionModal() {
    this.showSubstitutionModalValue = false
  }

  // Toggle methods
  toggleOffenseSubstitution() {
    this.showOffenseSubstitutionValue = !this.showOffenseSubstitutionValue
    this.offenseSubstitutionTextTarget.textContent = this.showOffenseSubstitutionValue ? 'Cancel' : 'Substitute'
  }

  toggleDefenseSubstitution() {
    this.showDefenseSubstitutionValue = !this.showDefenseSubstitutionValue
    this.defenseSubstitutionTextTarget.textContent = this.showDefenseSubstitutionValue ? 'Cancel' : 'Substitute'
  }

  toggleBench() {
    this.showBenchValue = !this.showBenchValue
    this.benchToggleTextTarget.textContent = this.showBenchValue ? 'Hide Bench' : 'Show Bench'
    
    if (this.showBenchValue) {
      this.benchContentTarget.style.display = 'block'
      // Ensure minimum height is maintained
      this.benchContentTarget.style.minHeight = '400px'
      // Auto-focus the search field and scroll to center it
      setTimeout(() => {
        this.benchSearchTarget.focus()
        this.benchSearchTarget.scrollIntoView({ 
          behavior: 'smooth', 
          block: 'center',
          inline: 'center'
        })
      }, 100)
    } else {
      this.benchContentTarget.style.display = 'none'
    }
  }

  // Computed properties for modal visibility
  get showSubstitutionModalValue() {
    return !this.substitutionModalTarget.classList.contains('hidden')
  }

  set showSubstitutionModalValue(value) {
    if (value) {
      this.substitutionModalTarget.classList.remove('hidden')
    } else {
      this.substitutionModalTarget.classList.add('hidden')
    }
  }
} 