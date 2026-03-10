# Seed file for Agent Management Dashboard
# Run with: rails runner db/seed_agents.rb

AgentActivity.destroy_all
AgentUsage.destroy_all
AgentSkillAssignment.destroy_all
AgentTask.destroy_all
AgentSkill.destroy_all
Agent.destroy_all
puts "Cleared existing agent data"

# ─── Skills ────────────────────────────────────────────────────────

skills_data = [
  { name: "Article Summarization", slug: "article-summarization", category: "content", description: "Summarize news articles into concise briefs" },
  { name: "Image Search", slug: "image-search", category: "content", description: "Find relevant images for articles and posts" },
  { name: "Social Media Writing", slug: "social-media-writing", category: "content", description: "Write engaging social media posts" },
  { name: "Web Scraping", slug: "web-scraping", category: "data", description: "Extract structured data from web pages" },
  { name: "API Integration", slug: "api-integration", category: "data", description: "Connect to and consume external APIs" },
  { name: "Data Analysis", slug: "data-analysis", category: "analytics", description: "Analyze datasets and generate insights" },
  { name: "RSS Monitoring", slug: "rss-monitoring", category: "data", description: "Monitor RSS feeds for new content" },
  { name: "Prediction Modeling", slug: "prediction-modeling", category: "analytics", description: "Build and run prediction models for game outcomes" },
  { name: "Product Strategy", slug: "product-strategy", category: "product", description: "Define product vision, roadmap, and feature priorities" },
  { name: "User Research", slug: "user-research", category: "product", description: "Gather and synthesize user feedback and usage patterns" },
  { name: "Feature Prioritization", slug: "feature-prioritization", category: "product", description: "Prioritize backlog items based on user value and business impact" },
  { name: "Quality Assurance", slug: "quality-assurance", category: "product", description: "Review shipped features for UX quality and acceptance criteria" }
]

skills_data.each do |data|
  AgentSkill.create!(data)
end
puts "Created #{AgentSkill.count} skills"

# ─── Agents ────────────────────────────────────────────────────────

alex = Agent.create!(
  name: "Alex Agent",
  slug: "alex",
  title: "CEO",
  status: "active",
  description: "Strategy agent responsible for coordination, task prioritization, quality review, and translating operator requests into agent tasks.",
  agent_type: "strategy",
  avatar_url: ActionController::Base.helpers.asset_path("agent-alex.png"),
  config: {},
  metadata: { version: "1.0.0", deployment: "production" },
  last_active_at: 1.hour.ago
)
puts "Created agent: Alex Agent"

mack = Agent.create!(
  name: "Mack",
  slug: "mack",
  title: "CTO",
  status: "active",
  description: "Engineering agent focused on infrastructure, data pipelines, API integrations, and system reliability. Keeps the systems running and the data flowing.",
  agent_type: "engineering",
  avatar_url: ActionController::Base.helpers.asset_path("agent-mack.png"),
  config: { model: "gpt-4o", temperature: 0.7, max_tokens: 4096 },
  metadata: { version: "1.2.0", deployment: "production" },
  last_active_at: 2.hours.ago
)
puts "Created agent: Mack"

mason = Agent.create!(
  name: "Mason",
  slug: "mason",
  title: "CPO",
  status: "active",
  description: "Product agent who owns the roadmap, feature prioritization, and UX quality. A 60-pound Goldendoodle that everyone calls a poodle. Friendly but decisive — ships the right thing, not everything.",
  agent_type: "product",
  avatar_url: ActionController::Base.helpers.asset_path("agent-mason.png"),
  config: {},
  metadata: { version: "1.0.0", deployment: "production" },
  last_active_at: 45.minutes.ago
)
puts "Created agent: Mason"

turf = Agent.create!(
  name: "Turf Monster",
  slug: "turf-monster",
  title: "CMO",
  status: "active",
  description: "Content agent specializing in NFL sports media, article summarization, social media writing, and audience growth. The voice of the Boodle brand.",
  agent_type: "content",
  avatar_url: ActionController::Base.helpers.asset_path("agent-turf-monster.png"),
  config: { model: "claude-sonnet", temperature: 0.3, max_tokens: 8192 },
  metadata: { version: "2.0.1", deployment: "production" },
  last_active_at: 30.minutes.ago
)
puts "Created agent: Turf Monster"

# ─── Skill Assignments ────────────────────────────────────────────

# Mack (CTO): data/engineering skills
%w[web-scraping api-integration data-analysis rss-monitoring].each do |slug|
  AgentSkillAssignment.create!(agent_slug: "mack", skill_slug: slug, proficiency: slug == "rss-monitoring" ? 75 : 95)
end

# Mason (CPO): product skills
%w[product-strategy user-research feature-prioritization quality-assurance].each do |slug|
  AgentSkillAssignment.create!(agent_slug: "mason", skill_slug: slug, proficiency: 95)
end

# Turf Monster (CMO): content/media skills
%w[article-summarization image-search social-media-writing prediction-modeling].each do |slug|
  AgentSkillAssignment.create!(agent_slug: "turf-monster", skill_slug: slug, proficiency: slug == "prediction-modeling" ? 80 : 95)
end
puts "Created #{AgentSkillAssignment.count} skill assignments"

# ─── Tasks ─────────────────────────────────────────────────────────

tasks_data = [
  { title: "Summarize Week 1 recap articles", agent_slug: "turf-monster", stage: "done", priority: 0,
    description: "Process all Week 1 recap articles from RSS feeds and generate summaries.",
    required_skills: ["article-summarization", "rss-monitoring"],
    result: { articles_processed: 12, summaries_generated: 12 },
    started_at: 6.hours.ago, completed_at: 5.hours.ago },
  { title: "Generate social posts for Mahomes article", agent_slug: "turf-monster", stage: "done", priority: 1,
    description: "Create Twitter and Instagram posts for the Mahomes Week 1 article.",
    required_skills: ["social-media-writing", "image-search"],
    result: { posts_created: 3, images_selected: 2 },
    started_at: 4.hours.ago, completed_at: 3.hours.ago },
  { title: "Scrape Week 2 betting lines", agent_slug: "mack", stage: "in_progress", priority: 1,
    description: "Collect opening betting lines for all Week 2 games from SportsOddsHistory.",
    required_skills: ["web-scraping"],
    started_at: 1.hour.ago },
  { title: "Run prediction model for Week 2", agent_slug: "turf-monster", stage: "queued", priority: 2,
    description: "Generate prediction scores for all Week 2 matchups using latest data.",
    required_skills: ["prediction-modeling", "data-analysis"],
    queued_at: 30.minutes.ago },
  { title: "Find images for Barkley article", agent_slug: "turf-monster", stage: "failed", priority: 0,
    description: "Search for action photos of Saquon Barkley from Week 1.",
    required_skills: ["image-search"],
    started_at: 2.hours.ago, failed_at: 2.hours.ago,
    error_message: "Image search API rate limit exceeded" },
  { title: "Update team roster data", agent_slug: nil, stage: "new", priority: 0,
    description: "Pull latest roster updates from SportRadar API for all 32 teams.",
    required_skills: ["api-integration"] },
  { title: "Analyze scoring trends Week 1", agent_slug: nil, stage: "new", priority: 1,
    description: "Run scoring analysis across all Week 1 games and generate trend report.",
    required_skills: ["data-analysis"] },
  { title: "Define Week 2 content feature spec", agent_slug: "mason", stage: "done", priority: 1,
    description: "Write acceptance criteria for the Week 2 predictions page — what data to show, layout, and UX flow.",
    required_skills: ["product-strategy", "feature-prioritization"],
    result: { spec_sections: 4, features_defined: 6 },
    started_at: 7.hours.ago, completed_at: 6.hours.ago },
  { title: "Review Barkley article UX before publish", agent_slug: "mason", stage: "queued", priority: 0,
    description: "Check article layout, image placement, and mobile responsiveness before Turf Monster publishes.",
    required_skills: ["quality-assurance"],
    queued_at: 1.hour.ago }
]

tasks_data.each do |data|
  AgentTask.create!(data)
end
puts "Created #{AgentTask.count} tasks"

# ─── Activities ────────────────────────────────────────────────────

activities_data = [
  { agent_slug: "alex", activity_type: "status_change", description: "Agent Alex started up", created_at: 10.hours.ago },
  { agent_slug: "alex", activity_type: "info", description: "Assigned Week 1 recap summarization to Turf Monster", created_at: 8.hours.ago },
  { agent_slug: "mason", activity_type: "status_change", description: "Agent Mason started up", created_at: 8.hours.ago },
  { agent_slug: "mason", activity_type: "task_started", description: "Started defining Week 2 content feature spec", created_at: 7.hours.ago },
  { agent_slug: "mason", activity_type: "task_completed", description: "Completed: Week 2 content feature spec (6 features defined)", created_at: 6.hours.ago },
  { agent_slug: "mack", activity_type: "status_change", description: "Agent Mack started up", created_at: 8.hours.ago },
  { agent_slug: "turf-monster", activity_type: "status_change", description: "Agent Turf Monster started up", created_at: 8.hours.ago },
  { agent_slug: "turf-monster", activity_type: "task_started", description: "Started summarizing Week 1 recap articles", created_at: 6.hours.ago },
  { agent_slug: "turf-monster", activity_type: "skill_used", description: "Used Article Summarization to process 12 articles", created_at: 6.hours.ago },
  { agent_slug: "turf-monster", activity_type: "task_completed", description: "Completed: Summarize Week 1 recap articles (12 articles processed)", created_at: 5.hours.ago },
  { agent_slug: "turf-monster", activity_type: "task_started", description: "Started generating social posts for Mahomes article", created_at: 4.hours.ago },
  { agent_slug: "turf-monster", activity_type: "task_completed", description: "Completed: Generate social posts for Mahomes article (3 posts created)", created_at: 3.hours.ago },
  { agent_slug: "turf-monster", activity_type: "task_started", description: "Started searching for Barkley images", created_at: 2.hours.ago },
  { agent_slug: "turf-monster", activity_type: "task_failed", description: "Failed: Find images for Barkley article — API rate limit exceeded", created_at: 2.hours.ago },
  { agent_slug: "mack", activity_type: "task_started", description: "Started scraping Week 2 betting lines", created_at: 1.hour.ago },
  { agent_slug: "mack", activity_type: "skill_used", description: "Used Web Scraping on SportsOddsHistory", created_at: 1.hour.ago },
  { agent_slug: "alex", activity_type: "info", description: "Queued prediction model run for Week 2 (urgent priority)", created_at: 30.minutes.ago }
]

activities_data.each do |data|
  AgentActivity.create!(data)
end
puts "Created #{AgentActivity.count} activities"

# ─── Usage Records ─────────────────────────────────────────────────

base_date = Date.today

# Mack usage (4 days)
[
  { days_ago: 3, tokens_in: 45_200, tokens_out: 12_800, api_calls: 34, cost: 0.2340, tasks_completed: 3, tasks_failed: 0 },
  { days_ago: 2, tokens_in: 52_100, tokens_out: 15_300, api_calls: 41, cost: 0.2890, tasks_completed: 4, tasks_failed: 1 },
  { days_ago: 1, tokens_in: 38_700, tokens_out: 11_200, api_calls: 28, cost: 0.1950, tasks_completed: 2, tasks_failed: 0 },
  { days_ago: 0, tokens_in: 61_400, tokens_out: 18_600, api_calls: 47, cost: 0.3420, tasks_completed: 2, tasks_failed: 1 }
].each do |data|
  AgentUsage.create!(
    agent_slug: "mack",
    period_date: base_date - data[:days_ago].days,
    model: "gpt-4o",
    tokens_in: data[:tokens_in],
    tokens_out: data[:tokens_out],
    api_calls: data[:api_calls],
    cost: data[:cost],
    tasks_completed: data[:tasks_completed],
    tasks_failed: data[:tasks_failed]
  )
end

# Turf Monster usage (4 days)
[
  { days_ago: 3, tokens_in: 78_500, tokens_out: 22_100, api_calls: 18, cost: 0.1580, tasks_completed: 2, tasks_failed: 0 },
  { days_ago: 2, tokens_in: 92_300, tokens_out: 28_400, api_calls: 22, cost: 0.1920, tasks_completed: 3, tasks_failed: 0 },
  { days_ago: 1, tokens_in: 64_800, tokens_out: 19_700, api_calls: 15, cost: 0.1340, tasks_completed: 1, tasks_failed: 0 },
  { days_ago: 0, tokens_in: 105_200, tokens_out: 31_500, api_calls: 25, cost: 0.2180, tasks_completed: 0, tasks_failed: 0 }
].each do |data|
  AgentUsage.create!(
    agent_slug: "turf-monster",
    period_date: base_date - data[:days_ago].days,
    model: "claude-sonnet",
    tokens_in: data[:tokens_in],
    tokens_out: data[:tokens_out],
    api_calls: data[:api_calls],
    cost: data[:cost],
    tasks_completed: data[:tasks_completed],
    tasks_failed: data[:tasks_failed]
  )
end
puts "Created #{AgentUsage.count} usage records"

puts "\nDone! Seeded:"
puts "  #{Agent.count} agents"
puts "  #{AgentSkill.count} skills"
puts "  #{AgentSkillAssignment.count} skill assignments"
puts "  #{AgentTask.count} tasks"
puts "  #{AgentActivity.count} activities"
puts "  #{AgentUsage.count} usage records"
