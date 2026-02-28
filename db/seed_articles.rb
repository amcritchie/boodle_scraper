Article.destroy_all
puts "Cleared existing articles"

Article.create!(
  title: "Patrick Mahomes Dominates in Week 1 Victory",
  title_summary: "Mahomes throws for 4 TDs as Chiefs cruise past Ravens",
  author: "Sports Desk",
  sport: "nfl",
  published_at: Date.new(2025, 9, 7),
  main_person_name: "Patrick Mahomes",
  main_person_slug: "patrick-mahomes",
  main_team_name: "Kansas City Chiefs",
  main_team_slug: "kansas-city-chiefs",
  source: "news-bot",
  source_url: "https://example.com/mahomes-week1",
  source_id: "news-bot-001",
  model: "gpt-4o",
  process: "auto-summarize",
  process_notes: "Scraped from RSS feed, summarized via LLM",
  context: "Week 1 of the 2025 NFL season. Chiefs opened as 3-point favorites at home.",
  image_options: [
    "https://picsum.photos/id/180/800/600",
    "https://picsum.photos/id/181/800/600",
    "https://picsum.photos/id/182/800/600",
    "https://picsum.photos/id/183/800/600"
  ],
  image_selected: "https://picsum.photos/id/181/800/600",
  teams_json: [
    { name: "Kansas City Chiefs", slug: "kansas-city-chiefs", role: "home" },
    { name: "Baltimore Ravens", slug: "baltimore-ravens", role: "away" }
  ],
  people_json: [
    { name: "Patrick Mahomes", slug: "patrick-mahomes", position: "QB" },
    { name: "Travis Kelce", slug: "travis-kelce", position: "TE" }
  ],
  scores_json: { home: 34, away: 20 },
  key_stats_json: [
    { label: "Passing Yards", value: "327" },
    { label: "Touchdowns", value: "4" },
    { label: "Passer Rating", value: "142.8" }
  ],
  quotes_json: [
    { speaker: "Patrick Mahomes", text: "We came out firing on all cylinders today." }
  ]
)
puts "Article 1 created: Mahomes"

Article.create!(
  title: "Saquon Barkley Rushes for 180 Yards in Eagles Win",
  title_summary: "Barkley's monster game powers Philly past Packers",
  author: "Beat Writer",
  sport: "nfl",
  published_at: Date.new(2025, 9, 8),
  main_person_name: "Saquon Barkley",
  main_person_slug: "saquon-barkley",
  main_team_name: "Philadelphia Eagles",
  main_team_slug: "philadelphia-eagles",
  source: "rss-feed",
  source_url: "https://example.com/barkley-180",
  source_id: "rss-002",
  model: "claude-sonnet",
  process: "manual-review",
  process_notes: "Flagged for review due to high stat line",
  context: "Barkley's first season with the Eagles after signing in free agency.",
  image_options: [
    "https://picsum.photos/id/200/800/600",
    "https://picsum.photos/id/201/800/600",
    "https://picsum.photos/id/202/800/600",
    "https://picsum.photos/id/203/800/600",
    "https://picsum.photos/id/204/800/600",
    "https://picsum.photos/id/205/800/600"
  ],
  image_selected: "https://picsum.photos/id/203/800/600",
  teams_json: [
    { name: "Philadelphia Eagles", slug: "philadelphia-eagles", role: "home" },
    { name: "Green Bay Packers", slug: "green-bay-packers", role: "away" }
  ],
  people_json: [
    { name: "Saquon Barkley", slug: "saquon-barkley", position: "RB" },
    { name: "Jalen Hurts", slug: "jalen-hurts", position: "QB" }
  ],
  scores_json: { home: 28, away: 17 },
  key_stats_json: [
    { label: "Rushing Yards", value: "180" },
    { label: "Carries", value: "24" },
    { label: "Yards Per Carry", value: "7.5" },
    { label: "Rushing TDs", value: "2" }
  ],
  quotes_json: [
    { speaker: "Saquon Barkley", text: "This offense fits my style perfectly." },
    { speaker: "Nick Sirianni", text: "He's everything we hoped for and more." }
  ]
)
puts "Article 2 created: Barkley"

Article.create!(
  title: "CJ Stroud Throws Game-Winning TD in Final Seconds",
  title_summary: "Texans rally from 10 down to stun Cowboys in Arlington",
  author: "AP Wire",
  sport: "nfl",
  published_at: Date.new(2025, 9, 8),
  main_person_name: "CJ Stroud",
  main_person_slug: "cj-stroud",
  main_team_name: "Houston Texans",
  main_team_slug: "houston-texans",
  source: "news-bot",
  source_url: "https://example.com/stroud-comeback",
  source_id: "news-bot-003",
  model: "gpt-4o",
  process: "auto-summarize",
  context: "Texans entered as underdogs. Stroud continues to build on impressive rookie season.",
  image_options: [
    "https://picsum.photos/id/220/800/600",
    "https://picsum.photos/id/221/800/600",
    "https://picsum.photos/id/222/800/600"
  ],
  teams_json: [
    { name: "Houston Texans", slug: "houston-texans", role: "away" },
    { name: "Dallas Cowboys", slug: "dallas-cowboys", role: "home" }
  ],
  people_json: [
    { name: "CJ Stroud", slug: "cj-stroud", position: "QB" },
    { name: "Nico Collins", slug: "nico-collins", position: "WR" }
  ],
  scores_json: { away: 27, home: 24 },
  records_json: [
    { team: "Houston Texans", wins: 1, losses: 0 },
    { team: "Dallas Cowboys", wins: 0, losses: 1 }
  ],
  key_stats_json: [
    { label: "Passing Yards", value: "289" },
    { label: "Touchdowns", value: "3" },
    { label: "Game-Winning Drive", value: "75 yards, 1:42" }
  ],
  quotes_json: [
    { speaker: "CJ Stroud", text: "We never stopped believing. That's what this team is about." }
  ]
)
puts "Article 3 created: Stroud"

puts "Done! #{Article.count} articles seeded."
