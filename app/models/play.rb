class Play < ApplicationRecord
  # Associations
  belongs_to :game, foreign_key: :game_slug, primary_key: :slug, optional: true

  def self.play_by_play_summary
    game = Game.find_by(slug: "sf-ari-18-2024")
    # Get all plays
    plays = Play.where(game_slug: game.slug).order(:sport_radar_sequence)
    plays.each do |play|
      puts "Play #{play.sport_radar_sequence} | #{play.event_type} | #{play.result}"
      ap play
    end
  end
end
