class Team < ApplicationRecord
    extend TeamMapping
    include TeamPopulations
    
    def players
      Player.where(team_slug: slug)
    end
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

    def self.active_teams
        teams = Team.where(active: true).order(:conference, :division, :name)
        teams.each do |team|
            puts "#{team.conference} - #{team.division} - #{team.name} - #{team.active}"
        end
    end

    def self.kaggle_import
        require 'csv'
        # Parse CSV
        csv_text = File.read('lib/kaggle/nfl_teams.csv')
        csv = CSV.parse(csv_text, headers: true)
        # Each through rows in CSV
        csv.each do |row|
            # Get team attributes from row
            team_attrs = row.to_hash
            team_name = team_attrs['team_name']
            puts "Team Row: | #{team_attrs}"
            # Skip inactive teams
            next if ["Tennessee Oilers","St. Louis Rams","St. Louis Cardinals","Phoenix Cardinals","Houston Oilers","Boston Patriots","Washington Football Team", "Washington Redskins", "San Diego Chargers", "Los Angeles Raiders", "Oakland Raiders", "Baltimore Colts"].include?(team_name)
            # Find or create Kaggle Team
            team = Team.kaggle_team(team_name)
            # Populate team basic data e.g., 🦬, buf
            team.populate
            puts "Team Created"
            ap team

            puts "🏈 #{team.conference} | #{team.division} | (#{team.slug}) #{team.name} Saved" if team.active
            # Update team name and other data based on Kaggle
            team.name = team_attrs['team_name']
            team.name_short = team_attrs['team_name_short']
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

            team.save
            puts "Team Updated"
            ap team
            # Output team saved
            puts "🏈 #{team.conference} | #{team.division} | (#{team.slug}) #{team.name} Saved" if team.active
        end
    end

    def generate_offense
      # Find team's players 
      teammates = Player.by_team(slug)
      # Fetch players by position
      quarterback     = teammates.by_position(:quarterback).order(offense_grade: :desc).first
      runningback     = teammates.by_position(:runningback).order(offense_grade: :desc).first
      wide_receivers  = teammates.by_position(:wide_receiver).order(offense_grade: :desc).limit(2)
      tight_end       = teammates.by_position(:tight_end).order(offense_grade: :desc).first
      flex            = teammates.where(position: [:runningback, :wide_receiver, :tight_end]).order(offense_grade: :desc).where.not(id: ([runningback&.id] + wide_receivers.map(&:id) + [tight_end&.id])).first
      center          = teammates.by_position(:center).order(offense_grade: :desc).first
      guards          = teammates.by_position(:gaurd).order(offense_grade: :desc).limit(2)
      tackles         = teammates.by_position(:tackle).order(offense_grade: :desc).limit(2)
      # Return collection
      return {
        quarterback: quarterback,
        runningback: runningback,
        wide_receivers: wide_receivers,
        tight_end: tight_end,
        flex: flex,
        center: center,
        guards: guards,
        tackles: tackles
      }
    end

    def generate_defense
      # Find team's players
      teammates = Player.by_team(slug)
      # Fetch players by position
      defensive_ends  = teammates.by_position(:defensive_end).order(defence_grade: :desc).limit(2)
      edge_rushers   = teammates.by_position(:edge_rusher).order(defence_grade: :desc).limit(2)
      linebackers     = teammates.by_position(:linebackers).order(defence_grade: :desc).limit(2)
      safeties        = teammates.by_position(:safeties).order(defence_grade: :desc).limit(2)
      cornerbacks     = teammates.by_position(:cornerback).order(defence_grade: :desc).limit(2)
      flex            = teammates.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback])
                              .order(defence_grade: :desc)
                              .where.not(id: (defensive_ends.map(&:id) + edge_rushers.map(&:id) + linebackers.map(&:id) + safeties.map(&:id) + cornerbacks.map(&:id)))
                              .limit(1).first
      # Return collection
      return {
        defensive_ends: defensive_ends,
        edge_rushers: edge_rushers,
        linebackers: linebackers,
        safeties: safeties,
        cornerbacks: cornerbacks,
        flex: flex
      }
    end

    def generate_matchup(week=1,season=2025)
      # Find game and evaluate if team is playing at home
      if game = Game.find_by(season: season, week: week, home_team: slug)
          home = true
      elsif game = Game.find_by(season: season, week: week, away_team: slug)
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
          week: week,
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

    def pff_player_import(pff_row,position)
      puts pff_row
      player_name = pff_row['Player']
      first_name = player_name.split.first
      last_name = player_name.split.last
      # Validate if last name includes
      if last_name.include?("II") || last_name.include?("Jr.")
        last_name = player_name.split.last(2).first rescue "invalid-last-name"
      end
      college = pff_row['College'].downcase.gsub(' ', '-') rescue 'undrafted'
      draft_year = pff_row['DraftYear'].to_i rescue 2099
      player_slug = "#{position}-#{first_name.downcase}-#{last_name.downcase}-#{college}-#{draft_year}"
      puts player_slug
      # Populate player
      player = Player.find_or_create_by(slug: player_slug) do |player|
        puts "-1"
        ap pff_row

        puts "-1"
        player.position     = position
        player.rank         = pff_row['Rank']
        player.player       = player_name
        player.first_name   = first_name
        puts "-2"
        player.last_name    = last_name
        player.team_slug    = self.slug
        player.jersey       = pff_row['Jersey']
        puts "-3"
        # Offence
        player.offense_grade    = pff_row['Overall']
        player.passing_grade    = pff_row['Passing']
        player.rushing_grade    = pff_row['Rushing']
        player.receiving_grade  = pff_row['Receiving']
        player.run_block_grade  = pff_row['RunBlock']
        player.pass_block_grade = pff_row['PassBlock']
        puts "-5"
        player.snaps_on_offense = pff_row['Snaps']
        player.snaps_passing    = pff_row['Passes']
        player.snaps_rushing    = pff_row['Rushes']
        player.snaps_recieving  = pff_row['Receptions']
        player.snaps_run_block  = pff_row['RunBlocks']
        player.snaps_pass_block = pff_row['PassBlocks']
        # Defense
        player.defence_grade      = pff_row['Overall']
        player.rush_defense_grade = pff_row['RushDefense']
        player.pass_rush_grade    = pff_row['PassRush']
        player.coverage_grade     = pff_row['Coverage']
        player.snaps_on_defence   = pff_row['Snaps']
        player.snaps_rush_defense = pff_row['RunSnaps']
        player.snaps_pass_rush    = pff_row['PassRushSnaps']
        player.snaps_coverage     = pff_row['CoverageSnaps']


        # player.dropback_grade = pff_row['Dropback_Grade']
        # player.pocket_grade   = pff_row['Pocket_Grade']
        # # RB, WR, TE, C, G, T
        # player.pass_block_grade   = pff_row['Pass_Block_Grade']
        # player.run_block_grade    = pff_row['Run_Block_Grade']
        # player.receiving_grade    = pff_row['Receiving_Grade']
        # player.rushing_grade      = (pff_row['Rush_Grade'] || pff_row['Rushing_Grade'])
        # player.route_grade        = pff_row['Route_Grade']
        # player.yac_grade          = pff_row['YAC_Grade']
        # # Defense
        # player.coverage_grade     = pff_row['Coverage_Grade']
        # player.run_defense_grade  = pff_row['Run_Defense_Grade']
        # player.tackling_grade     = pff_row['Tackling_Grade']
        # player.pass_rush_grade    = pff_row['Pass_Rush_Grade']
        # player.screen_block_grade = pff_row['Screen_Block_Grade']
        # player.intermediate_yards = pff_row['Intermediate_Yards']
        # player.deep_yards         = pff_row['Deep_Yards']
        # player.screen_yards       = pff_row['Screen_Yards']
        # player.total_yards        = pff_row['Total_Yards']
        # player.rush_yards         = pff_row['Rush_Yards']
        # player.receiving_yards    = pff_row['Receiving_Yards']
        # player.missed_tackles_forced = pff_row['Missed_Tackles_Forced']
        # # Offense
        # player.td               = pff_row['TD']
        # player.first_downs      = pff_row['1st_Downs']
        # player.snaps            = pff_row['Snaps']
        # player.run_snaps        = pff_row['Run_Snaps']
        # player.pass_rush_snaps  = pff_row['Pass_Rush_Snaps']
        # player.coverage_snaps   = pff_row['Coverage_Snaps']
        # player.passing_snaps    = pff_row['Passing_Snaps']
        # player.routes           = pff_row['Routes']
        # player.qb_hits          = pff_row['QB_Hits']
        # player.run_block_snaps  = pff_row['Run_Block_Snaps']
        # player.pass_block_snaps = pff_row['Pass_Block_Snaps']
        # # player.total_snaps      = pff_row['Total_Snaps']
        # # Snaps
        # player.total_snaps = pff_row['Total_Snaps']
        # player.pass_snaps = pff_row['Pass_Snaps']
        # player.rush_snaps = pff_row['Rush_Snaps']
        # player.rpo_snaps = pff_row['RPO_Snaps']
        # player.dropback_snaps = pff_row['Dropback_Snaps']
        # player.pocket_snaps = pff_row['Pocket_Snaps']

        # Player Attributes
        player.age = pff_row['Age']
        player.hand = pff_row['Hand']
        player.height = pff_row['Height']
        player.weight = pff_row['Weight']
        player.speed = pff_row['Speed']
        player.college = college
        player.draft_year = draft_year
        player.draft_round = pff_row['DraftRound']
        player.draft_pick = pff_row['DraftPick']
    end
    # Puts description
    puts "Player Imported ==========="
    puts player.description
    ap player
    unless player.errors.empty?
      puts "Errors ---------"
      ap player.errors.inspect
    end
  end

  def populate
    method_name = "#{slug_long}_populate"
    puts method_name
    if TeamPopulations.instance_methods.include?(method_name.to_sym)
      extend TeamPopulations
      send(method_name)
    else
      raise "No populate method defined for slug: #{slug}"
    end
  end
end
