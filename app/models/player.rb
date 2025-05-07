class Player < ApplicationRecord
  validates :slug, presence: true, uniqueness: true

  # Additional validations can be added as needed
  validates :rank, :player, :team, :college, :draft_year, presence: true

  # Scopes for querying
  scope :by_team, ->(team) { where(team: team) }
  scope :by_position, ->(position) { where(position: position) }

  def description
    puts "#{player} #{team} #{position} PFF: #{rank}"
  end
  def self.print_top_5_qbs
    top_qbs = order(overall_grade: :desc).limit(5)
    puts "Top 5 Quarterbacks:"
    top_qbs.each_with_index do |qb, index|
      puts "#{index + 1}. #{qb.player} - Overall Grade: #{qb.overall_grade}"
    end
  end
end
