class Week < ApplicationRecord
  has_many :games, ->(week) { where(season: week.season_year, week_slug: week.sequence).order(:scheduled) }

  # Return all matchups for this week
  def matchups
    Matchup.where(season: season_year, week_slug: sequence)
  end

  # Return all teams_weeks for this week
  def teams_weeks
    TeamsWeek.where(season_year: season_year, week_number: sequence)
  end

  def self.week1
    all.find_by(sequence: 1)
  end

  def display_name
    case sequence
    when 1..18
      "Week #{sequence}"
    when 19
      "Wild Card Game"
    when 20
      "Divisional Round"
    when 21
      "Conference Championship"
    when 22
      "Super Bowl"
    else
      "Week #{sequence}"
    end
  end

  def games
    return 'no-sports-radar-id' if sportsradar_id.blank?
    Game.where(season: season_year, week_slug: sequence).where.not(sportsradar_id: nil)
  end

  @@only_one_game = false

  def sport_radar_week
      puts "================================================"
      puts "Week #{self.sequence.to_s.rjust(2)} #{self.season_year}"
      # Initialize week population
      self.initialize_population

      time_start = Time.now
      # Each through games in week
      self.games.each do |game|

        # next unless game.slug == "sf-ari-18-2024" # Just one game

        # Initialize game scoring fields
        game.initialize_scoring_fields

        # Iterate game count
        self.games_count += 1
        self.save!

        # # Generate matchups
        # game.away_matchup
        # game.home_matchup

        game.sport_radar_play_by_play_seed

        # Reload game to get updated scoring data
        game.reload

        # Update passing touchdown categories for home team
        if game.home_passing_touchdowns >= 24
          self.passing_tds_4 += 1
        elsif game.home_passing_touchdowns >= 18
          self.passing_tds_3 += 1
        elsif game.home_passing_touchdowns >= 12
          self.passing_tds_2 += 1
        elsif game.home_passing_touchdowns >= 6
          self.passing_tds_1 += 1
        else
          self.passing_tds_0 += 1
        end

        # Update passing touchdown categories for away team
        if game.away_passing_touchdowns >= 24
          self.passing_tds_4 += 1
        elsif game.away_passing_touchdowns >= 18
          self.passing_tds_3 += 1
        elsif game.away_passing_touchdowns >= 12
          self.passing_tds_2 += 1
        elsif game.away_passing_touchdowns >= 6
          self.passing_tds_1 += 1
        else
          self.passing_tds_0 += 1
        end

        # Update rushing touchdown categories for home team
        if game.home_rushing_touchdowns >= 24
          self.rushing_tds_4 += 1
        elsif game.home_rushing_touchdowns >= 18
          self.rushing_tds_3 += 1
        elsif game.home_rushing_touchdowns >= 12
          self.rushing_tds_2 += 1
        elsif game.home_rushing_touchdowns >= 6
          self.rushing_tds_1 += 1
        else
          self.rushing_tds_0 += 1
        end

        # Update rushing touchdown categories for away team
        if game.away_rushing_touchdowns >= 24
          self.rushing_tds_4 += 1
        elsif game.away_rushing_touchdowns >= 18
          self.rushing_tds_3 += 1
        elsif game.away_rushing_touchdowns >= 12
          self.rushing_tds_2 += 1
        elsif game.away_rushing_touchdowns >= 6
          self.rushing_tds_1 += 1
        else
          self.rushing_tds_0 += 1
        end

        # Update field goal categories for home team
        if game.home_field_goals >= 15
          self.field_goals_5 += 1
        elsif game.home_field_goals >= 12
          self.field_goals_4 += 1
        elsif game.home_field_goals >= 9
          self.field_goals_3 += 1
        elsif game.home_field_goals >= 6
          self.field_goals_2 += 1
        elsif game.home_field_goals >= 3
          self.field_goals_1 += 1
        else
          self.field_goals_0 += 1
        end

        # Update field goal categories for away team
        if game.away_field_goals >= 15
          self.field_goals_5 += 1
        elsif game.away_field_goals >= 12 
          self.field_goals_4 += 1
        elsif game.away_field_goals >= 9
          self.field_goals_3 += 1
        elsif game.away_field_goals >= 6
          self.field_goals_2 += 1
        elsif game.away_field_goals >= 3
          self.field_goals_1 += 1
        else
          self.field_goals_0 += 1
        end

        # Save the updated counts
        self.save!

        # Add to score summary
        $score_summary.push("#{self.season_year},#{self.sequence},#{game.home_team.slug},#{game.home_passing_touchdowns},#{game.home_rushing_touchdowns},#{game.home_field_goals},#{game.home_extra_points},#{game.alt_points}")
        $score_summary.push("#{self.season_year},#{self.sequence},#{game.away_team.slug},#{game.away_passing_touchdowns},#{game.away_rushing_touchdowns},#{game.away_field_goals},#{game.away_extra_points},0")
        
        sleep(1)
        # Only process game
        break if @@only_one_game
      end

      time_end = Time.now
      puts "="*100
      puts "==== Week Finished ===="
      puts "="*100
      puts "Time taken: #{time_end - time_start} seconds - #{self.games_count} games - #{self.sequence} #{self.season_year}"
      puts "------------------------------------------------"
  end

  def initialize_population
    self.games_count              = 0
    self.rushing_touchdowns       = 0
    self.passing_touchdowns       = 0
    self.defensive_touchdowns     = 0
    self.special_teams_touchdowns = 0
    self.field_goals              = 0
    self.extra_points             = 0 # 1pt
    self.two_point_conversions    = 0
    self.interceptions            = 0 # 1pt
    self.fumbles                  = 0 # 1pt
    self.sacks                    = 0 # 1pt
    
    # Initialize scoring category counters
    self.passing_tds_4 = 0
    self.passing_tds_3 = 0
    self.passing_tds_2 = 0
    self.passing_tds_1 = 0
    self.passing_tds_0 = 0
    
    self.rushing_tds_4 = 0
    self.rushing_tds_3 = 0
    self.rushing_tds_2 = 0
    self.rushing_tds_1 = 0
    self.rushing_tds_0 = 0
    
    self.field_goals_5 = 0
    self.field_goals_4 = 0
    self.field_goals_3 = 0
    self.field_goals_2 = 0
    self.field_goals_1 = 0
    self.field_goals_0 = 0
    
    self.save!
  end

  def scoring_categories_summary
    {
      passing_games: passing_tds_4 + passing_tds_3 + passing_tds_2 + passing_tds_1 + passing_tds_0,
      rushing_games: rushing_tds_4 + rushing_tds_3 + rushing_tds_2 + rushing_tds_1 + rushing_tds_0,
      fg_games: field_goals_5 + field_goals_4 + field_goals_3 + field_goals_2 + field_goals_1 + field_goals_0,
      passing_tds: {
        tds_4: passing_tds_4,
        tds_3: passing_tds_3,
        tds_2: passing_tds_2,
        tds_1: passing_tds_1,
        tds_0: passing_tds_0
      },
      rushing_tds: {
        tds_4: rushing_tds_4,
        tds_3: rushing_tds_3,
        tds_2: rushing_tds_2,
        tds_1: rushing_tds_1,
        tds_0: rushing_tds_0
      },
      field_goals: {
        fg_5: field_goals_5,
        fg_4: field_goals_4,
        fg_3: field_goals_3,
        fg_2: field_goals_2,
        fg_1: field_goals_1,
        fg_0: field_goals_0
      }
    }
  end

  # Types of scores
  def self.scoring_summary
    puts "================================================"
    puts "Scoring Summary"
    puts "================================================"
    csv = ['games,season,week,field_goals,rushing_tds,passing_tds,zero_score_count,score_1fg,score_2fg,score_3fg,score_4fg,score_5fg,score_1rtd_0fg,score_1rtd_1fg,score_1rtd_2fg,score_1rtd_3fg,score_1rtd_4fg,score_1rtd_5fg,score_1rtd_1ptd_0fg,score_1rtd_1ptd_1fg,score_1rtd_1ptd_2fg,score_1rtd_1ptd_3fg,score_1rtd_1ptd_4fg,score_1rtd_1ptd_5fg,score_1ptd_0fg,score_1ptd_1fg,score_1ptd_2fg,score_1ptd_3fg,score_1ptd_4fg,score_1ptd_5fg,score_2ptd_0fg,score_2ptd_1fg,score_2ptd_2fg,score_2ptd_3fg,score_2ptd_4fg,score_2ptd_5fg,score_2rtd_0fg,score_2rtd_1fg,score_2rtd_2fg,score_2rtd_3fg,score_2rtd_4fg,score_2rtd_5fg']
    all.each do |week|
      puts "Week #{week.sequence} #{week.season_year}"
      puts "Field Goals: #{week.field_goals}"
      puts "Rushing Touchdowns: #{week.rushing_touchdowns}"
      puts "Passing Touchdowns: #{week.passing_touchdowns}"
      
      # Get per game stats using the helper method
      zero_score_count = (week.games.games_search(0,0,0).count.to_f / week.games_count).round(2)
      score_1fg = (week.games.games_search(3,0,0).count.to_f / week.games_count).round(2)
      score_2fg = (week.games.games_search(6,0,0).count.to_f / week.games_count).round(2)
      score_3fg = (week.games.games_search(9,0,0).count.to_f / week.games_count).round(2)
      score_4fg = (week.games.games_search(12,0,0).count.to_f / week.games_count).round(2)
      score_5fg = (week.games.games_search(15,0,0).count.to_f / week.games_count).round(2)
      score_1rtd_0fg = (week.games.games_search(0,6,0).count.to_f / week.games_count).round(2)
      score_1rtd_1fg = (week.games.games_search(3,6,0).count.to_f / week.games_count).round(2)
      score_1rtd_2fg = (week.games.games_search(6,6,0).count.to_f / week.games_count).round(2)
      score_1rtd_3fg = (week.games.games_search(9,6,0).count.to_f / week.games_count).round(2)
      score_1rtd_4fg = (week.games.games_search(12,6,0).count.to_f / week.games_count).round(2)
      score_1rtd_5fg = (week.games.games_search(15,6,0).count.to_f / week.games_count).round(2)
      score_1rtd_1ptd_0fg = (week.games.games_search(0,6,6).count.to_f / week.games_count).round(2)
      score_1rtd_1ptd_1fg = (week.games.games_search(3,6,6).count.to_f / week.games_count).round(2)
      score_1rtd_1ptd_2fg = (week.games.games_search(6,6,6).count.to_f / week.games_count).round(2)
      score_1rtd_1ptd_3fg = (week.games.games_search(9,6,6).count.to_f / week.games_count).round(2)
      score_1rtd_1ptd_4fg = (week.games.games_search(12,6,6).count.to_f / week.games_count).round(2)
      score_1rtd_1ptd_5fg = (week.games.games_search(15,6,6).count.to_f / week.games_count).round(2)
      score_1ptd_0fg = (week.games.games_search(0,0,6).count.to_f / week.games_count).round(2)
      score_1ptd_1fg = (week.games.games_search(3,0,6).count.to_f / week.games_count).round(2)
      score_1ptd_2fg = (week.games.games_search(6,0,6).count.to_f / week.games_count).round(2)
      score_1ptd_3fg = (week.games.games_search(9,0,6).count.to_f / week.games_count).round(2)
      score_1ptd_4fg = (week.games.games_search(12,0,6).count.to_f / week.games_count).round(2)
      score_1ptd_5fg = (week.games.games_search(15,0,6).count.to_f / week.games_count).round(2)
      score_2ptd_0fg = (week.games.games_search(0,0,12).count.to_f / week.games_count).round(2)
      score_2ptd_1fg = (week.games.games_search(3,0,12).count.to_f / week.games_count).round(2)
      score_2ptd_2fg = (week.games.games_search(6,0,12).count.to_f / week.games_count).round(2)
      score_2ptd_3fg = (week.games.games_search(9,0,12).count.to_f / week.games_count).round(2)
      score_2ptd_4fg = (week.games.games_search(12,0,12).count.to_f / week.games_count).round(2)
      score_2ptd_5fg = (week.games.games_search(15,0,12).count.to_f / week.games_count).round(2)
      score_2rtd_0fg = (week.games.games_search(0,12,0).count.to_f / week.games_count).round(2)
      score_2rtd_1fg = (week.games.games_search(3,12,0).count.to_f / week.games_count).round(2)
      score_2rtd_2fg = (week.games.games_search(6,12,0).count.to_f / week.games_count).round(2)
      score_2rtd_3fg = (week.games.games_search(9,12,0).count.to_f / week.games_count).round(2)
      score_2rtd_4fg = (week.games.games_search(12,12,0).count.to_f / week.games_count).round(2)
      score_2rtd_5fg = (week.games.games_search(15,12,0).count.to_f / week.games_count).round(2)
      
      # Push to CSV
      csv.push("#{week.games_count.to_i},#{week.season_year.to_i},#{week.sequence.to_i},#{week.field_goals},#{week.rushing_touchdowns},#{week.passing_touchdowns},#{zero_score_count},#{score_1fg},#{score_2fg},#{score_3fg},#{score_4fg},#{score_5fg},#{score_1rtd_0fg},#{score_1rtd_1fg},#{score_1rtd_2fg},#{score_1rtd_3fg},#{score_1rtd_4fg},#{score_1rtd_5fg},#{score_1rtd_1ptd_0fg},#{score_1rtd_1ptd_1fg},#{score_1rtd_1ptd_2fg},#{score_1rtd_1ptd_3fg},#{score_1rtd_1ptd_4fg},#{score_1rtd_1ptd_5fg},#{score_1ptd_0fg},#{score_1ptd_1fg},#{score_1ptd_2fg},#{score_1ptd_3fg},#{score_1ptd_4fg},#{score_1ptd_5fg},#{score_2ptd_0fg},#{score_2ptd_1fg},#{score_2ptd_2fg},#{score_2ptd_3fg},#{score_2ptd_4fg},#{score_2ptd_5fg},#{score_2rtd_0fg},#{score_2rtd_1fg},#{score_2rtd_2fg},#{score_2rtd_3fg},#{score_2rtd_4fg},#{score_2rtd_5fg}")
    end
      puts csv.join("\n")
  end
end
