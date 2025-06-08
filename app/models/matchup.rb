class Matchup < ApplicationRecord
#   belongs_to :team

  validates :season, :week_slug, :game, :team, presence: true

  # Add methods to fetch offensive and defensive players if needed

  def self.phi
    find_by(season: 2025, week_slug: 1, team: :phi)
  end

  def self.ari
    find_by(season: 2025, week_slug: 1, team: :ari)
  end

  def team
    Team.find_by_slug(team_slug)
  end
  def team_defense
    Team.find_by_slug(team_defense_slug)
  end

  def self.set_scores
    all.each do |matchup|
      matchup.set_rushing_offense_score
      matchup.set_rushing_defense_score
      matchup.set_passing_offense_score
      matchup.set_passing_defense_score
    end
  end

  def self.s2025
    where(season: 2025)
  end

  def self.w1
    where(week_slug: 1)
  end

  def self.w2
    where(week_slug: 2)
  end

  def self.pass_offense_rank
    summary = []
    s2025.w1.order(passing_offense_score: :desc).each_with_index do |offense, index|
      summary.push(offense.pass_off_summary(index))
    end
    puts "========================"
    puts "Pass Offense Summary"
    puts "------------------------"
    puts summary
    puts "------------------------"
  end

  def self.pass_defense_rank
    summary = []
    sort_byy = [:sack_score, :coverage_score, :passing_defense_score].sample
    s2025.w1.order(sort_byy).each_with_index do |defense, index|
      summary.push(defense.pass_def_summary(index))
    end
    puts "========================"
    puts "Pass Defense Summary (#{sort_byy})"
    puts "------------------------"
    puts summary
    puts "------------------------"
  end

  def pass_off_summary(index)
    # Format: Rank (2 chars), Team (3 chars), Score (3 chars), Details
    formatted_summary = sprintf(
      "#%-2d %-3s %-3d %s",
      index,
      self.team_slug,
      self.passing_offense_score,
      self.passing_offense_score_string
    )
  end

  def pass_def_summary(index)
    # Format: Rank (2 chars), Team (3 chars), Sack Score (3 chars), Sack Factors, Coverage Score (3 chars), Coverage Factors
    formatted_summary = sprintf(
      "#%-2d %-3s %-3d %-40s %-3d %-20s",
      index,
      self.team_defense_slug,
      self.sack_score,
      self.sack_factors,
      self.coverage_score,
      self.coverage_factors
    )
  end



  def self.rush_offense_rank
    summary = []
    s2025.w1.order(rushing_offense_score: :desc).each_with_index do |offense, index|
      summary.push(offense.rush_off_summary(index))
    end
    puts "========================"
    puts "Rush Offense Summary"
    puts "------------------------"
    puts summary
    puts "------------------------"
  end

  def self.rush_defense_rank
    summary = []
    s2025.w1.order(rushing_defense_score: :desc).each_with_index do |defense, index|
      summary.push(defense.rush_def_summary(index))
    end
    puts "========================"
    puts "Rush Defense Summary"
    puts "------------------------"
    puts summary
    puts "------------------------"
  end

  def rush_off_summary(index)
    # Format: Rank (2 chars), Team (3 chars), Score (3 chars), Details
    formatted_summary = sprintf(
      "#%-2d %-3s %-3d %s",
      index,
      self.team,
      self.rushing_offense_score,
      self.rushing_offense_score_string
    )
  end

  def rush_def_summary(index)
    # Format: Rank (2 chars), Team (3 chars), Score (3 chars), Details
    formatted_summary = sprintf(
      "#%-2d %-3s %-3d %s",
      index,
      self.game,
      self.rushing_defense_score,
      self.rushing_defense_score_string
    )
  end

  def self.week1
    matchups_hash = {}
    matchups = Matchup.where(season: 2025, week_slug: 1)
    matchups.set_scores
    matchups.order(:rushing_offense_score).each do |matchup|
      rushing_offense_score = matchup.rushing_offense_score rescue 0.0
      rushing_defense_score = matchup.rushing_defense_score rescue 0.0
      matchups_hash[matchup.team] = {
        game: matchup.game,
        rushing_offense_score: rushing_offense_score,
        rushing_defense_score: rushing_defense_score
      }
    end

    puts "Matchups"

    matchups_hash.each do |k,v|
      puts v[:game]
      puts v[:rushing_offense_score]
      puts v[:rushing_defense_score]
    end
  end

  def set_rushing_offense_score
    qb_rushing          = 0.8 * qb.rushing_grade rescue 60
    rb_rushing          = 1.2 * rb.rushing_grade rescue 60
    oline_blocking      = 1.0 * (oline.sum { |line| line.run_block_grade rescue 60 } / oline.count).to_i
    receivers_blocking  = 0.8 * (receivers.sum { |receiver| receiver.run_block_grade } / receivers.count).to_i

    # Rushing Tandem RB + QB
    rush_score = rushing_tandem.sum { |p| p.rushing_grade rescue 50 } / rushing_tandem.size
    # blocking grade
    update(rush_score: rush_score)
    # oline grades
    interior_grade = interior_oline.sum { |p| p.run_block_grade rescue 60 } / interior_oline.size
    exterior_grade = exterior_oline.sum { |p| p.run_block_grade rescue 60 } / exterior_oline.size
    # blocking grade
    update(interior_rush_block_score: interior_grade)
    update(exterior_rush_block_score: exterior_grade)
    # Update Rushing Off Score
    update(
      rushing_offense_score: (qb_rushing + rb_rushing + oline_blocking + receivers_blocking),
      rushing_offense_score_string: "QB-#{qb_rushing}|RB-#{rb_rushing}|OLINE-#{oline_blocking}|REC-#{receivers_blocking}"
    )
  end

  def set_rushing_defense_score
    dline_rushing_defense       = 1.5 * (dline.sum { |line| line.rush_defense_grade } / dline.count).to_i
    linebackers_rushing_defense = 1.0 * (linebackers.sum { |line| line.rush_defense_grade } / linebackers.count).to_i
    secondary_rushing_defense   = 0.8 * (secondary.sum { |line| line.rush_defense_grade } / secondary.count).to_i


    # Dline grades
    interior_grade = defensive_ends
    .sort_by { |player| -player.rush_defense_grade }
    .sum { |p| p.rush_defense_grade rescue 60 } / defensive_ends.size
    exterior_grade = edge_rushers
    .sort_by { |player| -player.rush_defense_grade }
    .sum { |p| p.rush_defense_grade rescue 60 } / edge_rushers.size
    linebacker_grade = linebackers
    .sort_by { |player| -player.rush_defense_grade }
    .sum { |p| p.rush_defense_grade rescue 60 } / edge_rushers.size
    safeties_grade = safeties
    .sort_by { |player| -player.rush_defense_grade }
    .sum { |p| p.rush_defense_grade rescue 60 } / edge_rushers.size
    # blocking grade
    update(interior_rush_defense_score: interior_grade)
    update(exterior_rush_defense_score: exterior_grade)
    update(linebacker_rush_defense_score: linebacker_grade)
    update(safety_rush_defense_score: safeties_grade)

    # Update Rushing Def Score
    update(
      rushing_defense_score: (dline_rushing_defense + linebackers_rushing_defense + secondary_rushing_defense),
      rushing_defense_score_string: "DL-#{dline_rushing_defense}|LB-#{linebackers_rushing_defense}|DB-#{secondary_rushing_defense}"
    )
  end

  def set_passing_offense_score
    qb_passing          = 4.0 * qb.passing_grade rescue 60
    # Most Impactful Rushing Players
    update(reciever_factors: top_three_receivers.map { |player| "#{player.receiving_grade.to_i} #{player.last_name}" })
    oline_holes = oline.sort_by { |player| -player.pass_block_grade rescue 60 }.last(2)
    # Most Impactful Coverage Players
    update(pass_block_factors: oline_holes.map { |player| "#{player.pass_block_grade.to_i} #{player.last_name}" unless player.nil? })
    # WRs + TE
    receiver1 = top_three_receivers.first
    receiver2 = top_three_receivers.second
    receiver3 = top_three_receivers.third
    rec1_receiving      = 1.75 * receiver1.receiving_grade
    rec2_receiving      = 1.00 * receiver2.receiving_grade
    rec3_receiving      = 0.70 * receiver3.receiving_grade
    # Set scores
    update(passer_score: qb_passing)
    update(reciever_score: rec1_receiving + rec2_receiving + rec3_receiving)
    # RB + OLINE
    rb_passing          = 0.5 * rb.offense_grade rescue 60
    oline_passing       = 2.0 * (oline.sum { |line| line.pass_block_grade rescue 60 } / oline.count).to_i
    # oline grades
    interior_grade = interior_oline.sum { |p| p.pass_block_grade rescue 60 } / interior_oline.size
    exterior_grade = exterior_oline.sum { |p| p.pass_block_grade rescue 60 } / exterior_oline.size
    # blocking grade
    update(interior_pass_block_score: interior_grade)
    update(exterior_pass_block_score: exterior_grade)
    # Set Pass blocking score
    update(pass_block_score: oline_passing + rb_passing)
    # Update Rushing Off Score
    update(
      passing_offense_score: (qb_passing + rec1_receiving + rec2_receiving + rec3_receiving + rb_passing + oline_passing),
      passing_offense_score_string: "QB-#{qb_passing}|REC1-#{rec1_receiving}|REC2-#{rec2_receiving}|REC3-#{rec3_receiving}|RB-#{rb_passing}|OLINE-#{oline_passing}"
    )
  end

  def set_passing_defense_score
    # Most Impactful Rushing Players
    update(sack_factors: pass_rush.map { |player| "#{player.pass_rush_grade.to_i} #{player.last_name}" })
    # Most Impactful Coverage Players
    update(coverage_factors: nickle_package.map { |player| "#{player.coverage_grade.to_i} #{player.last_name}" })
    
    # Calculate sack score
    rusher1 = 3.0 * (pass_rush.first.pass_rush_grade rescue 60)
    rusher2 = 2.0 * (pass_rush.second.pass_rush_grade rescue 60)
    rusher3 = 1.2 * (pass_rush.third.pass_rush_grade rescue 60)
    rusher4 = 0.8 * (pass_rush.fourth.pass_rush_grade rescue 60)
    update(sack_score: rusher1 + rusher2 + rusher3 + rusher4)
    # dline grades
    interior_grade = defensive_ends.sum { |p| p.pass_rush_grade rescue 60 } / defensive_ends.size
    exterior_grade = edge_rushers.sum { |p| p.pass_rush_grade rescue 60 } / edge_rushers.size
    # blocking grade
    update(interior_rush_score: interior_grade)
    update(exterior_rush_score: exterior_grade)
    # Calculate coverage score
    weakest_db_score = nickle_package.last.coverage_grade
    average_db_score = (nickle_package.sum {|db| db.coverage_grade}) / nickle_package.count
    coverage_score = 1.5 * (average_db_score - (0.5 * (average_db_score - weakest_db_score)))
    update(coverage_score: coverage_score)
    # oline grades
    lb_grade = linebackers.sum { |p| p.coverage_grade rescue 60 } / linebackers.size
    ss_grade = safeties.sum { |p| p.coverage_grade rescue 60 } / safeties.size
    cb_grade = cornerbacks.sum { |p| p.coverage_grade rescue 60 } / cornerbacks.size
    # blocking grade
    update(linebacker_coverage_score: lb_grade)
    update(safety_coverage_score: ss_grade)
    update(corner_coverage_score: cb_grade)
  end

  def calculate_tier(score_column)
    matchups = Matchup.where(season: 2025, week_slug: 1).order(score_column => :desc)
    total = matchups.count
    rank = matchups.index(self) + 1
    case rank.to_f / total
    when 0...0.15
      "S"
    when 0.15...0.4
      "A"
    when 0.4...0.6
      "B"
    when 0.6...0.8
      "C"
    when 0.8...0.9
      "D"
    else
      "F"
    end
  end

  def rush_tier
    calculate_tier(:rush_score)
  end
  def interior_rush_block_tier
    calculate_tier(:interior_rush_block_score)
  end
  def exterior_rush_block_tier
    calculate_tier(:exterior_rush_block_score)
  end
  def interior_rush_defense_tier
    calculate_tier(:interior_rush_defense_score)
  end
  def exterior_rush_defense_tier
    calculate_tier(:exterior_rush_defense_score)
  end
  def linebacker_rush_defense_tier
    calculate_tier(:linebacker_rush_defense_score)
  end
  def safety_rush_defense_tier
    calculate_tier(:safety_rush_defense_score)
  end
  def corner_rush_defense_tier
    calculate_tier(:corner_rush_defense_score)
  end

  def passer_tier
    calculate_tier(:passer_score)
  end

  def reciever_tier
    calculate_tier(:reciever_score)
  end

  def pass_block_tier
    calculate_tier(:pass_block_score)
  end

  def interior_pass_block_tier
    calculate_tier(:interior_pass_block_score)
  end

  def exterior_pass_block_tier
    calculate_tier(:exterior_pass_block_score)
  end

  def interior_rush_tier
    calculate_tier(:interior_rush_score)
  end
  def exterior_rush_tier
    calculate_tier(:exterior_rush_score)
  end
  def linebacker_coverage_tier
    calculate_tier(:linebacker_coverage_score)
  end
  def safety_coverage_tier
    calculate_tier(:safety_coverage_score)
  end
  def corner_coverage_tier
    calculate_tier(:corner_coverage_score)
  end

  def sack_tier
    calculate_tier(:sack_score)
  end

  def coverage_tier
    calculate_tier(:coverage_score)
  end
  def passer_range
    matchups = Matchup.where(season: 2025, week_slug: 1).order(passer_score: :desc)
    return matchups.first(2).last.passer_score, matchups.last(2).first.passer_score
  end

  def offense_starters
    Player.where(slug: [self.o1, self.o2, self.o3, self.o4, self.o5, self.o6, self.o7, self.o8, self.o9, self.o10, self.o11])
    # [self.o1, self.o2, self.o3, self.o4, self.o5, self.o6, self.o7, self.o8, self.o9, self.o10, self.o11].filter_map { |slug| Player.find_by_slug(slug) }
  end

  def qb
    Player.find_by_slug(self.o1)
  end

  def rb
    Player.find_by_slug(self.o2)
  end

  def full_backs
    offense_starters.filter_map { |player| player if player.slug&.start_with?("full_back") }
  end

  def running_backs
    offense_starters.filter_map { |player| player if player.slug&.start_with?("running_back") }
  end

  def wide_receivers
    offense_starters.filter_map { |player| player if player.slug&.start_with?("wide_receiver") }
  end

  def tight_ends
    offense_starters.filter_map { |player| player if player.slug&.start_with?("tight_end") }
  end

  # def fullbacks
  #   [] # Add logic if fullbacks are included in the dataset
  # end

  def receivers
    wide_receivers + tight_ends
  end

  def skill_positions
    full_backs + running_backs  + receivers
  end

  def oline
    interior_oline + exterior_oline
  end

  def center
    offense_starters
    .where(position: [:center])
    .limit(1).first
  end

  def guards
    offense_starters
    .where(position: [:gaurd])
    .limit(2)
  end

  def tackles
    offense_starters
    .where(position: [:tackle])
    .limit(2)
  end

  def interior_oline
    offense_starters
    .where(position: [:gaurd, :center])
    .limit(3)
  end

  def exterior_oline
    offense_starters
    .where(position: [:tackle])
    .limit(2)
  end

  def rushing_tandem
    offense_starters
    .where(position: [:runningback, :quarterback])
    .limit(2)
  end

  def defense_starters
    Player.where(slug: [self.d1, self.d2, self.d3, self.d4, self.d5, self.d6, self.d7, self.d8, self.d9, self.d10, self.d11])
      # .where("pass_rush_grade > ?", 70) # Filter players with pass_rush_grade > 70
      # .order(pass_rush_grade: :desc)   # Order by pass_rush_grade descending
      # .limit(2)                        # Limit to top 2 players
  end

  # Edge Rushers, 2, Pass Rush
  def edge_rushers
    defense_starters
    .where(position: [:edge_rusher])
    .limit(2)
  end

  # Defensive Ends, 2, Pass Rush
  def defensive_ends
    defense_starters
    .where(position: [:defensive_end])
    .limit(2)
  end

  def dline
    defensive_ends + edge_rushers
  end

  # Linebackers, 2, Defence grade
  def linebackers
    defense_starters
    .where(position: [:linebackers])
    .limit(2)
  end

  def cornerbacks
    defense_starters
    .where(position: [:cornerback])
    .limit(2)
  end

  def safeties
    defense_starters
    .where(position: [:safeties])
    .limit(2)
  end

  def secondary
    cornerbacks + safeties
  end

  def back_7
    secondary + linebackers
  end

  def top_three_receivers
    offense_starters
    .where(position: [:wide_receiver, :tight_end])
    .order_receiving
    .limit(3)
  end

  def nickle_package
    secondary
      .filter_map { |player| player if player.coverage_grade }
      .sort_by { |player| -player.coverage_grade }
      .first(5)
  end

  def pass_rush
    dline
      .filter_map { |player| player if player.pass_rush_grade }
      .sort_by { |player| -player.pass_rush_grade }
      .first(2)
  end

  def index_grade
    puts "=QB=============="
    puts qb.slug
    puts "🏈 #{qb.passing_grade}  🏃 #{qb.rushing_grade} 🙌 #{qb.receiving_grade}"
    puts "---------------"
    puts "=O-LINE=============="
    oline.each do |blocker|
      puts blocker.slug
      puts "🏈 #{blocker.pass_block_grade}  🏃 #{blocker.run_block_grade}"
    end
    puts "=RB=============="
    puts rb.slug
    puts "🏈 #{rb.pass_block_grade}  🏃 #{rb.rushing_grade} 🙌 #{rb.receiving_grade}"
    puts "---------------"
    puts "=Receivers=============="
    receivers.each do |receiver|
      puts receiver.slug
      puts "🏈 #{receiver.receiving_grade}  🏃 #{receiver.run_block_grade}"
    end
    puts "=D-Line=============="
    dline.each do |rusher|
      puts rusher.slug
      puts "🏈 #{rusher.pass_rush_grade}  🏃 #{rusher.rush_defense_grade} 🙌 #{rusher.coverage_grade}"
    end
    puts "=Linebackers=============="
    linebackers.each do |lb|
      puts lb.slug
      puts "🏈 #{lb.pass_rush_grade}  🏃 #{lb.rush_defense_grade} 🙌 #{lb.coverage_grade}"
    end
    puts "=Secondary=============="
    secondary.each do |back|
      puts back.slug
      puts "🏈 #{back.pass_rush_grade}  🏃 #{back.rush_defense_grade} 🙌 #{back.coverage_grade}"
    end
  end

  def tier_class(tier)
    case tier
    when "S"
      "bg-green-500 hover:bg-green-600 text-white"
    when "A"
      "bg-green-200 hover:bg-green-300 text-green-800"
    when "B"
      "bg-green-100 hover:bg-green-200 text-green-700"
    when "C"
      "bg-red-100 hover:bg-red-200 text-red-800"
    when "D"
      "bg-red-300 hover:bg-red-400 text-red-900"
    when "F"
      "bg-red-500 hover:bg-red-600 text-white"
    else
      ""
    end
  end

  def tier_class_offense(tier)
    case tier
    when "S"
      "bg-green-500 hover:bg-green-600 text-white bold border-2 border-solid border-green-600"
    when "A"
      "bg-green-400 hover:bg-green-500 text-white"
    when "B"
      "bg-green-300 hover:bg-green-400 text-green-800"
    when "C"
      "bg-green-200 hover:bg-green-300 text-green-700"
    when "D"
      "bg-gray-200 hover:bg-gray-300 text-green-700"
    when "F"
      "bg-orange-200 hover:bg-orange-300 text-gray-500"
    else
      ""
    end
  end

  def tier_class_defense(tier)
    case tier
    when "S"
      "bg-gray-200 hover:bg-gray-300 text-black"
    when "A"
      "bg-red-300 hover:bg-red-400 text-green-900"
    when "B"
      "bg-red-200 hover:bg-red-300 text-green-700"
    when "C"
      "bg-red-300 hover:bg-red-400 text-red-700"
    when "D"
      "bg-red-400 hover:bg-red-500 text-white"
    when "F"
      "bg-red-500 hover:bg-red-600 text-white"
    else
      ""
    end
  end

  # Stack error
  # def kicker
  #   Player.find_by_slug(self.place_kicker) # Replace `k1` with the actual key for kicker if available
  # end

  # def punter
  #   Player.find_by_slug(self.punter) # Replace `p1` with the actual key for punter if available
  # end
end