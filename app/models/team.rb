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

        # Hardcoded starting QB slugs for 2025 season
        starting_qb_slugs = [
          'quarterback-patrick-mahomes',  # AFC West
          'quarterback-bo-nix',
          'quarterback-justin-herbert',
          'quarterback-geno-smith',
          'quarterback-josh-allen',       # AFC East
          'quarterback-drake-maye',
          'quarterback-tua-tagovailoa',
          'quarterback-justin-fields',
          'quarterback-lamar-jackson',    # AFC North
          'quarterback-joe-burrow',
          'quarterback-aaron-rodgers',
          'quarterback-joe-flacco',
          'quarterback-cj-stroud',        # AFC South
          'quarterback-trevor-lawrence',
          'quarterback-will-levis',
          'quarterback-daniel-jones',
          'quarterback-jared-goff',        # NFC North
          'quarterback-jordan-love',
          'quarterback-caleb-williams',
          'quarterback-jj-mccarthy',
          'quarterback-bryce-young',      # NFC South
          'quarterback-baker-mayfield',
          'quarterback-michael-penix-jr',
          'quarterback-tyler-shough',
          'quarterback-dak-prescott',     # NFC East
          'quarterback-jalen-hurts',
          'quarterback-jayden-daniels',
          'quarterback-russell-wilson',
          'quarterback-brock-purdy',      # NFC West
          'quarterback-kyler-murray',
          'quarterback-matthew-stafford',
          'quarterback-sam-darnold'
        ]

        # Each through players
        team_sportsradar["players"].each do |player_sportsradar|
          # Find or create player
          player = Player.sportsradar_find_or_create(player_sportsradar, self.slug)
          
          # Mark as starter if QB slug is in the starter list
          player.update(starter: true) if starting_qb_slugs.include?(player.slug)
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

    def generate_offense
      # Find team's players 
      teammates = Player.by_team(slug)
      # Return collection
      return {
        quarterback:    self.starting_qb,
        runningback:    self.starting_rb,
        wide_receivers: self.starting_wrs,
        tight_end:      self.starting_te,
        flex:           self.starting_flex_offense,
        oline:          self.starting_oline
      }
    end

    def generate_defense
      # Find team's players 
      teammates = Player.by_team(slug)
      # Return collection
      return {
        defensive_ends: self.starting_defensive_ends,
        edge_rushers: self.starting_edge_rushers,
        linebackers: self.starting_linebackers,
        safeties: self.starting_safeties,
        cornerbacks: self.starting_cornerbacks,
        flex: self.starting_flex_defense
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
      # Find team's players 
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
      # Find or create roster
      matchup = Matchup.find_or_create_by(game: game.slug, team_slug: slug)
      # Create roster
      matchup.update(
          season: season,
          week_slug: week.to_s,
          home: home,
          o1: qb&.slug,
          o2: rb&.slug,
          o3: wrs[0]&.slug,
          o4: wrs[1]&.slug,
          o5: te&.slug,
          o6: flex&.slug,
          o7: center&.slug,
          o8: guards[0]&.slug,
          o9: guards[1]&.slug,
          o10: tackles[0]&.slug,
          o11: tackles[1]&.slug,
          d1: des[0]&.slug,
          d2: des[1]&.slug,
          d3: edges[0]&.slug,
          d4: edges[1]&.slug,
          d5: lbs[0]&.slug,
          d6: lbs[1]&.slug,
          d7: safeties[0]&.slug,
          d8: safeties[1]&.slug,
          d9: cbs[0]&.slug,
          d10: cbs[1]&.slug,
          d11: flex_defense[0]&.slug
      )
      puts "Matchup for Week #{week}, Season #{season} #{name} created successfully!"
      ap matchup
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
