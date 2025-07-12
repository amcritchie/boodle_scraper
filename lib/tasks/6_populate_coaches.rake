namespace :coaches do
  desc "Populate coaches with 2025 NFL offensive play callers"
  task populate: :environment do
    puts "Populating coaches with 2025 NFL offensive play callers..."
    
    coaches_data = [
      { team_slug: 'san-francisco-49ers', first_name: 'Kyle', last_name: 'Shanahan', position: 'Head Coach', 
        offensive_play_caller_rank: 1, pace_of_play_rank: 3, run_heavy_rank: 4 },
      { team_slug: 'los-angeles-rams', first_name: 'Sean', last_name: 'McVay', position: 'Head Coach', 
        offensive_play_caller_rank: 2, pace_of_play_rank: 7, run_heavy_rank: 27 },
      { team_slug: 'green-bay-packers', first_name: 'Matt', last_name: 'LaFleur', position: 'Head Coach', 
        offensive_play_caller_rank: 3, pace_of_play_rank: 9, run_heavy_rank: 26 },
      { team_slug: 'minnesota-vikings', first_name: 'Kevin', last_name: 'O\'Connell', position: 'Head Coach', 
        offensive_play_caller_rank: 4, pace_of_play_rank: 17, run_heavy_rank: 28 },
      { team_slug: 'kansas-city-chiefs', first_name: 'Andy', last_name: 'Reid', position: 'Head Coach', 
        offensive_play_caller_rank: 5, pace_of_play_rank: 16, run_heavy_rank: 19 },
      { team_slug: 'chicago-bears', first_name: 'Ben', last_name: 'Johnson', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 6, pace_of_play_rank: 4, run_heavy_rank: 10 },
      { team_slug: 'denver-broncos', first_name: 'Sean', last_name: 'Payton', position: 'Head Coach', 
        offensive_play_caller_rank: 7, pace_of_play_rank: 6, run_heavy_rank: 12 },
      { team_slug: 'miami-dolphins', first_name: 'Mike', last_name: 'McDaniel', position: 'Head Coach', 
        offensive_play_caller_rank: 8, pace_of_play_rank: 2, run_heavy_rank: 24 },
      { team_slug: 'washington-commanders', first_name: 'Kliff', last_name: 'Kingsbury', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 9, pace_of_play_rank: 32, run_heavy_rank: 6 },
      { team_slug: 'buffalo-bills', first_name: 'Joe', last_name: 'Brady', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 10, pace_of_play_rank: 8, run_heavy_rank: 20 },
      { team_slug: 'jacksonville-jaguars', first_name: 'Liam', last_name: 'Coen', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 11, pace_of_play_rank: 31, run_heavy_rank: 32 },
      { team_slug: 'baltimore-ravens', first_name: 'Todd', last_name: 'Monken', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 12, pace_of_play_rank: 12, run_heavy_rank: 15 },
      { team_slug: 'carolina-panthers', first_name: 'Dave', last_name: 'Canales', position: 'Head Coach', 
        offensive_play_caller_rank: 13, pace_of_play_rank: 29, run_heavy_rank: 23 },
      { team_slug: 'new-orleans-saints', first_name: 'Kellen', last_name: 'Moore', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 14, pace_of_play_rank: 5, run_heavy_rank: 30 },
      { team_slug: 'cleveland-browns', first_name: 'Kevin', last_name: 'Stefanski', position: 'Head Coach', 
        offensive_play_caller_rank: 15, pace_of_play_rank: 10, run_heavy_rank: 22 },
      { team_slug: 'indianapolis-colts', first_name: 'Shane', last_name: 'Steichen', position: 'Head Coach', 
        offensive_play_caller_rank: 16, pace_of_play_rank: 18, run_heavy_rank: 8 },
      { team_slug: 'las-vegas-raiders', first_name: 'Chip', last_name: 'Kelly', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 17, pace_of_play_rank: 22, run_heavy_rank: 11 },
      { team_slug: 'arizona-cardinals', first_name: 'Drew', last_name: 'Petzing', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 18, pace_of_play_rank: 19, run_heavy_rank: 13 },
      { team_slug: 'atlanta-falcons', first_name: 'Zac', last_name: 'Robinson', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 19, pace_of_play_rank: 21, run_heavy_rank: 7 },
      { team_slug: 'new-york-giants', first_name: 'Brian', last_name: 'Daboll', position: 'Head Coach', 
        offensive_play_caller_rank: 20, pace_of_play_rank: 27, run_heavy_rank: 29 },
      { team_slug: 'pittsburgh-steelers', first_name: 'Arthur', last_name: 'Smith', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 21, pace_of_play_rank: 26, run_heavy_rank: 5 },
      { team_slug: 'cincinnati-bengals', first_name: 'Zac', last_name: 'Taylor', position: 'Head Coach', 
        offensive_play_caller_rank: 22, pace_of_play_rank: 15, run_heavy_rank: 18 },
      { team_slug: 'new-england-patriots', first_name: 'Josh', last_name: 'McDaniels', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 23, pace_of_play_rank: 24, run_heavy_rank: 17 },
      { team_slug: 'seattle-seahawks', first_name: 'Klint', last_name: 'Kubiak', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 24, pace_of_play_rank: 23, run_heavy_rank: 15 },
      { team_slug: 'los-angeles-chargers', first_name: 'Greg', last_name: 'Roman', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 25, pace_of_play_rank: 25, run_heavy_rank: 3 },
      { team_slug: 'tennessee-titans', first_name: 'Brian', last_name: 'Callahan', position: 'Head Coach', 
        offensive_play_caller_rank: 26, pace_of_play_rank: 30, run_heavy_rank: 9 },
      { team_slug: 'dallas-cowboys', first_name: 'Brian', last_name: 'Schottenheimer', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 27, pace_of_play_rank: 13, run_heavy_rank: 20 },
      { team_slug: 'detroit-lions', first_name: 'John', last_name: 'Morton', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 28, pace_of_play_rank: 4, run_heavy_rank: 10 },
      { team_slug: 'new-york-jets', first_name: 'Tanner', last_name: 'Engstrand', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 29, pace_of_play_rank: 28, run_heavy_rank: 21 },
      { team_slug: 'houston-texans', first_name: 'Nick', last_name: 'Caley', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 30, pace_of_play_rank: 14, run_heavy_rank: 16 },
      { team_slug: 'tampa-bay-buccaneers', first_name: 'Josh', last_name: 'Grizzard', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 31, pace_of_play_rank: 31, run_heavy_rank: 32 },
      { team_slug: 'philadelphia-eagles', first_name: 'Kevin', last_name: 'Patullo', position: 'Offensive Coordinator', 
        offensive_play_caller_rank: 32, pace_of_play_rank: 5, run_heavy_rank: 30 }
    ]
    
    coaches_created = 0
    coaches_updated = 0
    
    coaches_data.each do |coach_data|
      coach_data[:season] = 2025
      coach = Coach.find_or_initialize_by(team_slug: coach_data[:team_slug], season: 2025)
      
      if coach.new_record?
        coach.assign_attributes(coach_data)
        coach.save!
        coaches_created += 1
        puts "Created: #{coach.full_name} (#{coach.team_slug}) - #{coach.season}"
      else
        coach.assign_attributes(coach_data)
        coach.save!
        coaches_updated += 1
        puts "Updated: #{coach.full_name} (#{coach.team_slug}) - #{coach.season}"
      end
    end
    
    puts "\nCoaches population completed!"
    puts "Created: #{coaches_created}"
    puts "Updated: #{coaches_updated}"
    puts "Total: #{Coach.count}"
    
    # Display top 10 offensive play callers
    puts "\nTop 10 Offensive Play Callers (2025):"
    Coach.current_season.by_play_caller_rank.limit(10).each_with_index do |coach, index|
      puts "#{index + 1}. #{coach.full_name} (#{coach.team_slug}) - Rank: #{coach.offensive_play_caller_rank}"
    end
  end
end 