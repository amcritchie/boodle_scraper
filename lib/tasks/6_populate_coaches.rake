namespace :coaches do
  desc "Populate coaches with 2025 NFL offensive play callers"
  task populate: :environment do
    puts "Populating coaches with 2025 NFL offensive play callers..."
    
    coaches_data = [
      { team_slug: 'sf', first_name: 'Kyle', last_name: 'Shanahan', position: 'Head Coach', 
        offensive_play_caller_rank: 1, pace_of_play_rank: 3, run_heavy_rank: 4 },
      { team_slug: 'lar', first_name: 'Sean', last_name: 'McVay', position: 'Head Coach', 
        offensive_play_caller_rank: 2, pace_of_play_rank: 7, run_heavy_rank: 27 },
      { team_slug: 'gb', first_name: 'Matt', last_name: 'LaFleur', position: 'Head Coach', 
        offensive_play_caller_rank: 3, pace_of_play_rank: 9, run_heavy_rank: 26 },
      { team_slug: 'min', first_name: 'Kevin', last_name: 'O\'Connell', position: 'Head Coach', 
        offensive_play_caller_rank: 4, pace_of_play_rank: 17, run_heavy_rank: 28 },
      { team_slug: 'kc', first_name: 'Andy', last_name: 'Reid', position: 'Head Coach', 
        offensive_play_caller_rank: 5, pace_of_play_rank: 16, run_heavy_rank: 19 },
      { team_slug: 'chi', first_name: 'Ben', last_name: 'Johnson', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 6, pace_of_play_rank: 4, run_heavy_rank: 10 },
      { team_slug: 'den', first_name: 'Sean', last_name: 'Payton', position: 'Head Coach', 
        offensive_play_caller_rank: 7, pace_of_play_rank: 6, run_heavy_rank: 12 },
      { team_slug: 'mia', first_name: 'Mike', last_name: 'McDaniel', position: 'Head Coach', 
        offensive_play_caller_rank: 8, pace_of_play_rank: 2, run_heavy_rank: 24 },
      { team_slug: 'was', first_name: 'Kliff', last_name: 'Kingsbury', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 9, pace_of_play_rank: 32, run_heavy_rank: 6 },
      { team_slug: 'buf', first_name: 'Joe', last_name: 'Brady', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 10, pace_of_play_rank: 8, run_heavy_rank: 20 },
      { team_slug: 'jax', first_name: 'Liam', last_name: 'Coen', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 11, pace_of_play_rank: 31, run_heavy_rank: 32 },
      { team_slug: 'bal', first_name: 'Todd', last_name: 'Monken', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 12, pace_of_play_rank: 12, run_heavy_rank: 15 },
      { team_slug: 'car', first_name: 'Dave', last_name: 'Canales', position: 'Head Coach', 
        offensive_play_caller_rank: 13, pace_of_play_rank: 29, run_heavy_rank: 23 },
      { team_slug: 'no', first_name: 'Kellen', last_name: 'Moore', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 14, pace_of_play_rank: 5, run_heavy_rank: 30 },
      { team_slug: 'cle', first_name: 'Kevin', last_name: 'Stefanski', position: 'Head Coach', 
        offensive_play_caller_rank: 15, pace_of_play_rank: 10, run_heavy_rank: 22 },
      { team_slug: 'ind', first_name: 'Shane', last_name: 'Steichen', position: 'Head Coach', 
        offensive_play_caller_rank: 16, pace_of_play_rank: 18, run_heavy_rank: 8 },
      { team_slug: 'lv', first_name: 'Chip', last_name: 'Kelly', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 17, pace_of_play_rank: 22, run_heavy_rank: 11 },
      { team_slug: 'ari', first_name: 'Drew', last_name: 'Petzing', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 18, pace_of_play_rank: 19, run_heavy_rank: 13 },
      { team_slug: 'atl', first_name: 'Zac', last_name: 'Robinson', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 19, pace_of_play_rank: 21, run_heavy_rank: 7 },
      { team_slug: 'nyg', first_name: 'Brian', last_name: 'Daboll', position: 'Head Coach', 
        offensive_play_caller_rank: 20, pace_of_play_rank: 27, run_heavy_rank: 29 },
      { team_slug: 'pit', first_name: 'Arthur', last_name: 'Smith', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 21, pace_of_play_rank: 26, run_heavy_rank: 5 },
      { team_slug: 'cin', first_name: 'Zac', last_name: 'Taylor', position: 'Head Coach', 
        offensive_play_caller_rank: 22, pace_of_play_rank: 15, run_heavy_rank: 18 },
      { team_slug: 'ne', first_name: 'Josh', last_name: 'McDaniels', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 23, pace_of_play_rank: 24, run_heavy_rank: 17 },
      { team_slug: 'sea', first_name: 'Klint', last_name: 'Kubiak', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 24, pace_of_play_rank: 23, run_heavy_rank: 15 },
      { team_slug: 'lac', first_name: 'Greg', last_name: 'Roman', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 25, pace_of_play_rank: 25, run_heavy_rank: 3 },
      { team_slug: 'ten', first_name: 'Brian', last_name: 'Callahan', position: 'Head Coach', 
        offensive_play_caller_rank: 26, pace_of_play_rank: 30, run_heavy_rank: 9 },
      { team_slug: 'dal', first_name: 'Brian', last_name: 'Schottenheimer', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 27, pace_of_play_rank: 13, run_heavy_rank: 20 },
      { team_slug: 'det', first_name: 'John', last_name: 'Morton', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 28, pace_of_play_rank: 4, run_heavy_rank: 10 },
      { team_slug: 'nyj', first_name: 'Tanner', last_name: 'Engstrand', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 29, pace_of_play_rank: 28, run_heavy_rank: 21 },
      { team_slug: 'hou', first_name: 'Nick', last_name: 'Caley', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 30, pace_of_play_rank: 14, run_heavy_rank: 16 },
      { team_slug: 'tb', first_name: 'Josh', last_name: 'Grizzard', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 31, pace_of_play_rank: 31, run_heavy_rank: 32 },
      { team_slug: 'phi', first_name: 'Kevin', last_name: 'Patullo', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 32, pace_of_play_rank: 5, run_heavy_rank: 30 }
    ]
    
    # Use the original coaches_data for database operations
    coaches_data.each do |coach_data|
      coach_data[:season] = 2025
      slug = [coach_data[:position], coach_data[:first_name], coach_data[:last_name]].compact.join('-').parameterize
      coach = Coach.find_or_initialize_by(slug: slug)
      
      if coach.new_record?
        coach.assign_attributes(coach_data)
        coach.save!
        puts "Created: #{coach.full_name} (#{coach.team_slug}) - #{coach.season}"
      else
        coach.assign_attributes(coach_data)
        coach.save!
        puts "Updated: #{coach.full_name} (#{coach.team_slug}) - #{coach.season}"
      end

      teams_season = TeamsSeason.find_or_create_by(team_slug: coach.team_slug, season_year: 2025)
      teams_season.offensive_play_caller = coach.slug
      teams_season.save!
    end
    
    puts "\nCoaches population completed!"
    puts "Total: #{Coach.count}"
    
    # Display top 10 offensive play callers
    puts "\nTop 10 Offensive Play Callers (2025):"
    Coach.current_season.by_play_caller_rank.limit(10).each_with_index do |coach, index|
      puts "#{index + 1}. #{coach.full_name} (#{coach.team_slug}) - Rank: #{coach.offensive_play_caller_rank}"
    end
  end

  desc "Populate field goal ranks for 2025 NFL coaches"
  task populate_field_goal_ranks: :environment do
    puts "Populating field goal ranks for 2025 NFL coaches..."
    
    field_goal_ranks = {
      'dal' => 1,     # Brandon Aubrey - DAL (10)
      'lac' => 2,     # Cameron Dicker - LAC (12)
      'det' => 3,     # Jake Bates - DET (8)
      'cin' => 4,     # Evan McPherson - CIN (10)
      'hou' => 5,     # Ka'imi Fairbairn - HOU (6)
      'tb' => 6,      # Chase McLaughlin - TB (9)
      'den' => 7,     # Wil Lutz - DEN (12)
      'buf' => 8,     # Tyler Bass - BUF (7)
      'kc' => 9,      # Harrison Butker - KC (10)
      'pit' => 10,    # Chris Boswell - PIT (5)
      'phi' => 11,    # Jake Elliott - PHI (9)
      'atl' => 12,    # Younghoe Koo - ATL (5)
      'mia' => 13,    # Jason Sanders - MIA (12)
      'was' => 14,    # Matt Gay - WAS (12)
      'lar' => 15,    # Joshua Karty - LAR (8)
      'lv' => 16,     # Daniel Carlson - LV (8)
      'sea' => 17,    # Jason Myers - SEA (8)
      'gb' => 18,     # Brandon McManus - GB (5)
      'min' => 19,    # Will Reichard - MIN (6)
      'jax' => 20,    # Cam Little - JAX (8)
      'chi' => 21,    # Cairo Santos - CHI (5)
      'ari' => 22,    # Chad Ryland - ARI (8)
      'sf' => 23,     # Jake Moody - SF (14)
      'no' => 24,     # Blake Grupe - NO (11)
      'bal' => 25,    # Tyler Loop - BAL (7)
      'nyg' => 26,    # Graham Gano - NYG (14)
      'ne' => 27,     # Andy Borregales - NE (14)
      'car' => 28,    # Ryan Fitzgerald - CAR (14)
      'cle' => 29,    # Dustin Hopkins - CLE (9)
      'nyj' => 30,    # Caden Davis - NYJ (9)
      'ind' => 31,    # Maddux Trujillo - IND (11)
      'ten' => 32     # Joey Slye - TEN (10)
    }
    
    updated_count = 0
    
    field_goal_ranks.each do |team_slug, rank|
      coaches = Coach.where(team_slug: team_slug, season: 2025).where.not(offensive_play_caller_rank: nil)
      
      coaches.each do |coach|
        if coach.field_goal_rank != rank
          coach.update!(field_goal_rank: rank)
          puts "Updated: #{coach.full_name} (#{coach.team_slug}) - Field Goal Rank: #{rank}"
          updated_count += 1
        else
          puts "Already set: #{coach.full_name} (#{coach.team_slug}) - Field Goal Rank: #{rank}"
        end
      end
    end
    
    puts "\nField goal ranks population completed!"
    puts "Total coaches updated: #{updated_count}"
    
    # Display top 10 field goal rank coaches
    puts "\nTop 10 Field Goal Rank Coaches (2025):"
    Coach.current_season.order(:field_goal_rank).limit(10).each_with_index do |coach, index|
      puts "#{index + 1}. #{coach.full_name} (#{coach.team_slug}) - Field Goal Rank: #{coach.field_goal_rank}"
    end
  end
end 