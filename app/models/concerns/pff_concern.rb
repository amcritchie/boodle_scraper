module PffConcern
  extend ActiveSupport::Concern

  class_methods do
    def extract_last_name(full_name)
      suffixes = %w[jr. sr. ii iii iv v]
      parts = full_name.strip.split
    
      return '' if parts.empty?
    
      # Check for and remove suffix if present
      suffix = ''
      if suffixes.include?(parts.last.downcase)
        suffix = parts.pop
      end
    
      last_name = parts.last || ''
      [last_name, suffix].reject(&:empty?).join(' ')
    end

    def pff_player(player_name, position)
      # Fetch important columns
      # slug_pff        = attrs["player_id"]
      # player_name     = attrs["player"]
      # team_name       = attrs["team_name"]
      # position        = Player.pff_position(attrs["position"]) rescue "unknown"
      position_class  = Player.position_class(position) rescue "unknown"
      last_name = extract_last_name(player_name)

      # team            = Team.pff_team(team_name) rescue "unknown"
      # Create player slug
      slug_player = "#{position_class}-#{player_name}".downcase.gsub(' ', '-').gsub('.', '')
      # Find or create player
      player = Player.find_or_create_by(slug: slug_player) 
      player.last_name = last_name
      player.save!
      player
    end

    def pff_passer_import(csv_path)
      CSV.foreach(csv_path, headers: true) do |row|
        # attrs = row.to_h.slice(*Player.column_names)
        attrs = row.to_h
        # Fetch important columns
        slug_pff        = attrs["player_id"]
        player_name     = attrs["player"]
        team_name       = attrs["team_name"]
        position        = Player.pff_position(attrs["position"]) rescue "unknown"
        team            = Team.pff_team(team_name) rescue "unknown"
        # Find or create player
        player = pff_player(player_name,position)
        # Update player
        player.slug_pff = slug_pff
        player.player   = player_name
        # Passer Details
        player.player_game_count          = attrs["player_game_count"]
        player.passing_yards_per_attempt  = attrs["ypa"].to_f.round(2)
        player.passing_attempts           = attrs["attempts"]
        player.passing_touchdowns         = attrs["touchdowns"]
        player.passing_yards              = attrs["yards"]
        player.franchise_id               = attrs["franchise_id"]
        player.grades_offense             = attrs["grades_offense"].to_f
        player.grades_pass                = attrs["grades_pass"].to_f
        player.grades_run                 = attrs["grades_run"].to_f
        player.penalties                  = attrs["penalties"]
        player.scrambles                  = attrs["scrambles"]
        player.accuracy_percent           = attrs["accuracy_percent"]
        player.aimed_passes               = attrs["aimed_passes"]
        player.avg_depth_of_target        = attrs["avg_depth_of_target"]
        player.avg_time_to_throw          = attrs["avg_time_to_throw"].to_f
        player.turnover_worthy_plays      = attrs["turnover_worthy_plays"]
        player.turnover_worthy_rate       = attrs["twp_rate"].to_f
        player.batted_passes              = attrs["bats"]
        player.big_time_throws            = attrs["big_time_throws"]
        player.btt_rate                   = attrs["btt_rate"].to_f
        player.completion_percent         = attrs["completion_percent"].to_f
        player.completions                = attrs["completions"]
        player.declined_penalties         = attrs["declined_penalties"]
        player.def_gen_pressures          = attrs["def_gen_pressures"]
        player.drop_rate                  = attrs["drop_rate"].to_f
        player.dropbacks                  = attrs["dropbacks"]
        player.drops                      = attrs["drops"].to_i
        player.first_downs                = attrs["first_downs"]
        player.grades_hands_fumble        = attrs["grades_hands_fumble"]
        player.hit_as_threw               = attrs["hit_as_threw"]
        player.interceptions              = attrs["interceptions"]
        player.passing_snaps              = attrs["passing_snaps"]
        player.penalties                  = attrs["penalties"].to_i
        player.pressure_to_sack_rate      = attrs["pressure_to_sack_rate"].to_f
        player.qb_rating                  = attrs["qb_rating"].to_f
        player.sack_percent               = attrs["sack_percent"].to_f
        player.sacks                      = attrs["sacks"]
        player.scrambles                  = attrs["scrambles"]
        player.spikes_thrown              = attrs["spikes"]
        player.thrown_aways               = attrs["thrown_aways"]
        player.team_slug                  = team.slug
        player.position                   = position
        player.save!

        puts "="*80
        ap attrs
        puts "-"*80
        ap player
        puts "-"*80
        # Puts details
        puts "#{player.position.rjust(15)} | #{player.player.rjust(25)} (#{player.jersey.to_s.rjust(2)}) | Grade: #{player.grades_offense.to_s.rjust(6)} /#{player.grades_pass.to_s.rjust(6)} 🏈 | #{player.team.description.ljust(30)}"
      end
    end

    def pff_rusher_import(csv_path)
      CSV.foreach(csv_path, headers: true) do |row|
        # Get row
        attrs = row.to_h
        # Fetch important columns
        slug_pff = attrs["player_id"]
        player_name = attrs["player"]
        team_name = attrs["team_name"]
        position = Player.pff_position(attrs["position"]) rescue "unknown"
        team = Team.pff_team(team_name) rescue "unknown"
        # Find or create player
        player = pff_player(player_name,position)
        # Update player
        player.slug_pff = slug_pff
        player.player   = player_name
        # Passer Details
        player.player_game_count                  = attrs["player_game_count"]
        player.rushing_attempts                   = attrs["attempts"]
        player.avoided_tackles                    = attrs["avoided_tackles"]
        player.breakaway_attempts                 = attrs["breakaway_attempts"]
        player.breakaway_percent                  = attrs["breakaway_percent"].to_f
        player.breakaway_yards                    = attrs["breakaway_yards"]
        player.declined_penalties                 = attrs["declined_penalties"]
        player.designed_yards                     = attrs["designed_yards"]
        player.drops                              = attrs["drops"].to_i
        player.elusive_recv_missed_tackles_forced = attrs["elu_recv_mtf"].to_i
        player.elusive_rush_missed_tackles_forced = attrs["elu_rush_mtf"].to_i
        player.elu_yco                            = attrs["elu_yco"].to_i
        player.elusive_rating                     = attrs["elusive_rating"].to_f
        player.explosive                          = attrs["explosive"].to_i
        player.first_downs                        = attrs["first_downs"]
        player.franchise_id                       = attrs["franchise_id"]
        player.fumbles                            = attrs["fumbles"].to_i
        player.gap_attempts                       = attrs["gap_attempts"].to_i
        player.grades_hands_fumble                = attrs["grades_hands_fumble"].to_f
        player.grades_offense                     = attrs["grades_offense"].to_f
        player.grades_offense_penalty             = attrs["grades_offense_penalty"].to_f
        player.grades_pass                       = attrs["grades_pass"].to_f
        player.grades_run                        = attrs["grades_run"].to_f
        player.grades_pass_block                 = attrs["grades_pass_block"].to_f
        player.grades_run_block                  = attrs["grades_run_block"].to_f
        player.longest                           = attrs["longest"].to_i
        player.rec_yards                         = attrs["rec_yards"].to_i
        player.receptions                        = attrs["receptions"].to_i
        player.routes                            = attrs["routes"].to_i
        player.run_plays                         = attrs["run_plays"].to_i
        player.scramble_yards                    = attrs["scramble_yards"].to_i
        player.scrambles                         = attrs["scrambles"].to_i
        player.targets                           = attrs["targets"].to_i
        player.total_touches                     = attrs["total_touches"].to_i
        player.rushing_touchdowns                = attrs["touchdowns"].to_i
        player.rushing_yards                     = attrs["yards"]
        player.yards_after_contact               = attrs["yards_after_contact"]
        player.yards_after_contact_attempt       = attrs["yco_attempt"]
        player.rushing_yards_per_attempt         = attrs["ypa"]
        player.yards_per_route_run               = attrs["yprr"]
        player.zone_attempts                     = attrs["zone_attempts"].to_i
        player.team_slug                         = team.slug
        player.position                          = position
        player.save!
        # Puts details
        puts "#{player.position.rjust(15)} | #{player.player.rjust(25)} (#{player.jersey.to_s.rjust(2)}) | Grade: #{player.grades_offense.to_s.rjust(6)} /#{player.grades_run.to_s.rjust(6)} 👟 | #{player.team.description.ljust(30)}"
      end
    end

    def pff_receiver_import(csv_path)
      CSV.foreach(csv_path, headers: true) do |row|
        # Get row
        attrs = row.to_h
        # Fetch important columns
        slug_pff = attrs["player_id"]
        player_name = attrs["player"]
        team_name = attrs["team_name"]
        position = Player.pff_position(attrs["position"]) rescue "unknown"
        team = Team.pff_team(team_name) rescue "unknown"
        # Find or create player
        player = pff_player(player_name,position)
        # Update player
        player.slug_pff = slug_pff
        player.player   = player_name
        # Passer Details
        player.player_game_count                = attrs["player_game_count"]
        player.avg_depth_of_target              = attrs["avg_depth_of_target"]
        player.avoided_tackles                  = attrs["avoided_tackles"]
        player.caught_percent                   = attrs["caught_percent"]
        player.contested_catch_rate             = attrs["contested_catch_rate"]
        player.contested_receptions             = attrs["contested_receptions"]
        player.contested_targets                = attrs["contested_targets"]
        player.declined_penalties               = attrs["declined_penalties"]
        player.drops                            = attrs["drops"].to_i
        player.first_downs                      = attrs["first_downs"]
        player.franchise_id                     = attrs["franchise_id"]
        player.fumbles                          = attrs["fumbles"].to_i
        player.grades_hands_drop                = attrs["grades_hands_drop"].to_i
        player.grades_hands_fumble              = attrs["grades_hands_fumble"].to_i
        player.grades_offense                   = attrs["grades_offense"].to_f
        player.grades_pass_block                = attrs["grades_pass_block"].to_f
        player.grades_pass_route                = attrs["grades_pass_route"].to_f
        player.inline_rate                      = attrs["inline_rate"].to_f
        player.inline_snaps                     = attrs["inline_snaps"].to_i
        player.interceptions                    = attrs["interceptions"].to_i
        player.longest                          = attrs["longest"].to_i
        player.pass_block_rate                  = attrs["pass_block_rate"].to_i
        player.pass_blocks                      = attrs["pass_blocks"].to_i
        player.pass_plays                       = attrs["pass_plays"].to_i
        player.penalties                        = attrs["penalties"].to_i
        player.receptions                       = attrs["receptions"].to_i
        player.route_rate                       = attrs["route_rate"].to_i
        player.routes                           = attrs["routes"].to_i
        player.slot_rate                        = attrs["slot_rate"].to_i
        player.slot_snaps                       = attrs["slot_snaps"].to_i
        player.targeted_qb_rating               = attrs["targeted_qb_rating"].to_i
        player.longest                          = attrs["longest"].to_i
        player.receiving_touchdowns             = attrs["touchdowns"].to_i
        player.receiving_yards                  = attrs["yards"]
        player.wide_rate                        = attrs["wide_rate"]
        player.wide_snaps                       = attrs["wide_snaps"].to_i
        player.yards_after_catch                = attrs["yards_after_catch"]
        player.yards_after_catch_per_reception  = attrs["yards_after_catch_per_reception"]
        player.receiving_yards                  = attrs["yards_per_reception"]
        player.yards_after_contact              = attrs["yards_after_contact"]
        player.yards_after_contact_attempt      = attrs["yco_attempt"]
        player.rushing_yards_per_attempt        = attrs["ypa"]
        player.yards_per_route_run              = attrs["yprr"]
        player.zone_attempts                    = attrs["zone_attempts"]
        player.team_slug                        = team.slug
        player.position                         = position
        player.save!
        # Puts details
        puts "#{player.position.rjust(15)} | #{player.player.rjust(25)} (#{player.jersey.to_s.rjust(2)}) | Grade: #{player.grades_offense.to_s.rjust(6)} /#{player.grades_pass_route.to_s.rjust(6)} 🙌 | #{player.team.description.ljust(30)}"
      end
    end
    
    def pff_blocker_import(csv_path)
      CSV.foreach(csv_path, headers: true) do |row|
        # Get row
        attrs = row.to_h
        # Fetch important columns
        slug_pff = attrs["player_id"]
        player_name = attrs["player"]
        team_name = attrs["team_name"]
        position = Player.pff_position(attrs["position"]) rescue "unknown"
        team = Team.pff_team(team_name) rescue "unknown"
        # Find or create player
        player = pff_player(player_name,position)
        # Update player
        player.slug_pff = slug_pff
        player.player   = player_name
        # Offensive Line Details - only using fields that exist in schema
        player.player_game_count                = attrs["player_game_count"]
        player.declined_penalties               = attrs["declined_penalties"].to_i
        player.franchise_id                     = attrs["franchise_id"]
        player.grades_offense                   = attrs["grades_offense"].to_f
        player.grades_pass_block                = attrs["grades_pass_block"].to_f
        player.grades_run_block                 = attrs["grades_run_block"].to_f
        player.penalties                        = attrs["penalties"].to_i
        player.snaps_on_offense                 = attrs["snap_counts_offense"].to_i
        player.snaps_pass_block                 = attrs["snap_counts_pass_block"].to_i
        player.snaps_run_block                  = attrs["snap_counts_run_block"].to_i
        player.team_slug                        = team.slug
        player.position                         = position
        player.save!
        # Puts details
        puts "#{player.position.rjust(15)} | #{player.player.rjust(25)} (#{player.jersey.to_s.rjust(2)}) | Grade: #{player.grades_offense.to_s.rjust(6)} /#{player.grades_pass_block.to_s.rjust(6)} 🛡️ | #{player.team.description.ljust(30)}"
      end
    end

    def pff_defense_import(csv_path)
      CSV.foreach(csv_path, headers: true) do |row|
        # Get row
        attrs = row.to_h
        # Fetch important columns
        slug_pff = attrs["player_id"]
        player_name = attrs["player"]
        team_name = attrs["team_name"]
        position = Player.pff_position(attrs["position"]) rescue "unknown"
        team = Team.pff_team(team_name) rescue "unknown"
        # Find or create player
        player = pff_player(player_name,position)
        # Update player
        player.slug_pff = slug_pff
        player.player   = player_name
        # Defense Details - only using fields that exist in schema
        player.player_game_count                = attrs["player_game_count"]
        player.declined_penalties               = attrs["declined_penalties"].to_i
        player.franchise_id                     = attrs["franchise_id"]
        player.defence_grade                    = attrs["grades_defense"].to_f
        player.rush_defense_grade               = attrs["grades_run_defense"].to_f
        player.pass_rush_grade                  = attrs["grades_pass_rush_defense"].to_f
        player.coverage_grade                   = attrs["grades_coverage_defense"].to_f
        # player.tackles                          = attrs["tackles"].to_i
        player.sacks                            = attrs["sacks"].to_i
        player.interceptions                    = attrs["interceptions"].to_i
        player.fumbles                          = attrs["fumbles"].to_i
        player.penalties                        = attrs["penalties"].to_i
        player.snaps_on_defence                 = attrs["snap_counts_defense"].to_i
        player.snaps_rush_defense               = attrs["snap_counts_run_defense"].to_i
        player.snaps_pass_rush                  = attrs["snap_counts_pass_rush"].to_i
        player.snaps_coverage                   = attrs["snap_counts_coverage"].to_i
        player.team_slug                        = team.slug
        player.position                         = position
        player.save!
        # Puts details
        puts "#{player.position.rjust(15)} | #{player.player.rjust(25)} (#{player.jersey.to_s.rjust(2)}) | Grade: #{player.defence_grade.to_s.rjust(6)} /#{player.coverage_grade.to_s.rjust(6)} 🏈 | #{player.team.description.ljust(30)}"
      end
    end
  end

  def pff_player_import(pff_row, position)
    player_name = pff_row['Player']
    first_name = player_name.split.first
    last_name = player_name.split.last
    # Validate if last name includes
    if last_name.include?("II") || last_name.include?("Jr.")
      last_name = player_name.split.last(2).first rescue "invalid-last-name"
    end
    college = pff_row['College'].downcase.gsub(' ', '-') rescue 'undrafted'
    draft_year = pff_row['DraftYear'].to_i rescue 2099
    # Find or create player
    player = self.class.pff_player(player_name, position)
    # Populate player
    # player = Player.find_or_create_by(slug: player_slug) do |player|
      player.position     = position
      player.rank         = pff_row['Rank']
      player.player       = player_name
      player.first_name   = first_name
      player.last_name    = last_name
      player.team_slug    = self.slug
      player.jersey       = pff_row['Jersey']
      # Offence
      player.offense_grade    = pff_row['Overall']
      player.passing_grade    = pff_row['Passing']
      player.rushing_grade    = pff_row['Rushing']
      player.receiving_grade  = pff_row['Receiving']
      player.run_block_grade  = pff_row['RunBlock']
      player.pass_block_grade = pff_row['PassBlock']
      player.snaps_on_offense = pff_row['Snaps']
      player.snaps_passing    = pff_row['Passes']
      player.snaps_rushing    = pff_row['Rushes']
      player.snaps_recieving  = pff_row['Receptions']
      player.snaps_run_block  = pff_row['RunBlocks']
      player.snaps_pass_block = pff_row['PassBlocks']
      # Defense
      player.defence_grade      = pff_row['Overall']
      player.rush_defense_grade = pff_row['RushDefense']
      player.pass_rush_grade    = pff_row['PassRush']
      player.coverage_grade     = pff_row['Coverage']
      player.snaps_on_defence   = pff_row['Snaps']
      player.snaps_rush_defense = pff_row['RunSnaps']
      player.snaps_pass_rush    = pff_row['PassRushSnaps']
      player.snaps_coverage     = pff_row['CoverageSnaps']

      # player.dropback_grade = pff_row['Dropback_Grade']
      # player.pocket_grade   = pff_row['Pocket_Grade']
      # # RB, WR, TE, C, G, T
      # player.pass_block_grade   = pff_row['Pass_Block_Grade']
      # player.run_block_grade    = pff_row['Run_Block_Grade']
      # player.receiving_grade    = pff_row['Receiving_Grade']
      # player.rushing_grade      = (pff_row['Rush_Grade'] || pff_row['Rushing_Grade'])
      # player.route_grade        = pff_row['Route_Grade']
      # player.yac_grade          = pff_row['YAC_Grade']
      # # Defense
      # player.coverage_grade     = pff_row['Coverage_Grade']
      # player.run_defense_grade  = pff_row['Run_Defense_Grade']
      # player.tackling_grade     = pff_row['Tackling_Grade']
      # player.pass_rush_grade    = pff_row['Pass_Rush_Grade']
      # player.screen_block_grade = pff_row['Screen_Block_Grade']
      # player.intermediate_yards = pff_row['Intermediate_Yards']
      # player.deep_yards         = pff_row['Deep_Yards']
      # player.screen_yards       = pff_row['Screen_Yards']
      # player.total_yards        = pff_row['Total_Yards']
      # player.rush_yards         = pff_row['Rush_Yards']
      # player.receiving_yards    = pff_row['Receiving_Yards']
      # player.missed_tackles_forced = pff_row['Missed_Tackles_Forced']
      # # Offense
      # player.td               = pff_row['TD']
      # player.first_downs      = pff_row['1st_Downs']
      # player.snaps            = pff_row['Snaps']
      # player.run_snaps        = pff_row['Run_Snaps']
      # player.pass_rush_snaps  = pff_row['Pass_Rush_Snaps']
      # player.coverage_snaps   = pff_row['Coverage_Snaps']
      # player.passing_snaps    = pff_row['Passing_Snaps']
      # player.routes           = pff_row['Routes']
      # player.qb_hits          = pff_row['QB_Hits']
      # player.run_block_snaps  = pff_row['Run_Block_Snaps']
      # player.pass_block_snaps = pff_row['Pass_Block_Snaps']
      # # player.total_snaps      = pff_row['Total_Snaps']
      # # Snaps
      # player.total_snaps = pff_row['Total_Snaps']
      # player.pass_snaps = pff_row['Pass_Snaps']
      # player.rush_snaps = pff_row['Rush_Snaps']
      # player.rpo_snaps = pff_row['RPO_Snaps']
      # player.dropback_snaps = pff_row['Dropback_Snaps']
      # player.pocket_snaps = pff_row['Pocket_Snaps']

      # Player Attributes
      player.age = pff_row['Age']
      player.hand = pff_row['Hand']
      player.height = pff_row['Height']
      player.weight = pff_row['Weight']
      player.speed = pff_row['Speed']
      player.college = college
      player.draft_year = draft_year
      player.draft_round = pff_row['DraftRound']
      player.draft_pick = pff_row['DraftPick']
      player.save!

  # Puts description
  puts "#{player.position.rjust(15)} | #{player.player.rjust(25)} (#{player.jersey.to_s.rjust(2)}) | Grade: #{player.offense_grade.to_s.rjust(6)} /#{player.defence_grade.to_s.rjust(6)} | #{player.team.description.ljust(30)}"

  unless player.errors.empty?
    puts "Errors ---------"
    ap player.errors.inspect
  end
end
end 