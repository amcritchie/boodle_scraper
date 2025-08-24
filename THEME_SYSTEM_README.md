# Theme System Documentation

## Overview

The new theme system provides a centralized, consistent approach to managing light and dark themes across the entire application. It replaces the scattered `dark:` variants with a unified system using CSS custom properties and JavaScript controllers.

## Key Benefits

1. **Centralized Management**: All theme colors are defined in one place
2. **Consistency**: Same color scheme across all pages and components
3. **Maintainability**: Easy to update themes globally
4. **Performance**: CSS custom properties for smooth transitions
5. **Accessibility**: Automatic system preference detection
6. **Developer Experience**: Helper methods and pre-built components

## Architecture

### 1. Theme Controller (`app/javascript/controllers/theme_controller.js`)
- Manages theme state (light/dark)
- Handles localStorage persistence
- Detects system preferences
- Dispatches theme change events

### 2. Theme CSS (`app/assets/stylesheets/theme.css`)
- Defines CSS custom properties for all colors
- Provides utility classes for common patterns
- Includes pre-built themed components

### 3. Theme Helper (`app/helpers/theme_helper.rb`)
- Ruby helper methods for views
- Consistent class generation
- Reduces repetition in templates

## Usage

### Basic Theme Classes

Replace scattered `dark:` variants with theme classes:

```erb
<!-- Before (scattered dark mode) -->
<div class="bg-white dark:bg-gray-800 text-gray-900 dark:text-white">

<!-- After (unified theme system) -->
<div class="theme-bg-primary theme-text-primary">
```

### Common Theme Classes

#### Backgrounds
- `theme-bg-primary` - Main background color
- `theme-bg-secondary` - Secondary background color
- `theme-bg-tertiary` - Tertiary background color
- `theme-bg-accent` - Accent background color

#### Text Colors
- `theme-text-primary` - Main text color
- `theme-text-secondary` - Secondary text color
- `theme-text-tertiary` - Tertiary text color
- `theme-text-muted` - Muted text color

#### Borders
- `theme-border-primary` - Main border color
- `theme-border-secondary` - Secondary border color
- `theme-border-accent` - Accent border color

#### Components
- `theme-card` - Complete themed card component
- `theme-card-header` - Card header with gradient
- `theme-table` - Themed table
- `theme-table-header` - Table header
- `theme-table-row` - Table row with hover effects
- `theme-table-cell` - Table cell

### Using Helper Methods

```erb
<!-- In your view -->
<div class="<%= theme_card_classes('mb-8') %>">
  <h2 class="<%= theme_text_primary %>">Title</h2>
  <p class="<%= theme_text_secondary %>">Description</p>
</div>

<button class="<%= theme_button_primary_classes('px-6 py-3') %>">
  Action Button
</button>
```

### Complete Component Example

```erb
<div class="theme-card">
  <div class="theme-card-header">
    <div class="flex items-center space-x-3">
      <span class="text-2xl">🏆</span>
      <div>
        <h3 class="text-xl font-bold text-white">Card Title</h3>
        <p class="text-white/90 text-sm">Card description</p>
      </div>
    </div>
  </div>
  <div class="p-6">
    <p class="theme-text-primary mb-4">Content goes here</p>
    <div class="flex space-x-4">
      <button class="theme-button-primary">Primary</button>
      <button class="theme-button-secondary">Secondary</button>
    </div>
  </div>
</div>
```

## Migration Guide

### Step 1: Update Layout
The application layout has been updated to use the theme controller:
```erb
<body class="theme-bg-secondary min-h-screen" 
      data-controller="theme"
      data-theme-system-preference-value="true">
```

### Step 2: Replace Dark Mode Classes
Search and replace patterns:

```bash
# Find all dark mode classes
grep -r "dark:" app/views/

# Replace common patterns
s/bg-white dark:bg-gray-800/theme-bg-primary/g
s/text-gray-900 dark:text-white/theme-text-primary/g
s/border-gray-200 dark:border-gray-700/theme-border-primary/g
```

### Step 3: Use Theme Classes
Replace individual dark mode classes with theme classes:

```erb
<!-- Before -->
<div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden border border-gray-200 dark:border-gray-700">

<!-- After -->
<div class="theme-card">
```

### Step 4: Update Tables
Replace table styling:

```erb
<!-- Before -->
<table class="w-full text-sm">
  <thead>
    <tr class="bg-gray-50 dark:bg-gray-700">
      <th class="text-left p-3 font-semibold text-gray-900 dark:text-white">

<!-- After -->
<table class="theme-table">
  <thead>
    <tr>
      <th class="theme-table-header">
```

## Customization

### Adding New Theme Colors

1. **Update CSS Variables** in `theme.css`:
```css
:root {
  --color-custom: #your-color;
}

.dark {
  --color-custom: #your-dark-color;
}
```

2. **Add Utility Class**:
```css
.theme-custom { color: var(--color-custom); }
```

3. **Add Helper Method** in `theme_helper.rb`:
```ruby
def theme_custom
  "theme-custom"
end
```

### Brand Colors

The system includes your brand colors:
- Primary: `#4BAF50` (green)
- Secondary: `#3d8a40` (dark green)
- Accent: `#FF7C47` (orange)
- Dark: `#121E18` (very dark green)
- Light: `#E8F0E6` (light green)

## Best Practices

1. **Use Theme Classes**: Always use `theme-*` classes instead of hardcoded colors
2. **Leverage Helpers**: Use helper methods for common patterns
3. **Consistent Spacing**: Maintain consistent spacing with Tailwind utilities
4. **Test Both Themes**: Always test your views in both light and dark modes
5. **Accessibility**: Ensure sufficient contrast ratios in both themes

## Troubleshooting

### Theme Not Switching
- Check that the theme controller is properly loaded
- Verify `data-controller="theme"` is on the body element
- Check browser console for JavaScript errors

### Colors Not Updating
- Ensure `theme.css` is included in `application.css`
- Check that CSS custom properties are being applied
- Verify the `dark` class is being added to `html` element

### Inconsistent Styling
- Use theme classes consistently across similar components
- Avoid mixing old `dark:` variants with new theme classes
- Check that all related elements use the same theme approach

## Future Enhancements

1. **Theme Presets**: Additional color schemes beyond light/dark
2. **Dynamic Themes**: User-customizable color schemes
3. **Component Library**: More pre-built themed components
4. **Design Tokens**: Integration with design system tokens
5. **Animation Controls**: User preference for motion/transitions

## Support

For questions or issues with the theme system:
1. Check this documentation
2. Review the example files in `app/views/teams/_theme_example.html.erb`
3. Examine the theme controller and CSS files
4. Test with the browser's developer tools
