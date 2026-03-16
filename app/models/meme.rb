class Meme < ApplicationRecord
  scope :by_feeling, ->(f) { where(feeling: f) if f.present? }
  scope :by_team, ->(slug) { where(team_slug: slug) if slug.present? }
  scope :unused_first, -> { order(Arel.sql("last_used_at ASC NULLS FIRST, rank ASC NULLS LAST")) }
end
