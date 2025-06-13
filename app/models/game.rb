# require 'open-uri'
require 'net/http'
require 'net/https'
require 'nokogiri'
require 'progress_bar'

class Game < ApplicationRecord
  # belongs_to :week
  # belongs_to :venue
  has_one :weather, dependent: :destroy
  has_one :broadcast, dependent: :destroy
  has_one :scoring, dependent: :destroy

  # Games imported from Kaggle
  def self.kaggle
    where(source: :kaggle)
  end
  # Games imported from SportsOddsHistory
  def self.sportsoddshistory
    where(source: :sportsoddshistory)
  end
  # Filter games by primetime
  def self.primetime
    where(primetime: :true)
  end
  # Filter games by overtime
  def self.overtime
    where(overtime: :true)
  end
  # Filter games by season
  def self.season(season=2024)
    all.where(season: season)
  end
  # Filter games by season
  def self.last_five_years
    all.where(season: [2024,2023,2022,2021,2020])
  end
  # Pluck seasons from games
  def self.seasons
    all.pluck(:season).uniq.sort
  end
  # Fetch the teams
  def the_away_team
    Team.find_by_slug(away_slug)
  end
  def the_home_team
    Team.find_by_slug(home_team)
  end

  def home_matchup
    away = Team.find_by_slug(away_slug)
    home = Team.find_by_slug(home_slug)
    # Generate rosters
    offense = home.generate_offense
    defense = away.generate_defense
    # Find or create matup
    matchup = Matchup.find_or_create_by(game: self.slug, team_slug: home.slug, team_defense_slug: away.slug)
    # Create roster
    matchup.update(
      season: self.season,
      week_slug: self.week_slug,
      home: true,
      o1:   offense[:quarterback]&.slug,
      o2:   offense[:runningback]&.slug,
      o3:   offense[:wide_receivers][0]&.slug,
      o4:   offense[:wide_receivers][1]&.slug,
      o5:   offense[:tight_end]&.slug,
      o6:   offense[:flex]&.slug,
      o7:   offense[:center]&.slug,
      o8:   offense[:guards][0]&.slug,
      o9:   offense[:guards][1]&.slug,
      o10:  offense[:tackles][0]&.slug,
      o11:  offense[:tackles][1]&.slug,
      d1:   defense[:defensive_ends][0]&.slug,
      d2:   defense[:defensive_ends][1]&.slug,
      d3:   defense[:edge_rushers][0]&.slug,
      d4:   defense[:edge_rushers][1]&.slug,
      d5:   defense[:linebackers][0]&.slug,
      d6:   defense[:linebackers][1]&.slug,
      d7:   defense[:safeties][0]&.slug,
      d8:   defense[:safeties][1]&.slug,
      d9:   defense[:cornerbacks][0]&.slug,
      d10:  defense[:cornerbacks][1]&.slug,
      d11:  defense[:flex]&.slug
    )
  end

  def away_matchup
    away = Team.find_by_slug(away_slug)
    home = Team.find_by_slug(home_slug)
    # Generate rosters
    offense = away.generate_offense
    defense = home.generate_defense

    # Find or create matup
    matchup = Matchup.find_or_create_by(game: self.slug, team_slug: away.slug, team_defense_slug: home.slug)
    # Create roster
    matchup.update(
      season: self.season,
      week_slug: self.week_slug,
      home: false,
      o1:   offense[:quarterback]&.slug,
      o2:   offense[:runningback]&.slug,
      o3:   offense[:wide_receivers][0]&.slug,
      o4:   offense[:wide_receivers][1]&.slug,
      o5:   offense[:tight_end]&.slug,
      o6:   offense[:flex]&.slug,
      o7:   offense[:center]&.slug,
      o8:   offense[:guards][0]&.slug,
      o9:   offense[:guards][1]&.slug,
      o10:  offense[:tackles][0]&.slug,
      o11:  offense[:tackles][1]&.slug,
      d1:   defense[:defensive_ends][0]&.slug,
      d2:   defense[:defensive_ends][1]&.slug,
      d3:   defense[:edge_rushers][0]&.slug,
      d4:   defense[:edge_rushers][1]&.slug,
      d5:   defense[:linebackers][0]&.slug,
      d6:   defense[:linebackers][1]&.slug,
      d7:   defense[:safeties][0]&.slug,
      d8:   defense[:safeties][1]&.slug,
      d9:   defense[:cornerbacks][0]&.slug,
      d10:  defense[:cornerbacks][1]&.slug,
      d11:  defense[:flex]&.slug
    )
  end

  # Summary of Kaggle games supported by SportsOddsHistory
  def self.kaggle_summary
    # Get games for summary
    games = Game.kaggle.season(2023).primetime.order(:date)
    # Create data array for processing later
    kaggle_games_array = games.map do |game|
      obj = {away_team: game.away_team, home_team: game.home_team}
      next obj unless home_team = Team.find_by(active: true, slug: game.home_team.upcase)
      next obj unless away_team = Team.find_by(active: true, slug: game.away_team.upcase)
      obj[:day_of_week] = game.day_of_week
      obj[:start_time] = game.start_time
      obj[:date] = game.date
      obj[:week] = game.week
      obj[:season] = game.season
      obj[:away_team] = away_team.name
      obj[:away_team_slug] = away_team.slug
      obj[:away_total] = game.away_total
      obj[:home_team] = home_team.name
      obj[:home_team_slug] = home_team.slug
      obj[:home_total] = game.home_total
      obj[:total_points] = game.total_points
      obj[:over_under] = game.over_under
      obj[:over_under_result] = game.over_under_result
      obj[:week] = game.week
      obj
    end

    # Add sportsoddshistory data to kaggle games
    kaggle_games_array.map! do |obj|
      # Add sportsoddshistory data for game if there is some
      if sportsoddshistory_game = Game.sportsoddshistory.find_by(date: obj[:date], home_team: obj[:home_team_slug], away_team: obj[:away_team_slug])
        obj[:sportsoddshistory_total_points] = sportsoddshistory_game.total_points
        obj[:sportsoddshistory_over_under] = sportsoddshistory_game.over_under
        obj[:sportsoddshistory_over_under_result] = sportsoddshistory_game.over_under_result
        obj[:sportsoddshistory_over_under_odds] = sportsoddshistory_game.over_under_odds
      end
      obj
    end

    # Initalize week for printing a change in week
    week = nil

    kaggle_games_array.each do |p|
      if week != p[:week]
        puts "="*40 
        puts "Week: #{p[:week]} " 
        puts "-"*40
        week = p[:week]
      end

      # Day of the week
      game_print = "#{p[:day_of_week]} @ #{p[:start_time]} on #{p[:date]} "

      # NFL Week
      game_print += " "*(32-game_print.length)
      game_print += "| Week #{p[:week]} "

      # Game
      game_print += " "*(50-game_print.length)
      game_print += "| (#{p[:away_total]}) #{p[:away_team]} @ (#{p[:home_total]}) #{p[:home_team]}"

      # Over Under
      game_print += " "*(110-game_print.length)
      game_print += "| 🐙 #{p[:total_points]} #{p[:over_under_result]}, ou: #{p[:over_under]}"

      # Over Under (sportsoddshistory)
      game_print += " "*(140-game_print.length)
      game_print += "| 🏃🏻 #{p[:sportsoddshistory_total_points]} #{p[:sportsoddshistory_over_under_result]}, ou: #{p[:sportsoddshistory_over_under]}"
      
      puts game_print
    end
    return "Done"
  end

  def over_under_result
    return "🔴 Over" if self.total_points.to_i > self.over_under.to_i
    return "🟢 Under" if self.total_points.to_i < self.over_under.to_i
    return "🌕 Push"
  end

  def self.most_common_scores
    # Initialize unsorted_scores
    unsorted_scores = {}
    games_csv = []
    # Get all games
    total_games = all.count
    # Each through games
    all.each do |game|
      # Get score of game
      score = game.total_points
      # Create or iterate score in unsorted_scores
      if unsorted_scores[score].nil?
        unsorted_scores[score] = 1
      else
        unsorted_scores[score] += 1
      end

      games_csv.push("#{game.total_points}")
    end
    # Sort unsorted_scores by count of games
    sorted_keys = unsorted_scores.keys.sort_by { |key| unsorted_scores[key] }
    sorted_obj = {}
    sorted_keys.reverse.each { |key| sorted_obj[key] = unsorted_scores[key] }
    # Print sorted scores
    sorted_obj.each do |key, val|
      puts "Score: #{key} | Amount: #{val} | Percent: #{((val.to_f/total_games)*100).to_i}%"
    end
    puts games_csv
    # Return string
    "Complete"
  end

  # Summary of game
  def summary 
    # Initialize output string
    output_sting = ""
    home_team = Team.find_by(slug: self.home_slug)
    away_team = Team.find_by(slug: self.away_slug)
    # Add primetime badge
    output_sting += "[ 🏟️  Primetime Game ] | " if self.primetime
    # Date string
    output_sting += "#{day_of_week} @ #{start_time} on #{date} | #{week_slug} | " if self.day_of_week
    # Add game summary
    output_sting += "#{away_team.name} (#{away_total}) @ #{home_team.name} (#{home_total}) "
    output_sting += "| ou: #{over_under} (#{over_under_result})" if self.over_under 
    puts output_sting
  end

  def home_team_obj
    Team.find_by(active: true, slug: team_attrs['team_home'])
  end

  def self.sportsradar_import(game_uuid="abc-123-def-456")
    superbowl_json = "lib/sportradar/2024-game-superbowl-play-by-play.json"
    json_data = JSON.parse(File.read(Rails.root.join(superbowl_json)))

    json_data['periods'].each do |period|

      # puts "======"
      # puts "New Period"
      # puts "======"
      # ap period
      # puts "------"
      puts "================================="
      puts "🪙 #{period['number']} Quarter"
      # puts "================================="

# {
#     "period_type" => "quarter",
#              "id" => "e6f42e4b-0146-4143-b24c-f97f991455e8",
#          "number" => 4,
#        "sequence" => 4,
#         "scoring" => {
#         "home" => {
#                 "id" => "386bdbf9-9eea-4869-bb9a-274b0bc66e80",
#               "name" => "Eagles",
#             "market" => "Philadelphia",
#              "alias" => "PHI",
#              "sr_id" => "sr:competitor:4428",
#             "points" => 6
#         },
#         "away" => {
#                 "id" => "6680d28d-d4d2-49f6-aace-5292d3ec02c2",
#               "name" => "Chiefs",
#             "market" => "Kansas City",
#              "alias" => "KC",
#              "sr_id" => "sr:competitor:4422",
#             "points" => 16
#         }


      period['pbp'].each do |drive|

        # puts "======"
        # puts "New Drive"
        # puts "======"
        # ap drive
        # puts "---------------------------------"
        puts "================================="
        puts "🚙 Drive | #{drive['start_clock']}"


        if drive['events'].nil?
          puts "No events for drive"
          next
        end

        drive['events'].each do |play|
          # puts "======"
          # puts "New Play"
          # puts "======"
          # ap play["description"]
          # ap play
          # puts "------"


          if play['play_type'] == "kickoff"
            type = "🦶 Kickoff"
          elsif play['play_type'] == "rush"
            type = "🏃🏻 Rush"
          elsif play['play_type'] == "pass"
            type = "🏈 Pass"
          elsif play['play_type'] == "field_goal"
            type = "🎯 Field Goal"
          elsif play['play_type'] == "extra_point"
            type = "🏆 Extra Point"
          elsif play['play_type'] == "conversion"
            type = "🏆 Two Point Conversion"
          else
            type = "🔴 Unknown"
          end

          # puts "#%-2d | %-50s | %-15s" % [type, play['description'], play['play_type']]

          puts "%-30s | %-10s | %-50s" % [type, play['play_type'], play['description']]

        end

        # Play.create(
          # game_uuid: game_uuid,
          # play_uuid: play['id'],
          # play_type: play['type'])
      end
    end

    "Done"
    
    # # Create or update the season record
    # season_record = find_or_initialize_by(
    #   year: json_data['year'],
    #   season_type: json_data['type']
    # )
    
    # season_record.name = json_data['name']
    # season_record.save!
    
    # season_record
  end


  def home_team
    Team.find_by(slug: home_slug)
  end
  def away_team
    Team.find_by(slug: away_slug)
  end

  def self.kaggle_import
    require 'csv'
    # Parse CSV
    csv_text = File.read('lib/kaggle/spreadspoke_scores.csv')
    csv = CSV.parse(csv_text, headers: true)

    # Each through rows in CSV
    csv.reverse_each do |row|

      # Get team attributes from row
      team_attrs = row.to_hash

      # Validate date_of_game can be found
      next unless date_of_game = Date.strptime(team_attrs['schedule_date'], "%m/%d/%Y") rescue nil # Date in MM/DD/YYYY format
      # Validate home and away teams can be found
      next unless h_team = Team.find_by(active: true, name: team_attrs['team_home'])
      next unless a_team = Team.find_by(active: true, name: team_attrs['team_away'])
      # Validate week and season can be found
      next unless week = team_attrs['schedule_week']
      next unless season = team_attrs['schedule_season']

      # Find or create game.
      game = Game.find_or_create_by(
        source: :kaggle, 
        season: season, 
        week_slug: week.to_s, 
        home_team: h_team.slug, 
        away_team: a_team.slug
      )
      # Add additional game data.
      game.home_total = team_attrs['score_home']
      game.away_total = team_attrs['score_away']
      game.total_points = game.home_total + game.away_total
      game.over_under = team_attrs['over_under_line']
      game.over_under_odds = 0.95
      game.date = date_of_game
      game.day_of_week = date_of_game.strftime('%A')

      # Get same game from sportsoddshistory
      if sportsoddshistory_game = Game.sportsoddshistory.find_by(date: date_of_game, home_team: home_team.slug, away_team: away_team.slug)
        game.start_time = sportsoddshistory_game.start_time
        game.primetime = sportsoddshistory_game.primetime
        game.overtime = sportsoddshistory_game.overtime
      end
      # Save game
      game.save 
      puts "🏈 #{game.season} | #{game.week_slug} | #{game.away_team} at #{game.home_team} Saved"
    end
  end

  def self.scrape_last(years=8)
    # Init focus year (started with 2024)
    focus_year = 2025
    # Each through years
    (focus_year - years...focus_year).to_a.reverse.each do |year|
      puts "Scraping season #{year}..."
      sportsoddshistory_scrape_season(year)
    end
  end

  def self.sportsoddshistory_scrape_season(season='2023')

    return "Teams not initialized.  Run `Team.kaggle_import`" unless Team.active.count == 32

      # Load page
      url = "https://www.sportsoddshistory.com/nfl-game-season/?y=#{season}"
      url_text = Net::HTTP.get(URI.parse url)
      doc = Nokogiri::HTML(url_text)

      puts "Page loaded ..."
      weeks_loaded = 100
      
      # Each through weeks
      doc.css('.soh1').each_with_index do |game_element, index|

          # First two "weeks" are Results by week and Results by team
          week = index - 1

          # Skip header tables
          next unless week >= 1

          # Skip after limit
          break if week > weeks_loaded + 1

          puts "Loading Week #{week} ..."
      
          # Pull game from week summary
          row = game_element.css('tr')
          
          # Each through columns in row
          row.each_with_index do |game_row, index|
              
              # Skip header column
              next if index == 0
              # Skip if the is missing columns (for some reason)
              next unless game_row.css('td')[0]
              # Scrape game data.
              sportsoddshistory_scrape_game(game_row,season,week)
          end
          # Set multiples
          Game.where(source: :sportsoddshistory, season: season, week_slug: week.to_s).set_week_multiples
      end
      return "Finished"
  end

  def self.sportsoddshistory_scrape_game(game, season=2023, week=1)

    # Pull columns from game row
    col0 = game.css('td')[0].text.strip
    col1 = game.css('td')[1].text.strip
    col2 = game.css('td')[2].text.strip
    col3 = game.css('td')[3].text.strip
    col4 = game.css('td')[4].text.strip
    col5 = game.css('td')[5].text.strip
    col6 = game.css('td')[6].text.strip
    col7 = game.css('td')[7].text.strip
    col8 = game.css('td')[8].text.strip
    col9 = game.css('td')[9].text.strip
    col10 = game.css('td')[10].text.strip rescue ""
    # Puts columns for visibility
    puts "= Row ==================================="
    puts "Col 0: #{col0}"
    puts "Col 1: #{col1}"
    puts "Col 2: #{col2}"
    puts "Col 3: #{col3}"
    puts "Col 4: #{col4}"
    puts "Col 5: #{col5}"
    puts "Col 6: #{col6}"
    puts "Col 7: #{col7}"
    puts "Col 8: #{col8}"
    puts "Col 9: #{col9}"

    # Evaluate if game is a playoff game
    if col0.include?("Wild") || col0.include?("Divisional") || col0.include?("Championship") || col0.include?("Super")
      # Playoff Game
      week = col0
      day_of_week = col1
      date_of_game = col2
      time_of_game = col3
      favorite = col5
      favorite_home = col4
      score = col6
      spread = col7
      underdog = col9
      underdog_home = col8
      over_under = col10
      # Parse favorite name and seed
      favorite_array = favorite.split("(")
      favorite = favorite_array.first.strip
      favorite_seed = favorite_array.last.tr('^0-9', '').to_i
      # Parse underdog name and seed
      underdog_array = underdog.split("(")
      underdog = underdog_array.first.strip
      underdog_seed = underdog_array.last.tr('^0-9', '').to_i
    else
      # None Playoff Game
      week = week
      day_of_week = col0
      date_of_game = col1
      time_of_game = col2
      favorite = col4
      favorite_home = col3
      score = col5
      spread = col6
      underdog = col8
      underdog_home = col7
      over_under = col9
    end

    # Parse OT
    was_there_ot = false
    if score.include? "(OT)"
        was_there_ot = true
    end

    # Parse favorite and underdog points
    favorite_points = score.split("-").first.tr('^0-9', '')
    underdog_points = score.split("-").last.tr('^0-9', '')
    total_points = favorite_points.to_i + underdog_points.to_i

    # Parse spred and over / under (Remove non-numeric characters (plus '.') and convert to float)
    over_under_float = over_under.tr('^0-9+\.', '').to_f
    spread_float = spread.tr('^0-9+\.', '').to_f
    half_points = over_under_float/2

    # Set over/under result
    over_under_result = "push"
    over_under_result = "over" if over_under_float < total_points
    over_under_result = "under" if over_under_float > total_points

    # Parse Prime Time Game
    primetime = false
    primetime = true if day_of_week.include? "Thu"
    primetime = true if day_of_week.include? "Mon"
    primetime = true if time_of_game.include? "8:20"    # Standard SNF
    primetime = true if time_of_game.include? "7:15"    # Two game MNF (early)
    primetime = true if time_of_game.include? "8:15"    # Two game MNF (late)
    primetime = true if time_of_game.include? "3:00"    # AFC Championship
    primetime = true if time_of_game.include? "6:30"    # Superbowl
    primetime = true if day_of_week.include? "Fri"      # Black Friday Game
    primetime = true if day_of_week.include? "Sat"      # Saturday Games

    # Get date of game
    game_date = Date.parse("#{date_of_game}")
    kickoff_at = Game.parse_datetime(time_of_game, game_date)

    # Evaluate if favorite is home or away
    if favorite_home == "@"
        h_team = Team.sportsoddshistory_team(favorite)
        home_total = favorite_points
        home_team_seed = favorite_seed if favorite_seed
        a_team = Team.sportsoddshistory_team(underdog)
        away_total = underdog_points
        away_team_seed = underdog_seed if underdog_seed
        # Set spreads
        away_spread = spread_float
        home_spread = spread_float * -1
        # Set implied totals
        away_implied_total = (half_points - spread_float/2).to_i
        home_implied_total = (half_points + spread_float/2).to_i
    else
        h_team = Team.sportsoddshistory_team(underdog)
        home_total = underdog_points
        home_team_seed = underdog_seed if underdog_seed
        a_team = Team.sportsoddshistory_team(favorite)
        away_total = favorite_points
        away_team_seed = favorite_seed if favorite_seed
        # Set spreads
        home_spread = spread_float
        away_spread = spread_float * -1
        # Set implied totals
        away_implied_total = (half_points + spread_float/2).to_i
        home_implied_total = (half_points - spread_float/2).to_i
    end
    # Create slug & game
    slug = "#{a_team.slug}-#{h_team.slug}-#{week}-#{season}".downcase
    game = Game.find_or_create_by(slug: slug)

    puts "-"*40
    puts "Season: #{season}"
    puts "Week: #{week}"
    puts "Home: (#{home_total}) #{h_team.name}"
    puts "Away: (#{away_total}) #{a_team.name}"
    puts "Home Lines: #{home_spread} | #{home_implied_total} #{h_team.name}"
    puts "Away Lines: #{away_spread} | #{away_implied_total} #{a_team.name}"
    puts "Over / Under: #{over_under_float} | #{over_under_result}"

    # Add additional game data.
    game.update(
      source: :sportsoddshistory, 
      season: season, 
      week_slug: week.to_s, 
      home_slug: h_team.slug, 
      away_slug: a_team.slug,
      overtime: was_there_ot,
      primetime: primetime,
      home_total: home_total, 
      away_total: away_total, 
      total_points: total_points,
      over_under: over_under_float, 
      over_under_odds: 0.95,
      over_under_result: over_under_result,
      kickoff_at: kickoff_at,
      date: game_date,
      day_of_week: day_of_week,
      start_time: time_of_game,
      away_spread: away_spread,
      away_implied_total: away_implied_total,
      home_spread: home_spread,
      home_implied_total: home_implied_total,
    )
    # Puts summary of game.

    game.summary
    # Return game
    game
  end

  def self.set_week_multiples
    highest_total = all.highest_implied_total
    # Each through games
    all.each do |game|
      # Calculate multiple
      away_multiple = (highest_total / game.away_implied_total).round(2)
      home_multiple = (highest_total / game.home_implied_total).round(2)
      # Update game multiples
      game.update(away_multiple: away_multiple)
      game.update(home_multiple: home_multiple)
    end
  end

  # Summary of season
  def self.season_summary(season)
      Game.where(season: season).each do |game|
          game.summary
      end
      puts "Finished"
  end

  def self.primetime_under_report
      overs = 0
      unders = 0
      pushes = 0
      primetime_games = all.where(primetime: true).count
      all.where(primetime: true).each do |game|
          overs += 1 if game.total_points > game.over_under
          unders += 1 if game.total_points < game.over_under
          pushes += 1 if game.total_points == game.over_under
      end
      win_percent = ((unders.to_f/primetime_games) * 100).to_i
      units_won = (unders*0.95) - overs
      puts "Win: #{win_percent}%"
      {overs: overs, unders: unders, pushes: pushes, win_percent: win_percent, units_won: units_won}
  end

  def self.primetime_under_report_historical
      # Pull seasons with data
      seasons_with_data = all.seasons
      # Seach through seasons with data
      seasons_with_data.each do |season|
          report = Game.where(season: season).primetime_under_report
          games = (report[:overs] + report[:unders] + report[:pushes])
          puts "="*40
          puts report[:unders]
          puts report[:unders].to_f
          puts games
          puts ((report[:unders].to_f / games) * 100)
          puts "="*40
          win_percent = ((report[:unders].to_f / games) * 100).to_i
          puts "Season: #{season} | Win %: #{win_percent}% | Games: #{games} | Unders: #{report[:unders]} | Overs: #{report[:overs]} | Pushes: #{report[:pushes]}"
      end
  end

  def self.score_frequency_report
    score_counts = Hash.new(0)

    # Count occurrences of scores in away_total and home_total
    all.each do |game|
      score_counts[game.away_total] += 1 if game.away_total
      score_counts[game.home_total] += 1 if game.home_total
    end

    # Sort scores by frequency in descending order
    sorted_scores = score_counts.sort_by { |_score, count| -count }.to_h

    # Print the report in CSV format
    puts "Copy into Number ⬇️"
    puts "Score,Times"
    sorted_scores.each do |score, count|
      puts "#{score},#{count}"
    end

    sorted_scores
  end

  def self.total_frequency_report
    score_counts = Hash.new(0)

    # Count occurrences of scores in away_total and home_total
    all.each do |game|
      score_counts[game.total_points] += 1 if game.total_points
    end

    # Sort scores by frequency in descending order
    sorted_scores = score_counts.sort_by { |_score, count| -count }.to_h

    # Print the report in CSV format
    puts "Copy into Number ⬇️"
    puts "Score,Times"
    sorted_scores.each do |score, count|
      puts "#{score},#{count}"
    end

    sorted_scores
  end

  def self.highest_implied_total
    highest_game = all.max_by do |game|
      [game.away_implied_total, game.home_implied_total].max
    end

    if highest_game
      # Get highest implied total from game
      [highest_game.away_implied_total, highest_game.home_implied_total].max
    else
      puts "No games found."
      nil
    end
  end

  def self.s24
    all.where(season: 2024)
  end

  def self.s25
    all.where(season: 2025)
  end

  def self.w1
    all.where(week_slug: "1")
    # all.where(week: 1).order(:kickoff_at)
  end

  def self.w2
    all.where(season: 2)
  end


  def self.week_1_reports
    # Select week 1 games
    week_1_games = all.where(season: 2024, week_slug: "1")
    # Find week high
    array = []
    # Each through games
    week_1_games.each do |game|
      # Push to array
      array.push("#{game.away_team},#{game.away_total},#{game.away_implied_total},#{game.away_multiple},#{game.week_slug}")
      array.push("#{game.home_team},#{game.home_total},#{game.home_implied_total},#{game.home_multiple},#{game.week_slug}")
    end
    puts "Team,Implied Total,Multiple,Week"
    puts array
  end

  def self.season_2024_report
    # Select week 1 games
    season_2024_games = all.where(season: 2024).order(:date)
    # season_2024_games = all.where(season: 2024)
    # season_2024_games = all.where(season: 2024)
    # Find week high
    array = []
    # Each through games
    season_2024_games.each do |game|
      # Push to array
      array.push("#{game.away_team},#{game.away_total},#{game.away_multiple},#{game.week_slug},#{game.season}")
      array.push("#{game.home_team},#{game.home_total},#{game.home_multiple},#{game.week_slug},#{game.season}")
    end
    puts "Team,Real Total,Multiple,Week,Season"
    puts array
  end

  def self.parse_datetime(time_of_game, game_date)
    # Combine game_date and time_of_game into a DateTime object in Eastern Time Zone
    eastern_time_zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
    datetime_string = "#{game_date} #{time_of_game} PM" # Assume PM for NFL games
    eastern_time_zone.parse(datetime_string)
  end

  def self.create_games_from_csv(file_path)
    require 'csv'

    csv_text = File.read(file_path)
    csv = CSV.parse(csv_text, headers: true)

    csv.each do |row|
      # Parse row data
      week = row['Week']
      day_of_week = row['Day']
      date_of_game = Date.parse(row['Date'])
      time_of_game = row['Time_ET']
      visitor_team_name = row['Visitor']
      home_team_name = row['Home']
      tv_network = row['TV']

      # Find or create teams
      visitor_team = Team.find_by(active: true, name: visitor_team_name)
      home_team = Team.find_by(active: true, name: home_team_name)
      next unless visitor_team && home_team

      # Determine if the game is primetime
      primetime = %w[8:20p 8:15p 7:00p 10:00p].include?(time_of_game)

      # Create slug for the game
      slug = "#{visitor_team.slug}-#{home_team.slug}-#{week}-2025".downcase

      # Find or create the game
      game = Game.find_or_create_by(slug: slug) do |g|
        g.season = 2025
        g.week_slug = week.to_s
        g.home_slug = home_team.slug
        g.away_slug = visitor_team.slug
        g.date = date_of_game
        g.day_of_week = day_of_week
        g.start_time = time_of_game
        g.primetime = primetime
        # g.tv_network = tv_network
      end

      puts "🏈 Game created: #{game.season} | Week #{game.week_slug} | #{game.away_team} at #{game.home_team}"
    end
  end

end