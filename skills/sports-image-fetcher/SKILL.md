---
name: sports-image-fetcher
description: "Find and download sports action images for articles. Supports multiple sources: Google Images, Wikimedia Commons, league player pages, and article featured images. Use when: Article needs images, user wants action shots, or needs multiple options."
---

# Sports Image Fetcher

## Overview

Fetch sports images from multiple sources to get action shots of athletes. Different scenarios call for different sources.

## When to Trigger

- After extracting main_person_name from an article
- When you need images for an athlete profile
- When you want action shots vs studio headshots

## Image Sources (in priority order)

### 1. Article Featured Image (Easiest)
- Source: The article's own featured image
- URL: Check `<meta property="og:image">` or article hero image
- Best for: Always matches the story

### 2. Google Images (Action Shots)
- Use browser to search Google Images
- Search: "[athlete name] [team] action shot"
- Click image → copy direct URL
- Best for: In-game action photos

### 3. Wikimedia Commons (Free/Legal)
- URL: `commons.wikimedia.org/wiki/Category:[Player_Name]`
- Free, Creative Commons licensed
- Best for: Headshots, official photos

### 4. League Sites (Official)
- NBA: `nba.com/player/[id]`
- NFL: `nfl.com/players/[id]`
- MLB: `mlb.com/player/[id]`
- Best for: Official headshots

### 5. Team Sites
- Most teams have player galleries
- Best for: High-quality team-approved photos

## Process

### Step 1: Determine Source Based on Need

| Need | Best Source |
|------|-------------|
| Article match | Article og:image |
| Action shot | Google Images |
| Headshot | Wikimedia/League site |
| Multiple options | Google Images + Wikimedia |

### Step 2: Fetch Image

**For Google Images (Browser):**
1. Open `https://www.google.com/search?q=[name]+[team]+action&tbm=isch`
2. Click on desired image
3. Copy image address/URL
4. Download: `curl -sL "[URL]" -o uploads/[name].jpg`

**For Wikimedia:**
1. Open `https://commons.wikimedia.org/wiki/Category:[Name]`
2. Find suitable image
3. Get direct upload URL (usually in format: `upload.wikimedia.org/wikipedia/...`)
4. Download

### Step 3: Save Multiple Options

When you need choice:
- Download 2-3 images to `uploads/`
- Name: `{athlete-name}-{1,2,3}.jpg`
- Return array of paths

## Output

Return a JSON object:
```json
{
  "image_options": [
    "uploads/nikola-jokic-1.jpg",
    "uploads/nikola-jokic-2.jpg"
  ],
  "image_selected": "uploads/nikola-jokic-1.jpg",
  "source": "google_images",
  "notes": "Action shot from Reuters"
}
```

## Example

**Article:** Nikola Jokic confrontation with Lu Dort
**main_person_name:** Nikola Jokic
**main_team_name:** Denver Nuggets

1. Try article og:image first (Yahoo)
2. If need action shots → Google Images search
3. Download 2 options
4. Return paths

## Tips

- Google Images via browser is most reliable for action shots
- Wikimedia has rate limits - add delays between requests
- Always verify image is downloadable before promising it
- League sites have consistent URL patterns for player photos
