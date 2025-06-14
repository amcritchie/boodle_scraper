namespace :matchups do
  desc "Populate matchups for Week 1, Season 2025 Buffalo Bills"
  task populate: :environment do
    # Each through active teams
    Team.active.each do |team|
        # Generate Week 1 Roster
        team.generate_matchup(1,2024)
    end
  end

  desc "Populate matchups for Week 1, Season 2024"
  task populate2024: :environment do

    Week.where(season_year: 2024, sequence: 1).where.not(sportsradar_id: nil).order(sequence: :asc).each do |week|
      puts "================================================"
      puts "Week #{week.sequence}"
      puts "================================================"

      week.games.each do |game|
        # Generate matchups
        game.away_matchup
        game.home_matchup

        puts "---"
        puts "Game #{game.sportsradar_id}"
        puts "mason"
        puts "---"
        ap game
        puts "---"

        access_level = "trial"
        language_code = "en"
        game_id = game.sportsradar_id
        format = "json"
        url_string = "https://api.sportradar.com/nfl/official/#{access_level}/v7/#{language_code}/games/#{game_id}/pbp.#{format}"

        # Fetch data from SportRadar API
        response = HTTParty.get(url_string,
            headers: {
              'accept' => 'application/json',
              'x-api-key' => 'dBqzgfZiBp0sTpz06FIx3AjcLzCA2EzwFID6ZCl0'
            }
          )
        
        if response.success?
          json_data = JSON.parse(response.body)
          # Each Through Periods
          json_data['periods'].each do |period|
            # Period Data
            period_type     = period['period_type']
            period_number   = period['number']      
            period_sequence = period['sequence']
            period_id       = period['id']
            puts "================================================"
            puts "#{period['number']} #{period['period_type']} | #{period['sequence']} #{period['id']}"
            # Each Through Drives
            period['pbp'].each do |drive|
              puts "=========== #{drive['event_type']} ===========" if drive['event_type']
              # Next on timeouts
              next if drive['event_type'] == "tv_timeout"
              next if drive['event_type'] == "period_end"
              # Pull data
              type          = drive['type']             # drive
              sequence      = drive['sequence']         # 16
              team_sequence = drive['team_sequence']    # 8
              start_reason  = drive['start_reason']     # Punt
              end_reason    = drive['end_reason']       # Touchdown
              id            = drive['id']               # 1234567890
              duration      = drive['duration']         # 3:50
              first_downs   = drive['first_downs']      # 3
              gain          = drive['gain']             # 90
              penalty_yards = drive['penalty_yards']    # -10
              scoring_drive = drive['scoring_drive']    # true
              start_clock   = drive['start_clock']      # 3:37
              end_clock     = drive['end_clock']        # 14:47
              # Fetch Offense Teams
              if drive['offensive_team']
                offense_team = Team.find_by(sportsradar_id: drive['offensive_team']['id'])
                defense_team = Team.find_by(sportsradar_id: drive['defensive_team']['id'])
              elsif drive['possession']
                offense_team = Team.find_by(sportsradar_id: drive['possession']['id'])
              end

              puts "--------------------------------"
              puts "Drive #{offense_team.emoji} #{type} #{sequence} #{start_reason} #{end_reason} #{id}"

              drive['events'].each do |eventt|
                # Fetch data
                clock = eventt['clock']      # 2:55
                play_type = eventt['play_type']      # pass
                description = eventt['description']  # L.Jackson pass deep right complete. Catch made by I.Likely for 49 yards. TOUCHDOWN.
                scoring_play = eventt['scoring_play'] # true
                # Fetch down
                if start_situation = eventt['start_situation']
                  down = start_situation['down']                # 2
                end
                # Start and end clock
                if start_situation = eventt['start_situation'] # true
                  start_situation_clock = eventt['start_situation']['clock'] # true
                end
                if end_situation = eventt['end_situation'] # true
                  end_situation_clock = eventt['end_situation']['clock'] # true
                end
                # Fetch points
                if score = eventt['score']
                  score_points = eventt['score']['points'] # 7
                  home_points = eventt['score']['home_points'] # 20
                  away_points = eventt['score']['away_points'] # 16
                end
                # Fetch statistics
                statistics = eventt['statistics'] # 5+ player events
              # Touchdown
                if play_type == "pass" && score_points == 7
                  puts "🎉 Passing Touchdown"
                  week.passing_touchdowns += 1
                  week.save!
                elsif play_type == "rush" && score_points == 7
                  puts "🎉 Rushing Touchdown"
                  week.rushing_touchdowns += 1
                  week.save!
                elsif play_type == "kickoff" && score_points == 7
                  puts "🎉 Kickoff Touchdown"
                elsif play_type == "extra_point" && score_points == 7
                  puts "🎉 Extra Point Touchdown"
                elsif  score_points == 7
                  puts "🎉 Other Touchdown"
                end
                # Extra Point
                if eventt['play_type'] == "extra_point" && eventt['scoring_play'] == true
                  puts "🎉 Extra Point"
                end

                # puts Play
                puts "#{clock} | #{down} | #{play_type} #{score_points} #{description}"
                sleep(0.1)
                # Error During Event
                rescue => e
                  puts "xx123xxE"
                  puts "Error: #{e}"
                  e.backtrace.each{ |line| puts line }
                  puts "--------------------------------"
                  puts "Event"
                  puts "--------------------------------"
                  ap eventt
                  puts "--------------------------------"
                  sleep(5)
              end
              # Error During Drive
            rescue => e
              puts "xx123xxD"
              puts "Error: #{e}"
              e.backtrace.each{ |line| puts line }
              puts "--------------------------------"
              puts "Drive"
              puts "--------------------------------"
              ap drive
              puts "--------------------------------"
              sleep(5)
            end
          end  
          puts "--------------------------------"
          ap week
          puts "--------------------------------"
        end
        sleep(1)
      end
    end
  end

  desc "Populate matchups for Week 1, Season 2025"
  task populate2025: :environment do
    # Create games
    Game.create_games_from_csv('/Users/amcritchie/alex-apps/boodle_scraper/lib/2025/Expanded_NFL_2025_Schedule.csv')
    # Each through games in season
    Game.where(season: 2025, week_slug: 1).each do |game|
      # Generate matchups
      game.away_matchup
      game.home_matchup
    end

    matchups = Matchup.where(season: 2025, week_slug: 1)
    matchups.set_scores

    # Eagles Index Grade (Have Fun)
    Matchup.rush_defense_rank
    Matchup.rush_offense_rank
    Matchup.pass_offense_rank
    Matchup.pass_defense_rank
  end

  desc "Populate matchups for Week 1, Season 2025"
  task populate_matchups: :environment do
    Team.active.each do |home_team|
      Team.active.each do |away_team|
        next if home_team == away_team
        Matchup.create!(
          season: 2025,
          week: 1,
          game: "#{home_team.name} vs #{away_team.name}",
          home_team: home_team.name,
          away_team: away_team.name,
          # Add logic to populate offensive and defensive lineups
          home_o1: "Player 1", away_d1: "Player A"
          # ...populate other positions...
        )
      end
    end
  end
end
