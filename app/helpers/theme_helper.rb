module ThemeHelper
  # Helper methods for the theme system
  
  # Returns theme-aware CSS classes for common components
  def theme_card_classes(additional_classes = "")
    "theme-card #{additional_classes}".strip
  end
  
  def theme_table_classes(additional_classes = "")
    "theme-table #{additional_classes}".strip
  end
  
  def theme_button_primary_classes(additional_classes = "")
    "theme-button-primary #{additional_classes}".strip
  end
  
  def theme_button_secondary_classes(additional_classes = "")
    "theme-button-secondary #{additional_classes}".strip
  end
  
  # Helper for conditional theme classes
  def theme_class(light_class, dark_class)
    "#{light_class} dark:#{dark_class}"
  end
  
  # Helper for theme-aware text colors
  def theme_text_primary
    "theme-text-primary"
  end
  
  def theme_text_secondary
    "theme-text-secondary"
  end
  
  def theme_text_muted
    "theme-text-muted"
  end
  
  # Helper for theme-aware background colors
  def theme_bg_primary
    "theme-bg-primary"
  end
  
  def theme_bg_secondary
    "theme-bg-secondary"
  end
  
  def theme_bg_tertiary
    "theme-bg-tertiary"
  end
  
  # Helper for theme-aware border colors
  def theme_border_primary
    "theme-border-primary"
  end
  
  def theme_border_secondary
    "theme-border-secondary"
  end
end
