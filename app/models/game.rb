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

  def self.print_summary
    prints = all.order(:date).map do |game|
      obj = {away_team: game.away_team, home_team: game.home_team}
      next obj unless home_team = Team.find_by(active: true, slug: game.home_team.upcase)
      next obj unless away_team = Team.find_by(active: true, slug: game.away_team.upcase)
      obj[:day_of_week] = game.day_of_week
      obj[:start_time] = game.start_time
      obj[:date] = game.date
      obj[:week] = game.week
      obj[:season] = game.season
      obj[:away_team] = away_team.name
      obj[:away_total] = game.away_total
      obj[:home_team] = home_team.name
      obj[:home_total] = game.home_total
      obj[:total_points] = game.total_points
      obj[:week] = game.week
      obj
    end
    week = nil
    prints.each do |p|
      if week != p[:week]
        puts "="*40 
        puts "Week: #{p[:week]} " 
        puts "-"*40
        week = p[:week]
      end
      puts "#{p[:day_of_week]} @ #{p[:start_time]} on #{p[:date]} | #{p[:week]} | (#{p[:away_total]}) #{p[:away_team]} @ (#{p[:home_total]}) #{p[:home_team]}"
    end
    return "Done"
  end

  def over_under_result
    if self.total_points > self.over_under
        "Over"
    elsif self.total_points < self.over_under
        "Under"
    else
        "Push"
    end
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
      if sportsoddshistory_game = Game.sportsoddshistory.find_by(date: date_of_game, home_team: home_team.slug.downcase, away_team: away_team.slug.downcase)
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

    def self.sportsoddshistory_scrape_game(game, season='2023', week='w1')
        # Pull data from game row
        day_of_week = game.css('td')[0].text.strip
        date_of_game = game.css('td')[1].text.strip
        time_of_game = game.css('td')[2].text.strip
        favorite = game.css('td')[4].text.strip
        favorite_home = game.css('td')[3].text.strip
        score = game.css('td')[5].text.strip
        spread = game.css('td')[6].text.strip
        underdog = game.css('td')[8].text.strip
        underdog_home = game.css('td')[7].text.strip
        over_under = game.css('td')[9].text.strip

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
        primetime = true if day_of_week.include? "Fri"      # Black Friday Game
        primetime = true if day_of_week.include? "Sat"      # Saturday Games

        puts "-"*40
        puts day_of_week
        puts date_of_game
        puts time_of_game
        puts time_of_game.inspect
        puts "day_of_week: #{day_of_week}"
        puts "date_of_game: #{date_of_game}"
        puts "time_of_game: #{time_of_game}"
        puts time_of_game.include? "8:15"
        puts time_of_game == "8:15"
        puts "favorite: #{favorite}"
        puts "favorite_home: #{favorite_home}"
        puts "favorite_points: #{favorite_points}"
        puts "score: #{score}"
        puts "spread: #{spread}"
        puts "underdog: #{underdog}"
        puts "underdog_home: #{underdog_home}"
        puts "underdog_points: #{underdog_points}"
        puts "over_under: #{over_under}"
        puts "primetime: #{primetime}"
        puts "-"*40

        game_date = Date.parse("#{date_of_game}")

        if favorite_home == "@"
            home_team = Team.sportsoddshistory_team_name_map(favorite)
            home_total = favorite_points
            away_team = Team.sportsoddshistory_team_name_map(underdog)
            away_total = underdog_points
        else
            home_team = Team.sportsoddshistory_team_name_map(underdog)
            home_total = underdog_points
            away_team = Team.sportsoddshistory_team_name_map(favorite)
            away_total = favorite_points
        end

        puts "home_team: #{home_team}"
        puts "home_total: #{home_total}"
        puts "away_team: #{away_team}"
        puts "away_total: #{away_total}"
        puts "total_points: #{total_points}"
        puts "over_under_float: #{over_under_float}"

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
        all.where(primetime: true).each do |game|
            overs += 1 if game.total_points > game.over_under
            unders += 1 if game.total_points < game.over_under
            pushes += 1 if game.total_points == game.over_under
        end
        {overs: overs, unders: unders, pushes: pushes}
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