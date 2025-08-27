import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "clearButton", "tableBody", "sortButton"]
  static values = { 
    sortUrl: String       // Base URL for sorting
  }

  connect() {
    console.log("SearchableTable controller connected")
    console.log("Controller element:", this.element)
    console.log("Available targets:", this.targets)
    
    // Add a small delay to ensure DOM is fully rendered
    setTimeout(() => {
      this.initializeCache()
      this.setupEventListeners()
      this.initializeState()
    }, 100)
  }

  initializeCache() {
    this.playerData = []
    
    console.log("Has table body target:", this.hasTableBodyTarget)
    
    if (this.hasTableBodyTarget) {
      console.log("Table body target:", this.tableBodyTarget)
      const rows = this.tableBodyTarget.querySelectorAll('tr[data-search]')
      console.log(`Found ${rows.length} rows with data-search attributes`)
      
      rows.forEach((row, index) => {
        const searchText = row.dataset.search
        console.log(`Row ${index} search text:`, searchText)
        
        if (searchText) {
          this.playerData.push({
            index: index,
            row: row,
            searchText: searchText.toLowerCase()
          })
        }
      })
      
      console.log(`Cached ${this.playerData.length} rows for search`)
    } else {
      console.error('Table body target not found for caching')
      console.log("Available targets:", Object.keys(this.targets))
    }
  }

  setupEventListeners() {
    // Search functionality
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.addEventListener('input', (e) => {
        this.performSearch(e.target.value)
      })
    }

    // Clear search functionality
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.addEventListener('click', () => {
        this.clearSearch()
      })
    }

    // Sort button functionality
    this.sortButtonTargets.forEach(button => {
      button.addEventListener('click', (e) => {
        const sortType = e.target.dataset.sort
        if (sortType && this.hasSortUrlValue) {
          this.updateSort(sortType)
        }
      })
    })
  }

  initializeState() {
    // Initialize clear button visibility
    this.toggleClearButton()
    
    // Trigger initial search if there's a pre-filled value
    if (this.hasSearchInputTarget && this.searchInputTarget.value.trim().length > 0) {
      this.performSearch(this.searchInputTarget.value)
    }
    
    // Auto-focus search input
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.focus()
    }
  }

  performSearch(searchTerm) {
    const term = searchTerm.toLowerCase().trim()
    
    // Toggle clear button visibility
    this.toggleClearButton()
    
    // Only perform search if we have cached data
    if (this.playerData.length === 0) {
      console.warn('No data cached, skipping search')
      return
    }
    
    // Search through cached data
    this.playerData.forEach(item => {
      const shouldShow = term === '' || this.matchesSearchTerm(item, term)
      item.row.style.display = shouldShow ? '' : 'none'
    })
  }

  matchesSearchTerm(item, searchTerm) {
    // Check the cached search text for the term
    return item.searchText.includes(searchTerm)
  }

  clearSearch() {
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ''
      this.searchInputTarget.focus()
      this.performSearch('')
    }
  }

  toggleClearButton() {
    if (this.hasClearButtonTarget && this.hasSearchInputTarget) {
      const hasValue = this.searchInputTarget.value.trim().length > 0
      this.clearButtonTarget.style.display = hasValue ? 'flex' : 'none'
    }
  }

  updateSort(sortType) {
    if (this.hasSortUrlValue) {
      const currentUrl = new URL(window.location)
      currentUrl.searchParams.set('sort', sortType)
      window.location.href = currentUrl.toString()
    }
  }

  // Public method to refresh cache (useful after dynamic content updates)
  refreshCache() {
    this.initializeCache()
  }

  // Public method to get current search term
  getCurrentSearchTerm() {
    return this.hasSearchInputTarget ? this.searchInputTarget.value : ''
  }

  // Public method to set search term programmatically
  setSearchTerm(term) {
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = term
      this.performSearch(term)
    }
  }
}
