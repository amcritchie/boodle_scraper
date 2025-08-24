import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "icon"]
  static values = { 
    theme: String,
    systemPreference: Boolean 
  }

  connect() {
    this.initializeTheme()
    this.setupSystemPreferenceListener()
  }

  initializeTheme() {
    // Check localStorage first, then system preference
    const savedTheme = localStorage.getItem('theme')
    if (savedTheme) {
      this.themeValue = savedTheme
    } else if (this.systemPreferenceValue) {
      this.themeValue = this.getSystemPreference()
    } else {
      this.themeValue = 'light'
    }
    
    this.applyTheme()
  }

  getSystemPreference() {
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
  }

  setupSystemPreferenceListener() {
    if (this.systemPreferenceValue) {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
      mediaQuery.addEventListener('change', (e) => {
        if (!localStorage.getItem('theme')) {
          this.themeValue = e.matches ? 'dark' : 'light'
          this.applyTheme()
        }
      })
    }
  }

  toggle() {
    this.themeValue = this.themeValue === 'light' ? 'dark' : 'light'
    this.applyTheme()
  }

  applyTheme() {
    const isDark = this.themeValue === 'dark'
    
    // Update document class
    document.documentElement.classList.toggle('dark', isDark)
    
    // Update localStorage
    localStorage.setItem('theme', this.themeValue)
    
    // Update toggle button state
    this.updateToggleButton()
    
    // Dispatch custom event for other components
    this.dispatch('themeChanged', { detail: { theme: this.themeValue } })
  }

  updateToggleButton() {
    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute('aria-pressed', this.themeValue === 'dark')
    }
    
    // Update icon visibility based on current theme
    if (this.hasIconTarget) {
      this.iconTargets.forEach(icon => {
        const iconTheme = icon.dataset.themeValue
        if (iconTheme === this.themeValue) {
          icon.style.display = 'block'
        } else {
          icon.style.display = 'none'
        }
      })
    }
  }

  // Getter for current theme state
  get isDark() {
    return this.themeValue === 'dark'
  }

  // Method to check if theme is system preference
  get isSystemPreference() {
    return !localStorage.getItem('theme')
  }
}
