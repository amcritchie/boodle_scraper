class Player < ApplicationRecord
  validates :slug, presence: true, uniqueness: true

  # Additional validations can be added as needed
  validates :rank, :player, :team, :college, :draft_year, presence: true

  # Scopes for querying
  scope :by_team, ->(team) { where(team_slug: team) }
  scope :by_position, ->(position) { where(position: position) }

  def team
    # Find active team
    Team.active.find_by(slug: team_slug)
  end

  def tag
    truncated_tag = "#{position_symbol} #{last_name}"
    truncated_tag.length > 9 ? "#{truncated_tag[0, 9]}..." : truncated_tag
  end

  def position_symbol
    case position
    when "quarterback"
      :QB
    when "running_back"
      :RB
    when "full_back"
      :FB
    when "wide_receiver"
      :WR
    when "tight_end"
      :TE
    when "center"
      :C
    when "gaurd"
      :G
    when "tackle"
      :T
    when "defensive_end"
      :DE
    when "edge_rusher"
      :EDGE
    when "linebackers"
      :LB
    when "safeties"
      :S
    when "cornerback"
      :CB
    else
      :DB
    end
  end

  def tier_class(tier)
    case tier
    when "S"
      "bg-green-500 text-white"
    when "A"
      "bg-green-200 text-green-800"
    when "B"
      "bg-red-100 text-red-800"
    when "C"
      "bg-red-300 text-red-900"
    when "D"
      "bg-red-500 text-white"
    else
      ""
    end
  end

  def description
    puts "#{team.description} #{player} #{position} PFF: #{rank}"
  end

  def self.print_top_5_qbs
    top_qbs = order(offense_grade: :desc).limit(5)
    puts "Top 5 Quarterbacks:"
    top_qbs.each_with_index do |qb, index|
      puts "#{index + 1}. #{qb.player} - Overall Grade: #{qb.offense_grade}"
    end
  end
end
