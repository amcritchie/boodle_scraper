# require 'open-uri'
require 'net/http'
require 'net/https'
require 'nokogiri'
require 'progress_bar'

class Game < ApplicationRecord

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
            home_team = sportsoddshistory_team_map(favorite)
            home_total = favorite_points
            away_team = sportsoddshistory_team_map(underdog)
            away_total = underdog_points
        else
            home_team = sportsoddshistory_team_map(underdog)
            home_total = underdog_points
            away_team = sportsoddshistory_team_map(favorite)
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
    end

    # Summary of game
    def summary 
        puts "="*40
        puts "#{away_team} (#{away_total}) at #{home_team} (#{home_total}) in week #{week} of the #{season} season. The #{away_team} are favored by #{away_spread} over the #{home_team} with an over/under of #{over_under} points. The final score was #{away_total} to #{home_total}."
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
        seasons_with_data = all.pluck(:season).uniq.sort
        # Seach through seasons with data
        seasons_with_data.each do |season|
            report = Game.where(season: season).primetime_under_report
            games = (report[:overs] + report[:unders] + report[:pushes])
            win_percent = ((report[:unders].to_f / games) * 100).to_i
            puts "Season: #{season} | Win %: #{win_percent}% | Games: #{games} | Unders: #{report[:unders]} | Overs: #{report[:overs]} | Pushes: #{report[:pushes]}"
        end
    end

    # Map team id for sportsoddshistory
    def self.sportsoddshistory_team_map(team_name)
        case team_name
        when "Buffalo Bills"              # AFC East
          :buf
        when "New York Jets"
          :nyj
        when "Miami Dolphins"
          :mia
        when "New England Patriots"
          :ne
        when "Kansas City Chiefs"       # AFC West
          :kc
        when "Denver Broncos"
          :den
        when "Los Angeles Chargers"
          :lac
        when "Las Vegas Raiders"
          :lv
        when "Cincinnati Bengals"       # AFC North
          :cin
        when "Baltimore Ravens"
          :bal
        when "Pittsburgh Steelers"
          :pit
        when "Cleveland Browns"
          :cle
        when "Jacksonville Jaguars"     # AFC South
          :jax
        when "Houston Texans"
          :hou
        when "Tennessee Titans"
          :ten
        when "Indianapolis Colts"
          :ind
        when "Green Bay Packers"        # NFC North
          :gb
        when "Minnesota Vikings"
          :min
        when "Chicago Bears"
          :chi
        when "Detroit Lions"
          :det
        when "Dallas Cowboys"           # NFC EAST
          :dal
        when "New York Giants"
          :nyg
        when "Philadelphia Eagles"
          :phi
        when "Washington Commanders"
          :was
        when "Seattle Seahawks"         # NFC West
          :sea
        when "Los Angeles Rams"
          :lar
        when "San Francisco 49ers"
          :sf
        when "Arizona Cardinals"
          :arz
        when "Atlanta Falcons"          # NFC South
          :atl
        when "Carolina Panthers"
          :car
        when "Tampa Bay Buccaneers"
          :tb
        when "New Orleans Saints"
          :no
        else
          :unknown
        end
    end
end