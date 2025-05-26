class Matchup < ApplicationRecord
#   belongs_to :team

  validates :season, :week, :game, :team, presence: true

  # Add methods to fetch offensive and defensive players if needed

  def self.phi
    find_by(season: 2025, week: 1, team: :phi)
  end

  def self.ari
    find_by(season: 2025, week: 1, team: :ari)
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
    where(week: 1)
  end

  def self.w2
    where(week: 2)
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
      self.team,
      self.passing_offense_score,
      self.passing_offense_score_string
    )
  end

  def pass_def_summary(index)
    # Format: Rank (2 chars), Team (3 chars), Sack Score (3 chars), Sack Factors, Coverage Score (3 chars), Coverage Factors
    formatted_summary = sprintf(
      "#%-2d %-3s %-3d %-40s %-3d %-20s",
      index,
      self.team_defense,
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
    matchups = Matchup.where(season: 2025, week: 1)
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
    # Update Rushing Def Score
    update(
      rushing_defense_score: (dline_rushing_defense + linebackers_rushing_defense + secondary_rushing_defense),
      rushing_defense_score_string: "DL-#{dline_rushing_defense}|LB-#{linebackers_rushing_defense}|DB-#{secondary_rushing_defense}"
    )
  end

  def set_passing_offense_score
    qb_passing          = 4.0 * qb.passing_grade rescue 60
    # WRs + TE
    receiver1 = top_three_receivers.first
    receiver2 = top_three_receivers.second
    receiver3 = top_three_receivers.third
    rec1_receiving      = 1.75 * receiver1.receiving_grade
    rec2_receiving      = 1.00 * receiver2.receiving_grade
    rec3_receiving      = 0.70 * receiver3.receiving_grade
    # RB + OLINE
    rb_passing          = 0.5 * rb.offense_grade rescue 60
    oline_passing       = 2.0 * (oline.sum { |line| line.pass_block_grade rescue 60 } / oline.count).to_i
    # Update Rushing Off Score
    update(
      passing_offense_score: (qb_passing + rec1_receiving + rec2_receiving + rec3_receiving + rb_passing + oline_passing),
      passing_offense_score_string: "QB-#{qb_passing}|REC1-#{rec1_receiving}|REC2-#{rec2_receiving}|REC3-#{rec3_receiving}|RB-#{rb_passing}|OLINE-#{oline_passing}"
    )
  end

  def set_passing_defense_score
    # Most Impactful Rushing Players
    update(sack_factors: pass_rush.map { |player| "#{player.last_name} #{player.pass_rush_grade}" })
    # Most Impactful Coverage Players
    update(coverage_factors: nickle_package.map { |player| "#{player.last_name} #{player.coverage_grade}" })
    
    # Calculate sack score
    rusher1 = 3.0 * (pass_rush.first.pass_rush_grade rescue 60)
    rusher2 = 2.0 * (pass_rush.second.pass_rush_grade rescue 60)
    rusher3 = 1.2 * (pass_rush.third.pass_rush_grade rescue 60)
    rusher4 = 0.8 * (pass_rush.fourth.pass_rush_grade rescue 60)
    update(sack_score: rusher1 + rusher2 + rusher3 + rusher4)

    # Calculate coverage score
    weakest_db_score = nickle_package.last.coverage_grade
    average_db_score = (nickle_package.sum {|db| db.coverage_grade}) / nickle_package.count
    coverage_score = 1.5 * (average_db_score - (0.5 * (average_db_score - weakest_db_score)))
    update(coverage_score: coverage_score)
  end

  def offense_starters
    [self.o1, self.o2, self.o3, self.o4, self.o5, self.o6, self.o7, self.o8, self.o9, self.o10, self.o11].filter_map { |slug| Player.find_by_slug(slug) }
  end

  def qb
    Player.find_by_slug(self.o1)
  end

  def rb
    Player.find_by_slug(self.o2)
  end

  def wide_receivers
    offense_starters.filter_map { |player| player if player.slug&.start_with?("wide_receiver") }
  end

  def tight_ends
    offense_starters.filter_map { |player| player if player.slug&.start_with?("tight_end") }
  end

  def fullbacks
    [] # Add logic if fullbacks are included in the dataset
  end

  def receivers
    wide_receivers + tight_ends
  end

  def oline
    [center] + guards + tackles
  end

  def center
    Player.find_by_slug(self.o7)
  end

  def guards
    offense_starters.filter_map { |player| player if player.slug&.start_with?("gaurd") }
  end

  def tackles
    offense_starters.filter_map { |player| player if player.slug&.start_with?("tackle") }
  end

  def defense_starters
    [self.d1, self.d2, self.d3, self.d4, self.d5, self.d6, self.d7, self.d8, self.d9, self.d10, self.d11].filter_map { |slug| Player.find_by_slug(slug) }
  end

  # Edge Rushers, 2, Pass Rush
  def edge_rushers
    defense_starters
    .filter_map { |player| player if player.slug&.start_with?("edge_rusher") }
    .sort_by { |player| -player.pass_rush_grade }
    .first(2)
  end

  # Defensive Ends, 2, Pass Rush
  def defensive_ends
    defense_starters.filter_map { |player| player if player.slug&.start_with?("defensive_end") }
    .sort_by { |player| -player.pass_rush_grade }
    .first(2)
  end

  def dline
    defensive_ends + edge_rushers
  end

  # Linebackers, 2, Defence grade
  def linebackers
    defense_starters.filter_map { |player| player if player.slug&.start_with?("linebackers") }
    .sort_by { |player| -player.defence_grade }
    .first(2)
  end

  def cornerbacks
    defense_starters.filter_map { |player| player if player.slug&.start_with?("cornerback") }
  end

  def safeties
    defense_starters.filter_map { |player| player if player.slug&.start_with?("safeties") }
  end

  def secondary
    cornerbacks + safeties
  end

  def back_7
    secondary + linebackers
  end

  def top_three_receivers
    offense_starters
      .filter_map { |player| player if player.receiving_grade }
      .sort_by { |player| -player.receiving_grade }
      .first(3)
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

  # Stack error
  # def kicker
  #   Player.find_by_slug(self.place_kicker) # Replace `k1` with the actual key for kicker if available
  # end

  # def punter
  #   Player.find_by_slug(self.punter) # Replace `p1` with the actual key for punter if available
  # end
end