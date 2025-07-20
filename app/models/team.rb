require 'csv'
require 'httparty'

class Team < ApplicationRecord
    extend TeamMapping
    include TeamPopulations
    include TeamGrades
    include PffConcern
    
    has_many :players, foreign_key: :team_slug, primary_key: :slug
    has_many :coaches, foreign_key: :team_slug, primary_key: :slug

    def self.active
        where(active: true)
    end
    def self.afc
        where(conference: :afc)
    end
    def self.nfc
        where(conference: :nfc)
    end
    def description
      "#{self.emoji} #{self.name}"
    end
    def matchup
      Matchup.find_by(season: 2025, week: 1, team_slug: slug)
    end
    def matchup_def
      Matchup.find_by(season: 2025, week: 1, team_defense_slug: slug)
    end

    def self.kaggle_import_teams
      # Parse CSV
      csv_text = File.read('lib/kaggle/nfl_teams.csv')
      csv = CSV.parse(csv_text, headers: true)
      # Each through rows in CSV
      csv.each do |row|
          # Get team attributes from row
          team_attrs = row.to_hash
          team_name = team_attrs['team_name']
          # Skip inactive teams
          next if ["Tennessee Oilers","St. Louis Rams","St. Louis Cardinals","Phoenix Cardinals","Houston Oilers","Boston Patriots","Washington Football Team", "Washington Redskins", "San Diego Chargers", "Los Angeles Raiders", "Oakland Raiders", "Baltimore Colts"].include?(team_name)
          # Find or create Kaggle Team
          team = Team.kaggle_team(team_name)
          # Populate team general team data e.g., 🦬, buf
          team.populate

          # Update team name and other data based on Kaggle
          team.name = team_attrs['team_name']
          team.alias = team_attrs['team_name_short']
          team.conference = team_attrs['team_conference']
          team.division = team_attrs['team_division']
          team.slug_pfr = team_attrs['team_id_pfr']
          team.division_pre_2002 = team_attrs['team_division_pre2002']
          team.conference_pre_2002 = team_attrs['team_conference_pre2002']

          # Denote team as active not active if they don't have a division or other criteria.
          team.active = false if team.division.nil? || team.division.empty?
          team.active = false if team.name == "Washington Football Team"
          team.active = false if team.name == "Washington Redskins"
          team.active = false if team.name == "San Diego Chargers"
          team.active = false if team.name == "Los Angeles Raiders"
          team.active = false if team.name == "Oakland Raiders"

          # Save team
          team.save
          # Output team saved
          puts "🏈 #{team.conference.ljust(4)} | #{team.division.ljust(10)} | (#{team.slug.ljust(4)}) #{team.name.ljust(22)} Saved" if team.active
      end
  end

    def fetch_roster_sportradar

      api_key = 'dBqzgfZiBp0sTpz06FIx3AjcLzCA2EzwFID6ZCl0' # amcr
      # api_key = 'xtsJqdNDRcvoGeXZ5kcG7iVYVJkpX4umc8bxIoGh' # free@b
      # api_key = 'HmAyXEUSsvWllyEVSCaniv3cnq8cLxKExAr2oAQD' # laurenalexm@g
      # api_key = 'c9IaDr6BFd7tSrQdEDbtIclRe6gqHexujsLdevJw' # alex@boodle

      # "0d855753-ea21-4953-89f9-0e20aff9eb73"
      response = HTTParty.get(
        "https://api.sportradar.com/nfl/official/trial/v7/en/teams/#{sportsradar_id}/full_roster.json",
        headers: {
          'accept' => 'application/json',
          'x-api-key' => api_key
        }
      )
      
      if response.success?
        team_sportsradar = JSON.parse(response.body)

        team_sportsradar["venue"]
        team_sportsradar["coaches"]
        team_sportsradar["players"]

        # # Hardcoded starting QB slugs for 2025 season
        # starting_qb_slugs = [
        #   'quarterback-patrick-mahomes',  # AFC West
        #   'quarterback-bo-nix',
        #   'quarterback-justin-herbert',
        #   'quarterback-geno-smith',
        #   'quarterback-josh-allen',       # AFC East
        #   'quarterback-drake-maye',
        #   'quarterback-tua-tagovailoa',
        #   'quarterback-justin-fields',
        #   'quarterback-lamar-jackson',    # AFC North
        #   'quarterback-joe-burrow',
        #   'quarterback-aaron-rodgers',
        #   'quarterback-joe-flacco',
        #   'quarterback-cj-stroud',        # AFC South
        #   'quarterback-trevor-lawrence',
        #   'quarterback-will-levis',
        #   'quarterback-daniel-jones',
        #   'quarterback-jared-goff',        # NFC North
        #   'quarterback-jordan-love',
        #   'quarterback-caleb-williams',
        #   'quarterback-jj-mccarthy',
        #   'quarterback-bryce-young',      # NFC South
        #   'quarterback-baker-mayfield',
        #   'quarterback-michael-penix-jr',
        #   'quarterback-tyler-shough',
        #   'quarterback-dak-prescott',     # NFC East
        #   'quarterback-jalen-hurts',
        #   'quarterback-jayden-daniels',
        #   'quarterback-russell-wilson',
        #   'quarterback-brock-purdy',      # NFC West
        #   'quarterback-kyler-murray',
        #   'quarterback-matthew-stafford',
        #   'quarterback-sam-darnold'
        # ]

        # # Hardcoded starting QB slugs for 2025 season
        # left_handed_qb_slugs = [
        #   'quarterback-tua-tagovailoa',
        #   'quarterback-michael-penix-jr'
        # ]

        # Each through players
        team_sportsradar["players"].each do |player_sportsradar|
          # Find or create player
          player = Player.sportsradar_find_or_create(player_sportsradar, self.slug)
          
          # # Mark as starter if QB slug is in the starter list
          # player.update(starter: true) if starting_qb_slugs.include?(player.slug)
        end

        # Process coaches
        team_sportsradar["coaches"].each do |coach_sportsradar|
          slug = [coach_sportsradar["position"], coach_sportsradar["first_name"], coach_sportsradar["last_name"]].compact.join('-').parameterize
          coach = Coach.find_or_create_by(slug: slug)
          coach.update(
            team_slug: self.slug,
            season: 2025, # You may want to make this dynamic
            sportsradar_id: coach_sportsradar["id"],
            first_name: coach_sportsradar["first_name"],
            last_name: coach_sportsradar["last_name"],
            position: coach_sportsradar["position"]
          )
          # puts "Coach: #{coach.position} - #{coach.first_name} #{coach.last_name} (slug: #{coach.slug})"
        end
      else
        puts "Response: #{response.code}"
        puts "Response: #{response.body}"
        puts "--------------------------------"
        sleep(30)
      end
    end

    def offense_starters_prediction
      # Find team's players 
      teammates = Player.by_team(slug)
      # Return collection
      return {
        quarterback:    self.starting_qb,
        runningbacks:    self.starting_rbs,
        wide_receivers: self.starting_wrs,
        tight_end:      self.starting_te,
        # flex:           self.starting_flex_offense,
        oline:          self.starting_oline
      }
    end

    def defense_starters_prediction
      # Find team's players 
      teammates = Player.by_team(slug)
      # Return collection
      return {
        edge_rushers: self.starting_edge_rushers,  
        defensive_ends: self.starting_defensive_ends,
        flex_dline: self.starting_flex_dline,
        linebackers: self.starting_linebackers,
        cornerbacks: self.starting_cornerbacks,
        safeties: self.starting_safeties
      }
    end

    def generate_matchup(week=1,season=2025)
      puts "Generating matchup for #{slug} in week #{week} of season #{season}"
      ap Game.find_by(season: season, week_slug: week)
      puts "Generating matchup for #{slug} in week #{week} of season #{season}"
      # Find game and evaluate if team is playing at home
      if game = Game.find_by(season: season, week_slug: week, home_slug: slug)
          home = true
      elsif game = Game.find_by(season: season, week_slug: week, away_slug: slug)
          home = false
      else
          raise "Game not found"
      end
      
      # Get TeamsSeason snapshot for this team
      teams_season = TeamsSeason.find_by(team_slug: slug, season_year: season)
      
      # Find or create roster
      matchup = Matchup.find_or_create_by(game: game.slug, team_slug: slug)
      
      if teams_season
        # Use TeamsSeason snapshot data
        if home
          # Home team - use this team's offense and opponent's defense
          opponent_teams_season = TeamsSeason.find_by(team_slug: game.away_team.slug, season_year: season)
          matchup.update(
            season: season,
            week_slug: week.to_s,
            home: home,
            # Offensive players
            qb: teams_season.qb,
            rb1: teams_season.rb1,
            rb2: teams_season.rb2,
            wr1: teams_season.wr1,
            wr2: teams_season.wr2,
            wr3: teams_season.wr3,
            te: teams_season.te,
            c: teams_season.c,
            lt: teams_season.lt,
            rt: teams_season.rt,
            lg: teams_season.lg,
            rg: teams_season.rg,
            # Defensive players
            eg1: opponent_teams_season&.eg1,
            eg2: opponent_teams_season&.eg2,
            dl1: opponent_teams_season&.dl1,
            dl2: opponent_teams_season&.dl2,
            dl3: opponent_teams_season&.dl3,
            lb1: opponent_teams_season&.lb1,
            lb2: opponent_teams_season&.lb2,
            cb1: opponent_teams_season&.cb1,
            cb2: opponent_teams_season&.cb2,
            cb3: opponent_teams_season&.cb3,
            s1: opponent_teams_season&.s1,
            s2: opponent_teams_season&.s2
          )
        else
          # Away team - use this team's offense and opponent's defense
          opponent_teams_season = TeamsSeason.find_by(team_slug: game.home_team.slug, season_year: season)
          matchup.update(
            season: season,
            week_slug: week.to_s,
            home: home,
            # Offensive players
            qb: teams_season.qb,
            rb1: teams_season.rb1,
            rb2: teams_season.rb2,
            wr1: teams_season.wr1,
            wr2: teams_season.wr2,
            wr3: teams_season.wr3,
            te: teams_season.te,
            c: teams_season.c,
            lt: teams_season.lt,
            rt: teams_season.rt,
            lg: teams_season.lg,
            rg: teams_season.rg,
            # Defensive players
            eg1: opponent_teams_season&.eg1,
            eg2: opponent_teams_season&.eg2,
            dl1: opponent_teams_season&.dl1,
            dl2: opponent_teams_season&.dl2,
            dl3: opponent_teams_season&.dl3,
            lb1: opponent_teams_season&.lb1,
            lb2: opponent_teams_season&.lb2,
            cb1: opponent_teams_season&.cb1,
            cb2: opponent_teams_season&.cb2,
            cb3: opponent_teams_season&.cb3,
            s1: opponent_teams_season&.s1,
            s2: opponent_teams_season&.s2
          )
        end
      else
        # Fallback to dynamic generation if TeamsSeason data not available
        teammates = Player.by_team(slug)
        # Fetch players by position
        qb = teammates.by_position(:quarterback).order(offense_grade: :desc).first
        rb = teammates.by_position(:runningback).order(offense_grade: :desc).first
        wrs = teammates.by_position(:wide_receiver).order(offense_grade: :desc).limit(2)
        te = teammates.by_position(:tight_end).order(offense_grade: :desc).first
        flex = teammates.where(position: [:runningback, :wide_receiver, :tight_end]).order(offense_grade: :desc).where.not(id: ([rb&.id] + wrs.map(&:id) + [te&.id])).first
        center = teammates.by_position(:center).order(offense_grade: :desc).first
        guards = teammates.by_position(:gaurd).order(offense_grade: :desc).limit(2)
        tackles = teammates.by_position(:tackle).order(offense_grade: :desc).limit(2)
        # Defence
        des = teammates.by_position(:defensive_end).order(defence_grade: :desc).limit(2)
        edges = teammates.by_position(:edge_rusher).order(defence_grade: :desc).limit(2)
        lbs = teammates.by_position(:linebackers).order(defence_grade: :desc).limit(2)
        safeties = teammates.by_position(:safeties).order(defence_grade: :desc).limit(2)
        cbs = teammates.by_position(:cornerback).order(defence_grade: :desc).limit(2)
        flex_defense = teammates.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(defence_grade: :desc).where.not(id: (des.map(&:id) + edges.map(&:id) + lbs.map(&:id) + safeties.map(&:id) + cbs.map(&:id))).limit(1)
        
        matchup.update(
            season: season,
            week_slug: week.to_s,
            home: home,
            # Offensive players
            qb: qb&.slug,
            rb1: rb&.slug,
            rb2: flex&.slug, # Using flex as RB2
            wr1: wrs[0]&.slug,
            wr2: wrs[1]&.slug,
            wr3: nil, # Third WR not available in fallback
            te: te&.slug,
            c: center&.slug,
            lg: guards[0]&.slug,
            rg: guards[1]&.slug,
            lt: tackles[0]&.slug,
            rt: tackles[1]&.slug,
            # Defensive players
            eg1: edges[0]&.slug,
            eg2: edges[1]&.slug,
            dl1: des[0]&.slug,
            dl2: des[1]&.slug,
            dl3: flex_defense[0]&.slug, # Using flex as third DL
            lb1: lbs[0]&.slug,
            lb2: lbs[1]&.slug,
            cb1: cbs[0]&.slug,
            cb2: cbs[1]&.slug,
            cb3: nil, # Third CB not available in fallback
            s1: safeties[0]&.slug,
            s2: safeties[1]&.slug
        )
      end
      
      puts "Matchup for Week #{week}, Season #{season} #{name} created successfully!"
      ap matchup
    end

  def self.parse_csv_starting_lineups
    csv_path = Rails.root.join('lib', 'pff', 'starting-lineups-2025.csv')
    return {} unless File.exist?(csv_path)
    
    require 'csv'
    
    team_lineups = {}
    
    CSV.foreach(csv_path, headers: true) do |row|
      team_name = row['Team']
      unit = row['Unit']
      position = row['Position']
      player_name = row['Player']
      grade = row['Grade'].to_f
      
      # Skip if missing essential data
      next if team_name.blank? || position.blank? || player_name.blank?
      
      # Initialize team if not exists
      team_lineups[team_name] ||= { offense: {}, defense: {} }
      
      # Group by unit (Offense/Defense)
      unit_key = unit.downcase.to_sym
      team_lineups[team_name][unit_key] ||= {}
      
      # Group by position
      position_key = position.downcase.to_sym
      team_lineups[team_name][unit_key][position_key] ||= []
      
      # Add player data
      team_lineups[team_name][unit_key][position_key] << {
        name: player_name,
        grade: grade,
        position: position
      }
    end
    
    team_lineups
  end

  def csv_starting_lineup
    @csv_starting_lineup ||= begin
      all_lineups = Team.parse_csv_starting_lineups
      all_lineups[self.name] || {}
    end
  end

  def csv_offense_starters
    csv_starting_lineup[:offense] || {}
  end

  def csv_defense_starters
    csv_starting_lineup[:defense] || {}
  end

  def find_player_by_name(player_name)
    return nil if player_name.blank?
    
    # Try exact match first
    player = players.find_by("LOWER(first_name || ' ' || last_name) = LOWER(?)", player_name)
    return player if player
    
    # Try partial matches
    name_parts = player_name.downcase.split(' ')
    players.find do |p|
      p_first = p.first_name&.downcase
      p_last = p.last_name&.downcase
      
      # Check if all name parts match either first or last name
      name_parts.all? do |part|
        p_first&.include?(part) || p_last&.include?(part)
      end
    end
  end

  def csv_offense_starters_prediction
    offense_data = csv_offense_starters
    
    {
      quarterback: find_player_by_name(offense_data[:qb]&.first&.dig(:name)),
      runningbacks: offense_data[:rb]&.map { |rb| find_player_by_name(rb[:name]) }&.compact || [],
      wide_receivers: offense_data[:wr]&.map { |wr| find_player_by_name(wr[:name]) }&.compact || [],
      tight_end: find_player_by_name(offense_data[:te]&.first&.dig(:name)),
      oline: csv_oline_starters
    }
  end

  def csv_defense_starters_prediction
    defense_data = csv_defense_starters
    
    {
      edge_rushers: defense_data[:edge]&.map { |edge| find_player_by_name(edge[:name]) }&.compact || [],
      defensive_ends: defense_data[:di]&.map { |di| find_player_by_name(di[:name]) }&.compact || [],
      flex_dline: find_player_by_name(defense_data[:di]&.third&.dig(:name)),
      linebackers: defense_data[:lb]&.map { |lb| find_player_by_name(lb[:name]) }&.compact || [],
      cornerbacks: defense_data[:cb]&.map { |cb| find_player_by_name(cb[:name]) }&.compact || [],
      safeties: defense_data[:s]&.map { |s| find_player_by_name(s[:name]) }&.compact || []
    }
  end

  def csv_oline_starters
    offense_data = csv_offense_starters
    
    # Map CSV positions to database positions
    oline_map = {
      c: offense_data[:c]&.first,
      lg: offense_data[:lg]&.first,
      rg: offense_data[:rg]&.first,
      lt: offense_data[:lt]&.first,
      rt: offense_data[:rt]&.first
    }
    
    # Return array in the expected order: [C, LG, RG, LT, RT]
    [
      find_player_by_name(oline_map[:c]&.dig(:name)),
      find_player_by_name(oline_map[:lg]&.dig(:name)),
      find_player_by_name(oline_map[:rg]&.dig(:name)),
      find_player_by_name(oline_map[:lt]&.dig(:name)),
      find_player_by_name(oline_map[:rt]&.dig(:name))
    ].compact
  end


  def populate
    method_name = "#{slug_long}_populate"
    if TeamPopulations.instance_methods.include?(method_name.to_sym)
      extend TeamPopulations
      send(method_name)
    else
      raise "No populate method defined for slug: #{slug}"
    end
  end
end
