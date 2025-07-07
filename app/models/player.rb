class Player < ApplicationRecord
  belongs_to :team
  has_many :player_seasons
  has_many :seasons, through: :player_seasons

  # validates :slug, presence: true, uniqueness: true

  # Additional validations can be added as needed
  # validates :rank, :player, :team, :college, :draft_year, presence: true

  # Scopes for querying
  scope :by_team, ->(team) { where(team_slug: team) }
  scope :by_position, ->(position) { where(position: position) }

  def team
    # Find active team
    Team.active.find_by(slug: team_slug)
  end

  def tag
    truncated_tag = "#{last_name} #{position_symbol}"
    # truncated_tag.length > 9 ? "#{truncated_tag[0, 9]}..." : truncated_tag
  end

  # 1.6176470588235294
  # Player.where(position: [:quarterback, :QB, :runningback, :HB]).sum{|b| b.touchdowns }.to_f/(16*17)

  # 2.9338235294117645
  # Player.runningbacks.sum{|b| b.touchdowns }.to_f/(16*17)
  
  def self.quarterbacks
    all.where(position: [:quarterback, :QB])
  end

  def self.running_backs
    all.where(position: ['running-back', :HB])
  end

  def self.run_block
    all.sort_by { |player| -player.pass_block_grade }
  end
  def self.pass_block
    all.sort_by { |player| -player.pass_block_grade }
  end

  def self.order_pass_rush
    all.order(pass_rush_grade: :desc)
  end

  def self.order_coverage
    all.order(coverage_grade: :desc)
  end

  def self.order_run_block
    all.order(run_block_grade: :desc)
  end

  def self.order_pass_block
    all.order(pass_block_grade: :desc)
  end
  def self.order_receiving
    all.order(receiving_grade: :desc)
  end

  def self.order_passing
    all.order(passing_grade: :desc)
  end
  def self.order_rushing
    all.order(rushing_grade: :desc)
  end
  def self.order_rush_defense
    all.order(rush_defense_grade: :desc)
  end

  def position_symbol
    case position
    when "quarterback"
      :QB
    when "running-back"
      :RB
    when "full-back"
      :FB
    when "wide-receiver"
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
    when "edge-rusher"
      :EDGE
    when "linebacker"
      :LB
    when "safety"
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

  def tiering(casee)
    case casee
    when 0...0.1
      "A"
    when 0.1...0.3
      "B"
    when 0.3...0.6
      "C"
    when 0.6...0.9
      "D"
    else
      "D"
    end
  end

  def self.sportsradar_position(position)
    case position
    when "QB"
      "quarterback"
    when "RB"
      "running-back"
    when "HB"
      "running-back"
    when "FB"
      "full-back"
    when "WR"
      "wide-receiver"
    when "TE"
      "tight-end"
    when "C"
      "center"
    when "G"
      "gaurd"
    when "OL"
      "gaurd"
    when "T"
      "tackle"
    when "DL"
      "defensive-end"
    when "DE"
      "defensive-end"
    when "EDGE"
      "edge-rusher"
    when "OLB"
      "linebacker"
    when "LB"
      "linebacker"
    when "S"
      "safety"
    when "CB"
      "cornerback"
    else
      "place-kicker"
    end
  end

  def self.pff_position(position)
    case position
    when "QB"
      "quarterback"
    when "HB"
      "running-back"
    when "FB"
      "full-back"
    when "WR"
      "wide-receiver"
    when "TE"
      "tight-end"
    when "C"
      "center"
    when "G"
      "gaurd"
    when "OL"
      "gaurd"
    when "T"
      "tackle"
    when "DL"
      "defensive-end"
    when "DE"
      "defensive-end"
    when "EDGE"
      "edge-rusher"
    when "OLB"
      "linebacker"
    when "LB"
      "linebacker"
    when "S"
      "safety"
    when "CB"
      "cornerback"
    else
      "place-kicker"
    end
  end

  def self.sportsradar_find_or_create(player_sportsradar, team_slug)
    # Fetch slug data
    position = sportsradar_position(player_sportsradar["position"])
    college = player_sportsradar["college"].downcase.gsub(' ', '-') rescue 'undrafted'
    player_slug = "#{position}-#{player_sportsradar['first_name'].downcase}-#{player_sportsradar['last_name'].downcase}"
    # Valdate if Player already exists
    unless player = Player.find_by(sportsradar_id: player_sportsradar["id"])
      unless player = Player.find_by(sportsradar_slug: player_sportsradar["sr_id"])
        player = Player.find_or_create_by(slug: player_slug)
      end
    end
    # Update Player with SportsRadar data
    player.update(
      slug:               player_slug,  
      position:           position,
      team_slug:          team_slug,
      player:             "#{player_sportsradar['first_name']} #{player_sportsradar['last_name']}",
      first_name:         player_sportsradar["first_name"],
      last_name:          player_sportsradar["last_name"],
      jersey:             player_sportsradar["jersey"],
      weight_pounds:      player_sportsradar["weight"],
      height_inches:      player_sportsradar["height"],
      birth_date:         player_sportsradar["birth_date"],
      birth_place:        player_sportsradar["birth_place"],
      high_school:        player_sportsradar["high_school"],
      college_conf:       player_sportsradar["college_conf"],
      rookie_year:        player_sportsradar["rookie_year"],
      status:             player_sportsradar["status"],
      sportsradar_id:     player_sportsradar["id"],
      sportsradar_slug:   player_sportsradar["sr_id"],
      season_experience:  player_sportsradar["experience"]
    )
    # Return player
    player
  end

  def self.pff_general(pff_row, position)
    puts "MASON"
    ap pff_row
    puts "MASON1"
    # Fetch Player Name
    player_name = pff_row['Player']
    first_name = player_name.split.first
    last_name = player_name.split.last
    # Validate if last name includes
    if last_name.include?("II") || last_name.include?("Jr.")
      last_name = player_name.split.last(2).first rescue "invalid-last-name"
    end
    college = pff_row['College'].downcase.gsub(' ', '-') rescue 'undrafted'
    draft_year = pff_row['DraftYear'].to_i rescue 2099
    player_slug = "#{position}-#{first_name.downcase}-#{last_name.downcase}-#{college}"
    puts player_slug

    # Valdate if Player already exists
    player = Player.find_or_create_by(slug: player_slug) do |player|
      player.slug_pff = 1
    end
    # Return player
    player
  end

  def peer_tiering(peers)
    # Validate they are in tier list
    return "D" if peers.index(self).nil?
    total = peers.count
    rank = peers.index(self) + 1
    # tiering(rank.to_f / peers.count)
    case rank.to_f / total
    when 0...0.15
      "A"
    when 0.15...0.35
      "B"
    when 0.35...0.65
      "C"
    when 0.65...0.9
      "D"
    else
      "D"
    end
  end

  def passing_tier
    peers = Player.where(position: [:quarterback]).order(passing_grade: :desc).limit(32)
    peer_tiering(peers) 
  end

  def receiving_tier
    peers = Player.where(position: [:wide_receiver, :tight_end]).order(receiving_grade: :desc).limit(96)
    peer_tiering(peers) 
  end

  def rushing_tier
    peers = Player.where(position: [:runningback, :quarterback]).order(rushing_grade: :desc).limit(96)
    peer_tiering(peers) 
  end

  def rush_block_tier
    peers = Player.where(position: [:gaurd, :center, :tackle]).order(run_block_grade: :desc).limit(160)
    peer_tiering(peers) 
  end

  def pass_block_tier
    peers = Player.where(position: [:gaurd, :center, :tackle]).order(pass_block_grade: :desc).limit(160)
    peer_tiering(peers) 
  end

  def rush_defense_tier
    peers = Player.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(rush_defense_grade: :desc).limit(352)
    peer_tiering(peers) 
  end

  def pass_rush_tier
    peers = Player.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(pass_rush_grade: :desc).limit(352)
    peer_tiering(peers) 
  end

  def coverage_tier
    peers = Player.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(coverage_grade: :desc).limit(352)
    peer_tiering(peers) 
  end

  # def description
  #   puts "#{position.rjust(15)} | #{player.rjust(25)} (#{jersey.to_s.rjust(2)}) | Grade: #{offense_grade.to_s.rjust(6)} /#{defence_grade.to_s.rjust(6)} | #{team.description.ljust(30)}"
  # end

  def self.print_top_5_qbs
    top_qbs = order(offense_grade: :desc).limit(5)
    puts "Top 5 Quarterbacks:"
    top_qbs.each_with_index do |qb, index|
      puts "#{index + 1}. #{qb.player} - Overall Grade: #{qb.offense_grade}"
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
