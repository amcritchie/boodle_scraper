namespace :matchups do
  desc "Populate matchups for Week 1, Season 2025 Buffalo Bills"
  task populate: :environment do
    # Each through active teams
    Team.active.each do |team|
        # Generate Week 1 Roster
        team.generate_matchup(1,2024)
    end
  end

  desc "Populate matchups for Seasons 2022-2024"
  task populate2021t2024: :environment do
    # seasons = [2022,2023,2024]
    seasons = [2020,2021,2022]
    # Get collection of weeks
    weeks = Week.where(season_year: seasons).where.not(sportsradar_id: nil).order(sequence: :desc)
    # Each through weeks collection
    weeks.each do |week|
      # Each trough games and populate
      week.sport_radar_week
    end
    # puts summary
    weeks.scoring_summary_puts
  end

  desc "Populate matchups for Season 2024"
  task populate2024: :environment do
    # seasons = [2024]
    seasons = [2023]
    # Get collection of weeks
    weeks = Week.where(season_year: seasons).where.not(sportsradar_id: nil).order(sequence: :desc)
    # Week.where(season_year: 2024, sequence: 2).where.not(sportsradar_id: nil).order(sequence: :asc).limit(1).each do |week|
    weeks.each do |week|
      # Each trough games and populate
      week.sport_radar_week
    end
    # puts summary
    weeks.scoring_summary_puts
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
