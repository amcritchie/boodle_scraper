import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "benchTable", "benchSearch", "benchPositionFilter", "benchGradeFilter", "benchCount",
    "benchContent", "substitutionModal", "selectedPlayerName", "selectedPlayerPosition", "selectedPosition",
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
    const position = event.currentTarget.getAttribute('data-position')
    
    this.selectedPlayerSlug = playerSlug
    this.selectedPosition = position
    
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
    
    this.selectedPositionTarget.textContent = position || 'Any Position'
    this.showSubstitutionModalValue = true
  }

  confirmSubstitution() {
    // Here you would make an AJAX call to update the substitution
    console.log('Substituting', this.selectedPlayerSlug, 'for position', this.selectedPosition)
    
    // Close modal
    this.showSubstitutionModalValue = false
    
    // You could reload the page or update the UI dynamically
    // window.location.reload()
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