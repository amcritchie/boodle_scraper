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

    // Store bound handler references for cleanup
    this.boundHandleSearchInput = (e) => this.performSearch(e.target.value)
    this.boundHandleClearClick = () => this.clearSearch()
    this.boundSortHandlers = new Map()

    // Add a small delay to ensure DOM is fully rendered
    this.initTimeout = setTimeout(() => {
      this.initializeCache()
      this.setupEventListeners()
      this.initializeState()
    }, 100)
  }

  disconnect() {
    // Clear the init timeout if it hasn't fired yet
    if (this.initTimeout) {
      clearTimeout(this.initTimeout)
      this.initTimeout = null
    }

    // Remove search input listener
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.removeEventListener('input', this.boundHandleSearchInput)
    }

    // Remove clear button listener
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.removeEventListener('click', this.boundHandleClearClick)
    }

    // Remove sort button listeners
    if (this.boundSortHandlers) {
      this.boundSortHandlers.forEach((handler, button) => {
        button.removeEventListener('click', handler)
      })
      this.boundSortHandlers.clear()
    }

    // Release cached data
    this.playerData = []
  }

  initializeCache() {
    this.playerData = []
    
    console.log("Has table body target:", this.hasTableBodyTarget)
    
    if (this.hasTableBodyTarget) {
      console.log("Table body target:", this.tableBodyTarget)
      const rows = this.tableBodyTarget.querySelectorAll('[data-search]')
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
      this.searchInputTarget.addEventListener('input', this.boundHandleSearchInput)
    }

    // Clear search functionality
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.addEventListener('click', this.boundHandleClearClick)
    }

    // Sort button functionality
    this.sortButtonTargets.forEach(button => {
      const handler = (e) => {
        const sortType = e.target.dataset.sort
        if (sortType && this.hasSortUrlValue) {
          this.updateSort(sortType)
        }
      }
      this.boundSortHandlers.set(button, handler)
      button.addEventListener('click', handler)
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
