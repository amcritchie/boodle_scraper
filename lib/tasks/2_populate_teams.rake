namespace :teams do
  desc "Populate 32 Active Teams (Kaggle)"
  task populate: :environment do
    Team.kaggle_import_teams
  end

  desc "Populate TeamsSeason with CSV starting lineups and coaches"
  task starters2025: :environment do
    # Clean all TeamsSeason records
    # TeamsSeason.destroy_all

    # Count manually so create or update works
    new_team = nil
    rb_count = 0 # RB1
    wr_count = 0 # WR1
    eg_count = 0 # EDGE1
    dl_count = 0 # DL1
    lb_count = 0 # LB1
    cb_count = 0 # CB1
    s_count = 0 # S1

    puts "Populating TeamsSeason with CSV starting lineups..."
    # Check if CSV file exists
    csv_path = Rails.root.join('lib', 'pff', 'starting-lineups-2025.csv')    
    # Each through starters CSV    
    require 'csv'
    CSV.foreach(csv_path, headers: true) do |row|
      team_name = row['Team']
      # team_slug = team_name
      position = row['Position']

      # Count manually so create or update works
      if new_team != team_name
        rb_count = 0 # RB1
        wr_count = 0 # WR1
        eg_count = 0 # EDGE1
        dl_count = 0 # DL1
        lb_count = 0 # LB1
        cb_count = 0 # CB1
        s_count = 0 # S1
      end
      new_team = team_name

      # Skip if missing essential data
      next if team_name.blank?
      # Find team by name
      team = Team.active.find_by(name: team_name)
      unless team
        puts "⚠️  Team not found: #{team_name}"
        next
      end

      # Find or create player
      player = Player.pff_starters_fetch(row)
      unit = row['Unit']
      # Set grade if new player - Travis Hunter
      if unit.downcase == 'offense'
        player.update(
          correction: nil,
          grades_offense: row['Grade'].to_f
        )
      else
        player.update(
          correction: nil,
          grades_defence: row['Grade'].to_f
        )
      end
      
      # Find or create TeamsSeason record
      teams_season = TeamsSeason.find_or_create_by(team_slug: team.slug, season_year: 2025)
      
      # Update TeamsSeason based on position
      case unit.downcase
      when 'offense'
        case position.upcase
        when 'QB'
          teams_season.update(qb: player.slug)
        when 'RB'
          # Handle multiple RBs - assign to rb1 or rb2
          if rb_count == 0
            rb_count += 1
            teams_season.update(rb1: player.slug)
          elsif rb_count == 1
            rb_count += 1
            teams_season.update(rb2: player.slug)
          end
        when 'WR'
          if wr_count == 0
            wr_count += 1
            teams_season.update(wr1: player.slug)
          elsif wr_count == 1
            wr_count += 1
            teams_season.update(wr2: player.slug)
          elsif wr_count == 2
            wr_count += 1
            teams_season.update(wr3: player.slug)
          end
        when 'TE'
          teams_season.update(te: player.slug)
        when 'C'
          teams_season.update(c: player.slug)
        when 'LG'
          teams_season.update(lg: player.slug)
        when 'RG'
          teams_season.update(rg: player.slug)
        when 'LT'
          teams_season.update(lt: player.slug)
        when 'RT'
          teams_season.update(rt: player.slug)
        end
        
      when 'defense'
        case position.upcase
        when 'EDGE'
          # Handle multiple EDGE rushers
          if eg_count == 0
            eg_count += 1
            teams_season.update(eg1: player.slug)
          elsif eg_count == 1
            eg_count += 1
            teams_season.update(eg2: player.slug)
          elsif teams_season.dl3.nil?
            teams_season.update(dl3: player.slug)
          end
        when 'DI'
          # Handle multiple defensive interior players
          if dl_count == 0
            dl_count += 1
            teams_season.update(dl1: player.slug)
          elsif dl_count == 1
            dl_count += 1
            teams_season.update(dl2: player.slug)
          elsif dl_count == 2
            dl_count += 1
            teams_season.update(dl3: player.slug)
          end
        when 'LB'
          # Handle multiple linebackers
          if lb_count == 0
            lb_count += 1
            teams_season.update(lb1: player.slug)
          elsif lb_count == 1
            lb_count += 1
            teams_season.update(lb2: player.slug)
          end
        when 'CB'
          # Handle multiple cornerbacks
          if cb_count == 0
            cb_count += 1
            teams_season.update(cb1: player.slug)
          elsif cb_count == 1
            cb_count += 1
            teams_season.update(cb2: player.slug)
          elsif cb_count == 2
            cb_count += 1
            teams_season.update(cb3: player.slug)
          end
        when 'S'
          # Handle multiple safeties
          if s_count == 0
            s_count += 1
            teams_season.update(s1: player.slug)
          elsif s_count == 1
            s_count += 1
            teams_season.update(s2: player.slug)
          end
        else
          puts "  ⚠️  Unknown defense position: #{position}"
        end
      end
    end
    
    puts "\n🎉 CSV roster population completed!"
    puts "📊 Total TeamsSeason records: #{TeamsSeason.count}"
    # Total playes output
    puts "============="
    puts "Players: #{Player.count}"
    puts "============="
  end

  desc "Populate Current Roster for Active Teams (Sport Radar)"
  task rosterr: :environment do
    Team.active.reverse.each do |team| 
      team.fetch_roster_sportradar
    end
  end

  desc "Populate TeamsSeason with current starters and coaches"
  task roster2025: :environment do
    puts "Populating TeamsSeason with current starters and coaches..."
    Team.active.each do |team|

      puts "="*50
      puts "team: #{team.name} #{team.emoji} - Team roster"
      puts "="*50
      # Fetch current team data from sports radar
      team.fetch_roster_sportradar
      # Generate offense and defense starter predictions based on grade
      offense                 = team.offense_starters_prediction
      defense                 = team.defense_starters_prediction
      # Fetch coaches
      head_coach              = team.coaches.find_by( season: 2025, position: 'Head Coach')
      offensive_coordinator   = team.coaches.find_by(season: 2025, position: 'Offensive Coordinator')
      defensive_coordinator   = team.coaches.find_by(season: 2025, position: 'Defensive Coordinator')
      offensive_play_caller   = team.offensive_play_caller_coach
      defensive_play_caller   = team.defensive_play_caller_coach
      # Create or update TeamsSeason record
      teams_season = TeamsSeason.find_or_create_by(team_slug: team.slug, season_year: 2025)

      # Update TeamsSeason with current starters and coaches
      teams_season.update(        
        # Coaches
        hc:   head_coach&.slug,
        oc:   offensive_coordinator&.slug,
        dc:   defensive_coordinator&.slug,
        offensive_play_caller: offensive_play_caller&.slug,
        defensive_play_caller: defensive_play_caller&.slug
      )
      play_caller_emoji = "🧠" if offensive_play_caller.position == "Offensive Coordinator"
      play_caller_emoji = "🏈" if offensive_play_caller.position == "Head Coach"
      # puts "2025 Roster added #{team.name.rjust(22)} #{team.emoji} | Players: #{team.players.length.to_s.rjust(4)} | QB: #{team.starting_qb.player.ljust(40)}"
      puts "TeamsSeason updated for #{team.name.rjust(22)} #{team.emoji} | QB: #{offense[:quarterback]&.player&.ljust(20)} | Play caller: #{offensive_play_caller.full_name&.ljust(20)} #{play_caller_emoji}"
    end
    puts "\nTeamsSeason population completed!"
    puts "Total TeamsSeason records: #{TeamsSeason.count}"
    # Total playes output
    puts "============="
    puts "Players: #{Player.count}"
    puts "============="
  end

  desc "Populate TeamsSeason with current starters and coaches"
  task startersOveride2025: :environment do

      # Starter overrides
      starter_overrides = [
        { team: 'pit', slug: 'quarterback-aaron-rodgers'},
        { team: 'mia', slug: 'quarterback-tua-tagovailoa', left_handed: true},
        { team: 'atl', slug: 'quarterback-michael-penix', left_handed: true}
      ]

      starter_overrides.each do |override|
        team = Team.active.find_by(slug: override[:team])
        player = Player.find_by(slug: override[:slug])
        player.update(left_handed: true) if override[:left_handed]
        # Update TeamsSeason
        teams_season = TeamsSeason.find_or_create_by(team_slug: team.slug, season_year: 2025)
        teams_season.update(qb: player.slug)
      end

      # Slug overrides
      slug_overrides = [
        # { team: 'atl', slug: 'dline-arnold-ebiketie', original_slug: 'linebacker-arnold-ebiketie'},
        # { team: 'mia', slug: 'dline-jaelan-phillips', original_slug: 'linebacker-jaelan-phillips'},
        # { team: 'mia', slug: 'dline-bradley-chubb', original_slug: 'linebacker-bradley-chubb'},
        # { team: 'nyg', slug: 'dline-kayvon-thibodeaux', original_slug: 'linebacker-kayvon-thibodeaux'},
        # { team: 'nyg', slug: 'dline-abdul-carter', original_slug: 'linebacker-abdul-carter'},
        # { team: 'nyg', slug: 'dline-brian-burns', original_slug: 'linebacker-brian-burns'},
        # { team: 'sea', slug: 'dline-uchenna-nwosu', original_slug: 'linebacker-uchenna-nwosu'},
        # { team: 'sea', slug: 'dline-boye-mafe', original_slug: 'linebacker-boye-mafe'},
        # { team: 'pit', slug: 'dline-tj-watt', original_slug: 'linebacker-tj-watt'},
        # { team: 'pit', slug: 'dline-alex-highsmith', original_slug: 'linebacker-alex-highsmith'},
        # { team: 'pit', slug: 'dline-zaven-collins', original_slug: 'linebacker-zaven-collins'},
        # { team: 'pit', slug: 'dline-josh-sweat', original_slug: 'linebacker-josh-sweat'},
        # { team: 'pit', slug: 'dline-baron-browning', original_slug: 'linebacker-baron-browning'},
        # { team: 'car', slug: 'dline-dj-wonnum', original_slug: 'linebacker-dj-wonnum'}
      ]

      slug_overrides.each do |override|
        team = Team.active.find_by(slug: override[:team])
        player = Player.find_by(slug: override[:original_slug])
        player.update(slug: override[:slug]) if player
      end
  end

  desc "Modify player grades based on rookie-grade-modifications.csv"
  task modifyGrades2025: :environment do
    puts "Modifying player grades based on rookie-grade-modifications.csv..."
    
    csv_path = Rails.root.join('lib', 'pff', 'rookie-grade-modifications.csv')
    require 'csv'
    
    CSV.foreach(csv_path, headers: true) do |row|
      team_name = row['Team']
      position = row['Position']
      grade = row['Grade'].to_f
      correction = row['Correction']
      
      # Skip if missing essential data
      next if team_name.blank? || correction.blank?
      
      # Find team by name
      team = Team.active.find_by(name: team_name)
      unless team
        puts "⚠️  Team not found: #{team_name}"
        next
      end

      # Find or create player using pff_starters_fetch (same as starters2025)
      player = Player.pff_starters_fetch(row)
      
      # Determine if this is an offensive or defensive position
      offensive_positions = ['QB', 'RB', 'WR', 'TE', 'C', 'LG', 'RG', 'LT', 'RT']
      defensive_positions = ['CB', 'S', 'LB', 'EDGE', 'DI']
      
      is_offensive = offensive_positions.include?(position.upcase)
      is_defensive = defensive_positions.include?(position.upcase)
      
      unless is_offensive || is_defensive
        # player.destroy
        puts "⚠️  Unknown position: #{position} for #{row['Player']}"
        next
      end

      unless player.correction.blank?
        puts "⚠️  Player already has a correction: #{player.correction}"
        next
      end

      player.update(correction: correction)
      
      # Calculate new grade based on correction type
      new_grade = case correction
      when 'NFL2023'
        # Average between 2023 grade and 60
        (grade + 60) / 2.0
      when 'College2024'
        if position.upcase == 'QB'
          # For QBs, average with 50
          (grade + 50) / 2.0
        else
          # For others, average with 60
          (grade + 60) / 2.0
        end
      when 'College2023'
        if position.upcase == 'QB'
          # For QBs, average with 55
          (grade + 55) / 2.0
        else
          # For others, average with 60
          (grade + 60) / 2.0
        end
      else
        puts "⚠️  Unknown correction type: #{correction} for #{row['Player']}"
        next
      end
      
  
      # Update the appropriate grade field
      if is_offensive
        old_grade = player.grades_offense
        player.update(grades_offense: new_grade)
        puts "📈 #{row['Player'].ljust(20)} (#{team_name.ljust(10)} #{position.ljust(10)}): #{old_grade} → #{new_grade.round(1)} (#{correction.ljust(10)})"
      elsif is_defensive
        old_grade = player.grades_defence
        player.update(grades_defence: new_grade)
        puts "📈 #{row['Player'].ljust(20)} (#{team_name.ljust(10)} #{position.ljust(10)}): #{old_grade.round(1)} → #{new_grade.round(1)} (#{correction.ljust(10)})"
      end
    end
    
    puts "\n🎉 Player grade modifications completed!"
  end
end 