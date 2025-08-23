class Player < ApplicationRecord
  include PositionConcern
  
  before_save :initialize_syncs
  
  belongs_to :team, optional: true

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

  def self.print_grade
    puts "Player".to_s.ljust(23) + "Position".to_s.ljust(18) + "Offense".to_s.ljust(5) + "Pass".to_s.ljust(5) + "Run".to_s.ljust(5) + "Pass Block".to_s.ljust(5) + "Run Block".to_s.ljust(5)
    all.sort_by { |p| (p.grades_offense || 0) }.each do |player|
      puts "#{player.player.to_s.ljust(20)} - #{player.position.to_s.ljust(15)} - #{player.grades_offense.to_s.ljust(5)} - #{player.grades_pass.to_s.ljust(5)} - #{player.grades_run.to_s.ljust(5)} - #{player.grades_pass_block.to_s.ljust(5)} - #{player.grades_run_block.to_s.ljust(5)}"
    end
    return nil
  end


  def passing_grade_x
    grades_pass || grades_offense || 60
  end
  def receiving_grade_x
    grades_pass_route || grades_offense || 60
  end
  def pass_block_grade_x
    grades_pass_block || grades_offense || 60
  end
  def pass_rush_grade_x
    grades_pass_rush || grades_offense || 60
  end
  def coverage_grade_x
    grades_coverage || grades_offense || 60
  end
  def rush_grade_x
    grades_run || grades_offense || 60
  end
  def run_block_grade_x
    grades_run_block || grades_offense || 60
  end
  def rush_defense_grade_x
    grades_rush_defense || grades_offense || 60
  end


  


  # Sort General Grades
  def self.by_grades_offense
    all.order(Arel.sql('COALESCE(grades_offense, 60) DESC'))
  end
  def self.by_grades_defence
    all.order(Arel.sql('COALESCE(grades_defence, 60) DESC'))
  end
  # Pass Play - Offense
  def self.by_grades_passing
    all.order(Arel.sql('COALESCE(grades_passing, 60) DESC'))
  end
  def self.by_grades_pass_route
    all.order(Arel.sql('COALESCE(grades_pass_route, 60) DESC'))
  end
  def self.by_grades_pass_block
    all.order(Arel.sql('COALESCE(grades_pass_block, 60) DESC'))
  end
  # Pass Play - Defense
  def self.by_grades_pass_rush
    all.order(Arel.sql('COALESCE(grades_pass_rush, 60) DESC'))
  end
  def self.by_grades_coverage
    all.order(Arel.sql('COALESCE(grades_coverage, 60) DESC'))
  end
  # Run Play - Offense
  def self.by_grades_run_block
    all.order(Arel.sql('COALESCE(grades_run_block, 60) DESC'))
  end
  def self.by_grades_run
    all.order(Arel.sql('COALESCE(grades_run, 60) DESC'))
  end
  # Run Play - Defense
  def self.by_grades_rush_defense
    all.order(Arel.sql('COALESCE(grades_rush_defense, 60) DESC'))
  end

  def self.quarterbacks
    all.where(position: ['quarterback'])
  end
  
  def self.starting_quarterbacks
    quarterbacks
  end
  def self.running_backs
    all.where(position: ['running-back'])
  end
  def self.wide_receivers
    all.where(position: ['wide-receiver'])
  end
  def self.tight_ends
    all.where(position: ['tight-end'])
  end
  def self.flex
    all.where(position: ['running-back', 'wide-receiver', 'tight-end'])
  end
  def self.oline
    all.where(position: ['center', 'gaurd', 'tackle'])
  end
  def self.center
    all.where(position: ['center'])
  end
  def self.guards
    all.where(position: ['gaurd'])
  end
  def self.tackles
    all.where(position: ['tackle'])
  end
  def self.defensive_ends
    all.where(position: ['defensive-end'])
  end
  def self.edge_rushers
    all.where(position: ['edge-rusher'])
  end
  def self.linebackers
    all.where(position: ['linebacker'])
  end
  def self.safeties
    all.where(position: ['safety'])
  end
  def self.cornerbacks
    all.where(position: ['cornerback'])
  end
  def self.flex_defense
    all.where(position: ['defensive-end', 'edge-rusher', 'linebacker', 'safety', 'cornerback'])
  end
  def self.flex_dline
    all.where(position: ['defensive-end', 'edge-rusher'])
  end

  # def self.run_block
  #   all.sort_by { |player| -player.pass_block_grade }
  # end
  # def self.pass_block
  #   all.sort_by { |player| -player.pass_block_grade }
  # end






  def position_symbol
    case position
    when "quarterback"
      "QB"
    when "running-back"
      "RB"
    when "full-back"
      "FB"
    when "wide-receiver"
      "WR"
    when "tight-end"
      "TE"
    when "center"
      "C"
    when "gaurd"
      "G"
    when "tackle"
      "T"
    when "defensive-end"
      "DE"
    when "edge-rusher"
      "EDGE"
    when "linebacker"
      "LB"
    when "safety"
      "S"
    when "cornerback"
      "CB"
    else
      "DB"
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

  def self.pff_starters_fetch(row)
    # Fetch slug data
    name              = row["Player"]
    position_starter  = pff_starter_position(row["Position"])
    position          = pff_starter_position_normalize_oline(position_starter)
    position_class    = position_class(position)
    college           = row["college"].downcase.gsub(' ', '-') rescue 'undrafted'
    player_slug       = "#{position_class}-#{name}".player_slugify

    player_slug = "secondary-kamren-curl" if player_slug == "secondary-kam-curl"
    player_slug = "secondary-tariq-woolen" if player_slug == "secondary-riq-woolen"
    # Find or create player
    unless player = Player.find_by(slug: player_slug)
      # Some Dlines might be labeled as linebackers in PFF
      was_linebacker_position = position_class
      was_linebacker_position = :linebacker if position_class == :dline
      was_linebacker_slug     = "#{was_linebacker_position}-#{name}".player_slugify
      was_dline_position = position_class
      was_dline_position = :dline if position_class == :linebacker
      was_dline_slug     = "#{was_dline_position}-#{name}".player_slugify
      # Find or create player
      if player = Player.find_by(slug: was_linebacker_slug)
        player = player
        puts "Dline / Linebacker Swap (listed as dline) | Slug: #{player_slug}"
      elsif player = Player.find_by(slug: was_dline_slug)
        player = player
        puts "Dline / Linebacker Swap (listed as linebacker) | Slug: #{player_slug}"
      else
        player = Player.find_or_create_by(slug: player_slug)
        player.prepend_sync("PFF starters fetch creation - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}")
      end
    end
    # Return player
    player
  end

  def grades_pass_route_print
    grades_pass_route || "#{grades_offense} 🤖"
  end

  def self.sportsradar_find_or_create(player_sportsradar, team_slug)

    # Fetch slug data
    name            = player_sportsradar["name"]
    position        = sportsradar_position(player_sportsradar["position"])
    position_class  = position_class(position)
    college         = player_sportsradar["college"].downcase.gsub(' ', '-') rescue 'undrafted'
    player_slug     = "#{position_class}-#{name}".player_slugify
    # Valdate if Player already exists
    unless player = Player.find_by(sportsradar_id: player_sportsradar["id"])
      unless player = Player.find_by(sportsradar_slug: player_sportsradar["sr_id"])
        # Find or create player
        unless player = Player.find_by(slug: player_slug)
          # Some Dlines might be labeled as linebackers in PFF
          was_dline_position = position_class
          was_dline_position = :dline if position_class == :linebacker
          was_dline_slug     = "#{was_dline_position}-#{name}".player_slugify
          was_linebacker_position = position_class
          was_linebacker_position = :linebacker if position_class == :dline
          was_linebacker_slug     = "#{was_linebacker_position}-#{name}".player_slugify
          # Find or create player
          if player = Player.find_by(slug: was_dline_slug)
            position    = player.position
            player_slug = was_dline_slug
            puts "Dline / Linebacker Swap (listed as linebacker) | Slug: #{player_slug}"
          elsif player = Player.find_by(slug: was_linebacker_slug)
            position    = player.position
            player_slug = was_linebacker_slug
            puts "Dline / Linebacker Swap (listed as dline) | Slug: #{player_slug}"
          else
            player = Player.find_or_create_by(slug: player_slug)
            player.prepend_sync("SportsRadar creation - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}")
          end
        end
      end
    end
    # Update Player with SportsRadar data
    player.update(
      # slug:               player_slug,  # Don't define slug here.  Causes a bug when re-running rake tasks | dline-dj-wonnum becomes linebacker-dj-wonnum
      position:           position,
      team_slug:          team_slug,
      player:             player_sportsradar["name"],
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
    player.prepend_sync("SportsRadar update - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}")
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
    player.prepend_sync("PFF general creation - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}") if player.persisted?
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

  def self.with_offense_grade
    all.where.not(grades_offense: nil)
  end

  def self.offense_grade
    all.with_offense_grade.order(grades_offense: :desc)
  end

  def self.with_defence_grade
    all.where.not(grades_defence: nil)
  end

  def self.defence_grade
    all.with_defence_grade.order(grades_defence: :desc)
  end

  def self.quarterback
    Player.where(position: [:quarterback])
  end

  def self.jay
    all.where(first_name: "Jayden")
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
    peers = Player.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(grades_rush_defense: :desc).limit(352)
    peer_tiering(peers) 
  end

  def pass_rush_tier
    peers = Player.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(grades_pass_rush: :desc).limit(352)
    peer_tiering(peers) 
  end

  def coverage_tier
    peers = Player.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(grades_coverage: :desc).limit(352)
    peer_tiering(peers) 
  end

  # def description
  #   puts "#{position.rjust(15)} | #{player.rjust(25)} (#{jersey.to_s.rjust(2)}) | Grade: #{offense_grade.to_s.rjust(6)} /#{grades_defence.to_s.rjust(6)} | #{team.description.ljust(30)}"
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

  # Initialize syncs as empty array if nil
  def initialize_syncs
    self.syncs ||= []
  end

  # Prepend a string to the syncs array
  def prepend_sync(sync_string)
    initialize_syncs
    self.syncs.push(sync_string)
    save
  end

  # Get syncs with initialization
  def syncs_with_init
    initialize_syncs
    syncs
  end
end
