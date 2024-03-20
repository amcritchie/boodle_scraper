# require 'open-uri'
require 'net/http'
require 'net/https'
require 'nokogiri'
require 'progress_bar'

class Game < ApplicationRecord

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
  def self.season(season=2023)
    all.where(season: season)
  end
  # Pluck seasons from games
  def self.seasons
    all.pluck(:season).uniq.sort
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
    return "🔴 Over" if self.total_points > self.over_under
    return "🟢 Under" if self.total_points < self.over_under
    return "🌕 Push"
  end

  # Summary of game
  def summary 
    # Initialize output string
    output_sting = ""
    home_team = Team.find_by(slug: self.home_team.upcase)
    away_team = Team.find_by(slug: self.away_team.upcase)
    # Add primetime badge
    output_sting += "[🏟️ Primetime Game] | " if self.primetime
    # Date string
    output_sting += "#{day_of_week} @ #{start_time} on #{date} | #{week} | " if self.day_of_week
    # Add game summary
    output_sting += "#{away_team.name} (#{away_total}) @ #{home_team.name} (#{home_total}) "
    output_sting += "| ou: #{over_under} (#{over_under_result})" if self.over_under 
    puts output_sting
  end

  def home_team_obj
    Team.find_by(active: true, slug: team_attrs['team_home'])
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
      next unless home_team = Team.find_by(active: true, name: team_attrs['team_home'])
      next unless away_team = Team.find_by(active: true, name: team_attrs['team_away'])
      # Validate week and season can be found
      next unless week = team_attrs['schedule_week']
      next unless season = team_attrs['schedule_season']

      # Find or create game.
      game = Game.find_or_create_by(
        source: :kaggle, 
        season: season, 
        week: week, 
        home_team: home_team.slug, 
        away_team: away_team.slug
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
      puts "🏈 #{game.season} | #{game.week} | #{game.away_team} at #{game.home_team} Saved"
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

      # Parse over / under (Remove non-numeric characters (plus '.') and convert to float)
      over_under_float = over_under.tr('^0-9+\.', '').to_f

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

      # Evaluate if favorite is home or away
      if favorite_home == "@"
          home_team = Team.sportsoddshistory_team_name_map(favorite)
          home_total = favorite_points
          home_team_seed = favorite_seed if favorite_seed
          away_team = Team.sportsoddshistory_team_name_map(underdog)
          away_total = underdog_points
          away_team_seed = underdog_seed if underdog_seed
      else
          home_team = Team.sportsoddshistory_team_name_map(underdog)
          home_total = underdog_points
          home_team_seed = underdog_seed if underdog_seed
          away_team = Team.sportsoddshistory_team_name_map(favorite)
          away_total = favorite_points
          away_team_seed = favorite_seed if favorite_seed
      end

      puts "-"*40
      puts "Season: #{season}"
      puts "Week: #{week}"
      puts "Home: (#{home_total}) #{home_team.name}"
      puts "Away: (#{away_total}) #{away_team.name}"

      # Find or create game.
      game = Game.find_or_create_by(
          source: :sportsoddshistory, 
          season: season, 
          week: week, 
          home_team: home_team, 
          away_team: away_team
      )
      # Add additional game data.
      game.update(
          overtime: was_there_ot,
          primetime: primetime,
          home_total: home_total, 
          away_total: away_total, 
          total_points: total_points,
          over_under: over_under_float, 
          over_under_odds: 0.95,
          date: game_date,
          day_of_week: day_of_week,
          start_time: time_of_game,
      )
      # Puts summary of game.
      game.summary
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
end