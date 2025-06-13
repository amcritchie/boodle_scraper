require 'csv'
require 'httparty'

class Team < ApplicationRecord
    extend TeamMapping
    include TeamPopulations
    
    has_many :players

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

    def fetch_roster_sportradar
      # "0d855753-ea21-4953-89f9-0e20aff9eb73"
      response = HTTParty.get(
        "https://api.sportradar.com/nfl/official/trial/v7/en/teams/#{sportsradar_id}/full_roster.json",
        headers: {
          'accept' => 'application/json',
          'x-api-key' => 'dBqzgfZiBp0sTpz06FIx3AjcLzCA2EzwFID6ZCl0'
        }
      )
      
      ap response
      if response.success?
        team_sportsradar = JSON.parse(response.body)

        team_sportsradar["venue"]
        team_sportsradar["coaches"]
        team_sportsradar["players"]
        # Each through players
        team_sportsradar["players"].each do |player_sportsradar|
          # Find or create player
          player = Player.sportsradar_find_or_create(player_sportsradar, self.slug)
        end
      else
        Rails.logger.error "Failed to fetch SportRadar roster: #{response.code} - #{response.message}"
        nil
      end
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

    def self.pff_passer_import(csv_path)
      CSV.foreach(csv_path, headers: true) do |row|
        # attrs = row.to_h.slice(*Player.column_names)
        attrs = row.to_h
        # Fetch important columns
        slug_pff = attrs["player_id"]
        player_name = attrs["player"]
        team_name = attrs["team_name"]
        position = Player.pff_position(attrs["position"]) rescue "unknown"
        team = Team.pff_team(team_name) rescue "unknown"
        # Create player slug
        slug_player = "#{position}-#{player_name}".downcase.gsub(' ', '-')
        # Find or create player
        unless player = Player.find_by(slug_pff: slug_pff)
          player = Player.find_or_create_by(slug: slug_player) do |player|
            player.slug_pff = slug_pff
          end
        end
        # Update player
        player.update(
          player_game_count:    attrs["player_game_count"],
          passing_yards_per_attempt:   attrs["ypa"].to_f,
          passing_attempts:     attrs["attempts"],
          passing_touchdowns:   attrs["touchdowns"],
          passing_yards:        attrs["yards"],
          franchise_id:         attrs["franchise_id"],
          grades_offense:       attrs["grades_offense"].to_f,
          grades_pass:          attrs["grades_pass"].to_f,
          grades_run:           attrs["grades_run"].to_f,
          penalties:            attrs["penalties"],
          scrambles:            attrs["scrambles"],
          accuracy_percent:       attrs["accuracy_percent"],
          aimed_passes:           attrs["aimed_passes"],
          avg_depth_of_target:    attrs["avg_depth_of_target"],
          avg_time_to_throw:      attrs["avg_time_to_throw"],
          turnover_worthy_plays:  attrs["turnover_worthy_plays"],
          turnover_worthy_rate:   attrs["twp_rate"],
          batted_passes:          attrs["bats"],
          big_time_throws:        attrs["big_time_throws"],
          btt_rate:               attrs["btt_rate"],
          completion_percent:     attrs["completion_percent"],
          completions:            attrs["completions"],
          declined_penalties:     attrs["declined_penalties"],
          def_gen_pressures:      attrs["def_gen_pressures"],
          drop_rate:              attrs["drop_rate"],
          dropbacks:              attrs["dropbacks"],
          drops:                  attrs["drops"].to_i,
          first_downs:            attrs["first_downs"],
          grades_hands_fumble:    attrs["grades_hands_fumble"],
          hit_as_threw:           attrs["hit_as_threw"],
          interceptions:          attrs["interceptions"],
          passing_snaps:          attrs["passing_snaps"],
          penalties:              attrs["penalties"].to_i,
          pressure_to_sack_rate:  attrs["pressure_to_sack_rate"],
          qb_rating:              attrs["qb_rating"],
          sack_percent:           attrs["sack_percent"],
          sacks:                  attrs["sacks"],
          scrambles:              attrs["scrambles"],
          spikes_thrown:          attrs["spikes"],
          thrown_aways:           attrs["thrown_aways"],
          team_slug:              team.slug,
          position:               position
        )
        puts "-lala----"
        ap attrs['player']
        puts "-----"
        ap player
        puts "-----"
      end
    end

    def self.pff_rusher_import(csv_path)
      CSV.foreach(csv_path, headers: true) do |row|
        # Get row
        attrs = row.to_h
        # Fetch important columns
        slug_pff = attrs["player_id"]
        player_name = attrs["player"]
        team_name = attrs["team_name"]
        position = Player.pff_position(attrs["position"]) rescue "unknown"
        team = Team.pff_team(team_name) rescue "unknown"
        # Create player slug
        slug_player = "#{position}-#{player_name}".downcase.gsub(' ', '-')
        # Find or create player
        unless player = Player.find_by(slug_pff: slug_pff)
          player = Player.find_or_create_by(slug: slug_player) do |player|
            player.slug_pff = slug_pff
          end
        end
        # Update player
        player.update(
          player_game_count:                  attrs["player_game_count"],
          rushing_attempts:                   attrs["attempts"],
          avoided_tackles:                    attrs["avoided_tackles"],
          breakaway_attempts:                 attrs["breakaway_attempts"],
          breakaway_percent:                  attrs["breakaway_percent"].to_f,
          breakaway_yards:                    attrs["breakaway_yards"],
          declined_penalties:                 attrs["declined_penalties"],
          designed_yards:                     attrs["designed_yards"],
          drops:                              attrs["drops"],
          elusive_recv_missed_tackles_forced: attrs["elu_recv_mtf"].to_i,
          elusive_rush_missed_tackles_forced: attrs["elu_rush_mtf"].to_i,
          elu_yco:                            attrs["elu_yco"].to_i,
          elusive_rating:                     attrs["elusive_rating"].to_f,
          explosive:                          attrs["explosive"].to_i,
          first_downs:                        attrs["first_downs"],
          franchise_id:                       attrs["franchise_id"],
          fumbles:                            attrs["fumbles"].to_i,
          gap_attempts:                       attrs["gap_attempts"],
          grades_hands_fumble:                attrs["grades_hands_fumble"].to_f,
          grades_offense:                     attrs["grades_offense"].to_f,
          grades_offense_penalty:             attrs["grades_offense_penalty"].to_f,
          grades_pass:                        attrs["grades_pass"].to_f,
          grades_run:                         attrs["grades_run"].to_f,
          grades_pass_block:                  attrs["grades_pass_block"].to_f,
          grades_run_block:                   attrs["grades_run_block"].to_f,
          longest:                            attrs["longest"].to_i,
          rec_yards:                          attrs["rec_yards"].to_i,
          receptions:                         attrs["receptions"].to_i,
          routes:                             attrs["routes"].to_i,
          run_plays:                          attrs["run_plays"].to_i,
          scramble_yards:                     attrs["scramble_yards"].to_i,
          scrambles:                          attrs["scrambles"].to_i,
          targets:                            attrs["targets"].to_i,
          total_touches:                      attrs["total_touches"].to_i,
          rushing_touchdowns:                 attrs["touchdowns"].to_i,
          rushing_yards:                      attrs["yards"],
          yards_after_contact:                attrs["yards_after_contact"],
          yards_after_contact_attempt:        attrs["yco_attempt"],
          rushing_yards_per_attempt:          attrs["ypa"],
          yards_per_route_run:                attrs["yprr"],
          zone_attempts:                      attrs["zone_attempts"],
          team_slug:            team.slug,
          position:             position
        )
        puts "-margot----"
        ap attrs['player']
        puts "-----"
        ap player
        puts "-----"
      end
    end

    def self.pff_receiver_import(csv_path)
      CSV.foreach(csv_path, headers: true) do |row|
        # Get row
        attrs = row.to_h
        # Fetch important columns
        slug_pff = attrs["player_id"]
        player_name = attrs["player"]
        team_name = attrs["team_name"]
        position = Player.pff_position(attrs["position"]) rescue "unknown"
        team = Team.pff_team(team_name) rescue "unknown"
        # Create player slug
        slug_player = "#{position}-#{player_name}".downcase.gsub(' ', '-')
        # Find or create player
        unless player = Player.find_by(slug_pff: slug_pff)
          player = Player.find_or_create_by(slug: slug_player) do |player|
            player.slug_pff = slug_pff
          end
        end

  

        # Update player
        player.update(
          player_game_count:                attrs["player_game_count"],
          avg_depth_of_target:              attrs["avg_depth_of_target"],
          avoided_tackles:                  attrs["avoided_tackles"],
          caught_percent:                   attrs["caught_percent"],
          contested_catch_rate:             attrs["contested_catch_rate"],
          contested_receptions:             attrs["contested_receptions"],
          contested_targets:                attrs["contested_targets"],
          declined_penalties:               attrs["declined_penalties"],
          drops:                            attrs["drops"],
          first_downs:                      attrs["first_downs"],
          franchise_id:                     attrs["franchise_id"],
          fumbles:                          attrs["fumbles"].to_i,
          grades_hands_drop:                attrs["grades_hands_drop"].to_i,
          grades_hands_fumble:              attrs["grades_hands_fumble"].to_i,
          grades_offense:                   attrs["grades_offense"].to_f,
          grades_pass_block:                attrs["grades_pass_block"].to_f,
          grades_pass_route:                attrs["grades_pass_route"].to_f,
          inline_rate:                      attrs["inline_rate"].to_f,
          inline_snaps:                     attrs["inline_snaps"].to_i,
          interceptions:                    attrs["interceptions"].to_i,
          longest:                          attrs["longest"].to_i,
          pass_block_rate:                  attrs["pass_block_rate"].to_i,
          pass_blocks:                      attrs["pass_blocks"].to_i,
          pass_plays:                       attrs["pass_plays"].to_i,
          penalties:                        attrs["penalties"].to_i,
          receptions:                       attrs["receptions"].to_i,
          route_rate:                       attrs["route_rate"].to_i,
          routes:                           attrs["routes"].to_i,
          slot_rate:                        attrs["slot_rate"].to_i,
          slot_snaps:                       attrs["slot_snaps"].to_i,
          targeted_qb_rating:               attrs["targeted_qb_rating"].to_i,
          longest:                          attrs["longest"].to_i,
          receiving_touchdowns:             attrs["touchdowns"].to_i,
          receiving_yards:                  attrs["yards"],
          receiving_yards:                  attrs["wide_rate"],
          receiving_yards:                  attrs["wide_snaps"],
          yards_after_catch:                attrs["yards_after_catch"],
          yards_after_catch_per_reception:  attrs["yards_after_catch_per_reception"],
          receiving_yards:                  attrs["yards_per_reception"],
          yards_per_route_run:              attrs["yprr"],
          wide_rate:                        attrs["wide_rate"],
          wide_snaps:                       attrs["wide_snaps"],
          receiving_yards:                  attrs["yards"],
          yards_after_contact:              attrs["yards_after_contact"],
          yards_after_contact_attempt:      attrs["yco_attempt"],
          rushing_yards_per_attempt:        attrs["ypa"],
          yards_per_route_run:              attrs["yprr"],
          zone_attempts:                    attrs["zone_attempts"],
          team_slug:                        team.slug,
          position:                         position
        )
        puts "-margo2----"
        ap attrs['player']
        puts "-----"
        ap player
        puts "-----"
      end
    end

    def pff_player_import(pff_row,position)
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
