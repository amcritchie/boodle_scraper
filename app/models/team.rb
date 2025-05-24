class Team < ApplicationRecord
    extend TeamMapping
    include TeamPopulations
    
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
    
    # Map team id for sportsoddshistory
    def self.sportsoddshistory_team_name_map(team_name)
        case team_name
        when "Buffalo Bills"              # AFC East
          :BUF
        when "New York Jets"
          :NYJ
        when "Miami Dolphins"
          :MIA
        when "New England Patriots"
          :NE
        when "Kansas City Chiefs"       # AFC West
          :KC
        when "Denver Broncos"
          :DEN
        when "Los Angeles Chargers"
          :LAC
        when "Las Vegas Raiders"
          :LV
        when "Oakland Raiders"
          :LV
        when "Cincinnati Bengals"       # AFC North
          :CIN
        when "Baltimore Ravens"
          :BAL
        when "Pittsburgh Steelers"
          :PIT
        when "Cleveland Browns"
          :CLE
        when "Jacksonville Jaguars"     # AFC South
          :JAX
        when "Houston Texans"
          :HOU
        when "Tennessee Titans"
          :TEN
        when "Indianapolis Colts"
          :IND
        when "Green Bay Packers"        # NFC North
          :GB
        when "Minnesota Vikings"
          :MIN
        when "Chicago Bears"
          :CHI
        when "Detroit Lions"
          :DET
        when "Dallas Cowboys"           # NFC EAST
          :DAL
        when "New York Giants"
          :NYG
        when "Philadelphia Eagles"
          :PHI
        when "Washington Commanders"
          :WAS
        when "Washington Football Team"
          :WAS
        when "Washington Redskins"
          :WAS
        when "Seattle Seahawks"         # NFC West
          :SEA
        when "Los Angeles Rams"
          :LAR
        when "San Francisco 49ers"
          :SF
        when "Arizona Cardinals"
          :ARI
        when "Atlanta Falcons"          # NFC South
          :ATL
        when "Carolina Panthers"
          :CAR
        when "Tampa Bay Buccaneers"
          :TB
        when "New Orleans Saints"
          :NO
        else
          :unknown
        end
    end

    # # Emoji
    # def emoji
    #   emoji_map = {
    #     "buf" => :🦬, "nyj" => :🛩️, "mia" => :🐬, "ne"  => :🇺🇸, # AFC East
    #     "kc"  => :🏹, "den" => :🐴, "lac" => :⚡️, "lv"  => :🎲, # AFC WEST
    #     "bal" => :🐦‍⬛, "pit" => :👷‍♂️, "cin" => :🐯, "cle" => :🟤, # AFC NORTH
    #     "hou" => :🐂, "jax" => :🐆, "ind" => :🐎, "ten" => :🗡️, # AFC SOUTH
    #     "phi" => :🦅, "dal" => :🤠, "was" => :🪖, "nyg" => :🗽, # NFC East
    #     "sf"  => :🌉, "lar" => :🐏, "sea" => :‍‍🐦, "ari" => :🐤, # NFC WEST
    #     "det" => :🦁, "gb"  => :🧀, "min" => :😈, "chi" => :🐻, # NFC NORTH
    #     "no"  => :⚜️, "atl" => :🐦‍🔥, "tb"  => :🏴‍☠️, "car" => :🐈‍⬛ # NFC SOUTH
    #   }
    #   emoji_map[slug] || :unknown
    # end

    def generate_roster(week=1,season=2025)
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
      qb = teammates.by_position(:quarterback).order(overall_grade: :desc).first
      rb = teammates.by_position(:runningback).order(overall_grade: :desc).first
      wrs = teammates.by_position(:wide_receiver).order(overall_grade: :desc).limit(2)
      te = teammates.by_position(:tight_end).order(overall_grade: :desc).first
      flex = teammates.where(position: [:runningback, :wide_receiver, :tight_end]).order(overall_grade: :desc).where.not(id: ([rb&.id] + wrs.map(&:id) + [te&.id])).first
      center = teammates.by_position(:center).order(overall_grade: :desc).first
      guards = teammates.by_position(:gaurd).order(overall_grade: :desc).limit(2)
      tackles = teammates.by_position(:tackle).order(overall_grade: :desc).limit(2)
      # Defence
      des = teammates.by_position(:defensive_end).order(overall_grade: :desc).limit(2)
      edges = teammates.by_position(:edge_rusher).order(overall_grade: :desc).limit(1)
      lbs = teammates.by_position(:linebackers).order(overall_grade: :desc).limit(2)
      safeties = teammates.by_position(:safeties).order(overall_grade: :desc).limit(2)
      cbs = teammates.by_position(:cornerback).order(overall_grade: :desc).limit(2)
      flex_defense = teammates.where(position: [:defensive_end, :edge_rusher, :linebackers, :safeties, :cornerback]).order(overall_grade: :desc).where.not(id: (des.map(&:id) + edges.map(&:id) + lbs.map(&:id) + safeties.map(&:id) + cbs.map(&:id))).limit(2)
      # Find or create roster
      roster = Roster.find_or_create_by(game: game.slug, team: slug)
      # Create roster
      roster.update(
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
          d4: lbs[0]&.slug,
          d5: lbs[1]&.slug,
          d6: safeties[0]&.slug,
          d7: safeties[1]&.slug,
          d8: cbs[0]&.slug,
          d9: cbs[1]&.slug,
          d10: flex_defense[0]&.slug,
          d11: flex_defense[1]&.slug
      )
      puts "Roster for Week #{week}, Season #{season} #{name} created successfully!"
      ap roster
    end

    def pff_player_import(pff_row,position)
      player_name = pff_row['Player']
      first_name = player_name.split.first
      last_name = player_name.split.last
      # Validate if last name includes
      if last_name.include?("II")
        last_name = player_name.split.last(2).first rescue "invalid-last-name"
      end
      college = pff_row['College'].downcase.gsub(' ', '-') rescue 'undrafted'
      draft_year = pff_row['Draft_Year'].to_i rescue 2099
      player_slug = "#{position}-#{last_name.downcase}-#{college}-#{draft_year}"
      # Populate player
      player = Player.find_or_create_by(slug: player_slug) do |player|
        player.position     = position
        player.rank         = pff_row['Rank']
        player.player       = player_name
        player.first_name   = first_name
        player.last_name    = last_name
        player.team_slug    = self.slug
        player.jersey       = pff_row['Jersey']
        # QB
        player.overall_grade  = pff_row['Overall_Grade']
        player.passing_grade  = pff_row['Passing_Grade']
        player.running_grade  = pff_row['Running_Grade']
        player.rpo_grade      = pff_row['RPO_Grade']
        player.dropback_grade = pff_row['Dropback_Grade']
        player.pocket_grade   = pff_row['Pocket_Grade']
        # RB, WR, TE, C, G, T
        player.pass_block_grade   = pff_row['Pass_Block_Grade']
        player.run_block_grade    = pff_row['Run_Block_Grade']
        player.receiving_grade    = pff_row['Receiving_Grade']
        player.rushing_grade      = (pff_row['Rush_Grade'] || pff_row['Rushing_Grade'])
        player.route_grade        = pff_row['Route_Grade']
        player.yac_grade          = pff_row['YAC_Grade']
        # Defense
        player.coverage_grade     = pff_row['Coverage_Grade']
        player.run_defense_grade  = pff_row['Run_Defense_Grade']
        player.tackling_grade     = pff_row['Tackling_Grade']
        player.pass_rush_grade    = pff_row['Pass_Rush_Grade']
        player.screen_block_grade = pff_row['Screen_Block_Grade']
        player.intermediate_yards = pff_row['Intermediate_Yards']
        player.deep_yards         = pff_row['Deep_Yards']
        player.screen_yards       = pff_row['Screen_Yards']
        player.total_yards        = pff_row['Total_Yards']
        player.rush_yards         = pff_row['Rush_Yards']
        player.receiving_yards    = pff_row['Receiving_Yards']
        player.missed_tackles_forced = pff_row['Missed_Tackles_Forced']
        # Offense
        player.td               = pff_row['TD']
        player.first_downs      = pff_row['1st_Downs']
        player.snaps            = pff_row['Snaps']
        player.run_snaps        = pff_row['Run_Snaps']
        player.pass_rush_snaps  = pff_row['Pass_Rush_Snaps']
        player.coverage_snaps   = pff_row['Coverage_Snaps']
        player.passing_snaps    = pff_row['Passing_Snaps']
        player.routes           = pff_row['Routes']
        player.qb_hits          = pff_row['QB_Hits']
        player.run_block_snaps  = pff_row['Run_Block_Snaps']
        player.pass_block_snaps = pff_row['Pass_Block_Snaps']
        # player.total_snaps      = pff_row['Total_Snaps']
        # Snaps
        player.total_snaps = pff_row['Total_Snaps']
        player.pass_snaps = pff_row['Pass_Snaps']
        player.rush_snaps = pff_row['Rush_Snaps']
        player.rpo_snaps = pff_row['RPO_Snaps']
        player.dropback_snaps = pff_row['Dropback_Snaps']
        player.pocket_snaps = pff_row['Pocket_Snaps']
        player.age = pff_row['Age']
        player.hand = pff_row['Hand']
        player.height = pff_row['Height']
        player.weight = pff_row['Weight']
        player.speed = pff_row['Speed']
        player.college = college
        player.draft_year = draft_year
        player.draft_round = pff_row['Draft_Round']
        player.draft_pick = pff_row['Draft_Pick']
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
