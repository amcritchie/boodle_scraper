namespace :teams do
  desc "Populate 32 Active Teams (Kaggle)"
  task populate: :environment do
    Team.kaggle_import_teams
  end

  desc "Populate TeamsSeason with CSV starting lineups and coaches"
  task starters2025: :environment do
    # Clean all TeamsSeason records
    TeamsSeason.destroy_all

    puts "Populating TeamsSeason with CSV starting lineups..."
    # Check if CSV file exists
    csv_path = Rails.root.join('lib', 'pff', 'starting-lineups-2025.csv')    
    # Each through starters CSV
    require 'csv'
    CSV.foreach(csv_path, headers: true) do |row|
      team_name = row['Team']
      position = row['Position']
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
        player.update(grades_offense: row['Grade'].to_f)
      else
        player.update(grades_defence: row['Grade'].to_f)
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
          if teams_season.rb1.nil?
            teams_season.update(rb1: player.slug)
          elsif teams_season.rb2.nil?
            teams_season.update(rb2: player.slug)
          end
        when 'WR'
          if teams_season.wr1.nil?
            teams_season.update(wr1: player.slug)
          elsif teams_season.wr2.nil?
            teams_season.update(wr2: player.slug)
          elsif teams_season.wr3.nil?
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
          if teams_season.eg1.nil?
            teams_season.update(eg1: player.slug)
          elsif teams_season.eg2.nil?
            teams_season.update(eg2: player.slug)
          elsif teams_season.dl3.nil?
            teams_season.update(dl3: player.slug)
          end
        when 'DI'
          # Handle multiple defensive interior players
          if teams_season.dl1.nil?
            teams_season.update(dl1: player.slug)
          elsif teams_season.dl2.nil?
            teams_season.update(dl2: player.slug)
          elsif teams_season.dl3.nil?
            teams_season.update(dl3: player.slug)
          end
        when 'LB'
          # Handle multiple linebackers
          if teams_season.lb1.nil?
            teams_season.update(lb1: player.slug)
          elsif teams_season.lb2.nil?
            teams_season.update(lb2: player.slug)
          end
        when 'CB'
          # Handle multiple cornerbacks
          if teams_season.cb1.nil?
            teams_season.update(cb1: player.slug)
          elsif teams_season.cb2.nil?
            teams_season.update(cb2: player.slug)
          elsif teams_season.cb3.nil?
            teams_season.update(cb3: player.slug)
          end
        when 'S'
          # Handle multiple safeties
          if teams_season.s1.nil?
            teams_season.update(s1: player.slug)
          elsif teams_season.s2.nil?
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
      # Fetch current team data from sports radar
      team.fetch_roster_sportradar
      # Generate offense and defense starter predictions based on grade
      offense                 = team.offense_starters_prediction
      defense                 = team.defense_starters_prediction
      # Fetch coaches
      head_coach              = team.coaches.find_by( season: 2025, position: 'Head Coach')
      offensive_coordinator   = team.coaches.find_by(season: 2025, position: 'Offensive Coordinator')
      defensive_coordinator   = team.coaches.find_by(season: 2025, position: 'Defensive Coordinator')
      offensive_play_caller   = team.offensive_play_caller
      # defensive_play_caller   = team.defensive_play_caller
      # Create or update TeamsSeason record
      teams_season = TeamsSeason.find_or_create_by(team_slug: team.slug, season_year: 2025)

      # if teams_season.qb != offense[:quarterback]&.slug
      #   puts "QB: #{teams_season.qb} != #{offense[:quarterback]&.slug}"
      # end

      # if teams_season.te != offense[:tight_end]&.slug
      #   puts "TE: #{teams_season.te} != #{offense[:tight_end]&.slug}"
      # end

      # # Find runningbacks not assigned to rb1 or rb2
      # assigned_rb_slugs = [teams_season.rb1, teams_season.rb2].compact
      # unassigned_rbs = offense[:runningbacks].reject { |rb| assigned_rb_slugs.include?(rb.slug) }
      
      # if unassigned_rbs.any?
      #   puts "Unassigned RBs for #{team.name}: #{unassigned_rbs.map(&:slug).join(', ')}"
      # end

      # # Find wide receivers not assigned to wr1, wr2, or wr3
      # assigned_wr_slugs = [teams_season.wr1, teams_season.wr2, teams_season.wr3].compact
      # unassigned_wrs = offense[:wide_receivers].reject { |wr| assigned_wr_slugs.include?(wr.slug) }
      
      # if unassigned_wrs.any?
      #   puts "Unassigned WRs for #{team.name}: #{unassigned_wrs.map(&:slug).join(', ')}"
      # end

      # # Find offensive linemen not assigned to any oline position
      # assigned_oline_slugs = [teams_season.c, teams_season.lg, teams_season.rg, teams_season.lt, teams_season.rt].compact
      # unassigned_oline = offense[:oline].reject { |ol| assigned_oline_slugs.include?(ol.slug) }
      
      # if unassigned_oline.any?
      #   puts "Unassigned OLine for #{team.name}: #{unassigned_oline.map(&:slug).join(', ')}"
      # end

      # # Find edge rushers not assigned to eg1 or eg2
      # assigned_edge_slugs = [teams_season.eg1, teams_season.eg2, teams_season.dl3].compact
      # unassigned_edges = defense[:edge_rushers].reject { |edge| assigned_edge_slugs.include?(edge.slug) }
      
      # if unassigned_edges.any?
      #   puts "Unassigned Edge Rushers for #{team.name}: #{unassigned_edges.map(&:slug).join(', ')}"
      # end

      # # Find defensive ends not assigned to dl1 or dl2
      # assigned_de_slugs = [teams_season.dl1, teams_season.dl2, teams_season.dl3].compact
      # unassigned_des = defense[:defensive_ends].reject { |de| assigned_de_slugs.include?(de.slug) }
      
      # if unassigned_des.any?
      #   puts "Unassigned Defensive Ends for #{team.name}: #{unassigned_des.map(&:slug).join(', ')}"
      # end
      # # San Francisco 49ers,Defense,Edge,Nick Bosa,91.0

      # # Find linebackers not assigned to lb1 or lb2
      # assigned_lb_slugs = [teams_season.lb1, teams_season.lb2].compact
      # unassigned_lbs = defense[:linebackers].reject { |lb| assigned_lb_slugs.include?(lb.slug) }
      
      # if unassigned_lbs.any?
      #   puts "Unassigned Linebackers for #{team.name}: #{unassigned_lbs.map(&:slug).join(', ')}"
      # end

      # # Find cornerbacks not assigned to cb1, cb2, or cb3
      # assigned_cb_slugs = [teams_season.cb1, teams_season.cb2, teams_season.cb3].compact
      # unassigned_cbs = defense[:cornerbacks].reject { |cb| assigned_cb_slugs.include?(cb.slug) }
      
      # if unassigned_cbs.any?
      #   puts "Unassigned Cornerbacks for #{team.name}: #{unassigned_cbs.map(&:slug).join(', ')}"
      # end

      # # Find safeties not assigned to s1 or s2
      # assigned_s_slugs = [teams_season.s1, teams_season.s2].compact
      # unassigned_safeties = defense[:safeties].reject { |s| assigned_s_slugs.include?(s.slug) }
      
      # if unassigned_safeties.any?
      #   puts "Unassigned Safeties for #{team.name}: #{unassigned_safeties.map(&:slug).join(', ')}"
      # end

      # Update TeamsSeason with current starters and coaches
      teams_season.update(        
        # Coaches
        hc:   head_coach&.slug,
        oc:   offensive_coordinator&.slug,
        dc:   defensive_coordinator&.slug,
        offensive_play_caller: offensive_play_caller&.slug,
        defensive_play_caller: nil
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

      starter_overrides = [
        { team: 'pit', slug: 'quarterback-aaron-rodgers'},
        { team: 'mia', slug: 'quarterback-tua-tagovailoa', left_handed: true},
        { team: 'atl', slug: 'quarterback-michael-penix-jr', left_handed: true}
      ]

      starter_overrides.each do |override|
        team = Team.active.find_by(slug: override[:team])
        player = Player.find_by(slug: override[:slug])
        player.update(left_handed: true) if override[:left_handed]
        # Update TeamsSeason
        teams_season = TeamsSeason.find_or_create_by(team_slug: team.slug, season_year: 2025)
        teams_season.update(qb: player.slug)
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
      # ap player.slug
      # ap position.upcase

      # puts "============="
      
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
        puts "📈 #{row['Player'].ljust(20)} (#{team_name.ljust(10)} #{position.ljust(10)}): #{old_grade.round(1)} → #{new_grade.round(1)} (#{correction.ljust(10)})"
      elsif is_defensive
        old_grade = player.grades_defence
        player.update(grades_defence: new_grade)
        puts "📈 #{row['Player'].ljust(20)} (#{team_name.ljust(10)} #{position.ljust(10)}): #{old_grade.round(1)} → #{new_grade.round(1)} (#{correction.ljust(10)})"
      end
    end
    
    puts "\n🎉 Player grade modifications completed!"
  end
end 