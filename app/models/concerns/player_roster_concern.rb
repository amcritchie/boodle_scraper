module PlayerRosterConcern
  extend ActiveSupport::Concern

  # Class method to collect all offensive line players from all matches
  def self.all_oline_players
    # Collect all offensive line player slugs from matchups
    matchup_oline_slugs = Matchup.pluck(:c, :lt, :rt, :lg, :rg).flatten.compact.uniq
    
    # Collect all offensive line player slugs from teams_weeks
    teams_week_oline_slugs = TeamsWeek.pluck(:c, :lt, :rt, :lg, :rg).flatten.compact.uniq
    
    # Combine and deduplicate all slugs
    all_oline_slugs = (matchup_oline_slugs + teams_week_oline_slugs).uniq
    
    # Return the actual Player objects
    Player.where(slug: all_oline_slugs)
  end

  # Individual player methods
  def qb_player
    Player.find_by_slug(qb)
  end

  def rb1_player
    Player.find_by_slug(rb1)
  end

  def rb2_player
    Player.find_by_slug(rb2)
  end

  def wr1_player
    Player.find_by_slug(wr1)
  end

  def wr2_player
    Player.find_by_slug(wr2)
  end

  def wr3_player
    Player.find_by_slug(wr3)
  end

  def te_player
    Player.find_by_slug(te)
  end

  def center_player
    Player.find_by_slug(c)
  end

  def left_tackle_player
    Player.find_by_slug(lt)
  end

  def right_tackle_player
    Player.find_by_slug(rt)
  end

  def left_guard_player
    Player.find_by_slug(lg)
  end

  def right_guard_player
    Player.find_by_slug(rg)
  end

  def edge1_player
    Player.find_by_slug(eg1)
  end

  def edge2_player
    Player.find_by_slug(eg2)
  end

  def dl1_player
    Player.find_by_slug(dl1)
  end

  def dl2_player
    Player.find_by_slug(dl2)
  end

  def dl3_player
    Player.find_by_slug(dl3)
  end

  def lb1_player
    Player.find_by_slug(lb1)
  end

  def lb2_player
    Player.find_by_slug(lb2)
  end

  def cb1_player
    Player.find_by_slug(cb1)
  end

  def cb2_player
    Player.find_by_slug(cb2)
  end

  def cb3_player
    Player.find_by_slug(cb3)
  end

  def safety1_player
    Player.find_by_slug(s1)
  end

  def safety2_player
    Player.find_by_slug(s2)
  end

  def place_kicker_player
    Player.find_by_slug(place_kicker)
  end

  def punter_player
    Player.find_by_slug(punter)
  end

  # Collection methods
  def offense_starters
    Player.where(slug: [qb, rb1, rb2, wr1, wr2, wr3, te, c, lt, rt, lg, rg].compact)
  end

  def defense_starters
    Player.where(slug: [eg1, eg2, dl1, dl2, dl3, lb1, lb2, cb1, cb2, cb3, s1, s2].compact)
  end

  def rushers
    Player.where(slug: [qb, rb1, rb2].compact)
  end

  def receivers
    Player.where(slug: [wr1, wr2, wr3, te].compact)
  end

  def oline_players
    slugs = [lt, lg, c, rg, rt].compact
    players = Player.where(slug: slugs)
    # Sort players to match the order of slugs in the original array
    players.sort_by { |player| slugs.index(player.slug) }
  end

  def edge_players
    Player.where(slug: [eg1, eg2].compact)
  end

  def dinterior_players
    Player.where(slug: [dl1, dl2, dl3].compact).sort_by { |player| -(player.rush_defense_grade_x || 0) }
  end

  def dline_players
    Player.where(slug: [eg1, eg2, dl1, dl2, dl3].compact)
  end

  def pass_rush_players
    Player.where(slug: dline_players.sort_by { |player| -(player.pass_rush_grade_x || 0) }.pluck(:slug))
  end

  def linebacker_players
    Player.where(slug: [lb1, lb2].compact).sort_by { |player| -(player.rush_defense_grade_x || 0) }
  end

  def corner_back_players
    Player.where(slug: [cb1, cb2, cb3]).sort_by { |player| -(player.coverage_grade_x || 0) }
  end

  def safety_players
    Player.where(slug: [s1, s2]).sort_by { |player| -(player.coverage_grade_x || 0) }
  end

  def secondary_players
    Player.where(slug: [cb1, cb2, cb3, s1, s2].compact)
  end

  def rushing_players
    # Get all potential rushing players and sort by rushing grade
    potential_rushers = [rb1_player, rb2_player, qb_player].compact
    potential_rushers.sort_by { |player| -(player.rush_grade_x || 0) }.first(2)
  end



  def full_backs
    offense_starters.filter_map { |player| player if player.slug&.start_with?("full_back") }
  end

  def running_backs
    offense_starters.filter_map { |player| player if player.slug&.start_with?("running_back") }
  end

  def wide_receivers
    offense_starters.filter_map { |player| player if player.position == "wide-receiver" }
  end

  def tight_ends
    offense_starters.filter_map { |player| player if player.position == "tight-end" }
  end

  def skill_positions
    full_backs + running_backs + receivers
  end

  def oline
    interior_oline + exterior_oline
  end

  def center
    offense_starters.where(position: [:center]).limit(1).first
  end

  def guards
    offense_starters.where(position: [:gaurd]).limit(2)
  end

  def tackles
    offense_starters.where(position: [:tackle]).limit(2)
  end

  def interior_oline
    offense_starters.where(position: [:gaurd, :center]).limit(3)
  end

  def exterior_oline
    offense_starters.where(position: [:tackle]).limit(2)
  end

  def rushing_tandem
    offense_starters.where(position: [:runningback, :quarterback]).limit(2)
  end

  def edge_rushers
    defense_starters.where(position: ['edge-rusher']).limit(2)
  end

  def defensive_ends
    defense_starters.where(position: ['defensive-end']).limit(2)
  end

  def dline
    defensive_ends + edge_rushers
  end

  def linebackers
    defense_starters.where(position: ['linebacker']).limit(2)
  end

  def cornerbacks
    defense_starters.where(position: ['cornerback']).limit(2)
  end

  def safeties
    defense_starters.where(position: ['safety']).limit(2)
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
      .by_grades_pass_route
      .limit(3)
  end

  def nickle_package
    secondary
      .filter_map { |player| player if player.grades_coverage }
      .sort_by { |player| -player.grades_coverage }
      .first(5)
  end

  def pass_rush
    dline
      .filter_map { |player| player if player.grades_pass_rush }
      .sort_by { |player| -player.grades_pass_rush }
      .first(2)
  end
end
