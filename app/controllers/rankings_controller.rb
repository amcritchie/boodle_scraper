class RankingsController < ApplicationController
  def offensive_line
    @year = params[:year]&.to_i || 2025
    @week = params[:week]&.to_i || 1
    
    # Use the new Ranking model for offensive line rankings
    # ranking_slug = "#{@year}_week_#{@week}_olinemen_rank"
    ranking_slug = "olinemen_rank"
    
    # Get rankings from the Ranking model
    # @rankings = Ranking.find_rankings(ranking_slug)
    @rankings = Ranking.where(ranking_slug: ranking_slug)
    @rankings = Ranking.where(ranking_slug: "olinemen_rank")
    
    # If no rankings exist, fall back to the old method
    if @rankings.empty?
      puts "No rankings found for #{ranking_slug}, falling back to live calculation..."
      fallback_to_live_calculation
    else
      # Apply team filter if present
      if params[:team].present?
        # Find the team by alias to get the slug
        team = Team.find_by(alias: params[:team])
        @filtered_team_name = team.alias if team
      end
      
      # Apply search filter if present
      if params[:search].present?
        search_term = "%#{params[:search].downcase}%"
        @rankings = @rankings.joins(:player).where(
          "LOWER(players.first_name) LIKE ? OR LOWER(players.last_name) LIKE ? OR LOWER(players.team_slug) LIKE ?", 
          search_term, search_term, search_term
        )
      end
      
      # Sort by the appropriate rank based on sort parameter
      @sort_by = params[:sort] || 'pass_block'
    
      puts "Sorting by: #{@sort_by}"

      case @sort_by
      when 'run_block'
        puts "Sorting by run block"
        @rankings = @rankings.order(:rank_3, :rank_2, :rank_1)

        # @rankings = @rankings.order(:rank_3)
        # @rankings = Ranking.all.order(:rank_3)
      when 'offense'
        puts "Sorting by offense"
        @rankings = @rankings.order(:rank_1, :rank_2, :rank_3)
      else
        puts "Sorting by pass block"
        @rankings = @rankings.order(:rank_2, :rank_3, :rank_1) # Default to pass block
      end


      ap @rankings.first(5)
      puts "--------------------------------"
      ap @rankings.first.player
      
      # Get available weeks for navigation
      @available_weeks = Week.where(season_year: @year).order(:sequence).pluck(:sequence)
      @available_seasons = Week.distinct.pluck(:season_year).sort.reverse
      
      # Set page title and meta description for SEO
      @page_title = "NFL Offensive Line Rankings - Week #{@week} #{@year} Season"
      @meta_description = "Comprehensive NFL offensive line rankings for Week #{@week} of the #{@year} season. Compare pass block and run block grades for all starting offensive linemen."
    end
  end
  
  private
  
  def fallback_to_live_calculation
    # Get current week's matchups to find starting oline players
    @current_matchups = Matchup.where(season: @year, week_slug: @week)
    
    # If no matchups for current week, try to get from TeamsWeek as fallback
    if @current_matchups.empty?
      @current_teams_weeks = TeamsWeek.where(season_year: @year, week_number: @week)
      oline_slugs = @current_teams_weeks.pluck(:c, :lt, :rt, :lg, :rg).flatten.compact.uniq
    else
      # Get all oline player slugs from current matchups
      oline_slugs = @current_matchups.pluck(:c, :lt, :rt, :lg, :rg).flatten.compact.uniq
    end
    
    # Get the actual Player objects and filter out those without pass block grades
    @oline_players = Player.where(slug: oline_slugs)
                          .where.not(grades_pass_block: [nil, 0])
                          .includes(:team)
    
    # Apply search filter if present
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @oline_players = @oline_players.where(
        "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(team_slug) LIKE ?", 
        search_term, search_term, search_term
      )
    end
    
    # Sort by pass block grade (default) or run block grade
    @sort_by = params[:sort] || 'pass_block'
    
    case @sort_by
    when 'run_block'
      @oline_players = @oline_players.order(grades_run_block: :desc, grades_pass_block: :desc)
    else
      @oline_players = @oline_players.order(grades_pass_block: :desc, grades_run_block: :desc)
    end
    
    # Calculate percentile ranks for each player based on their position in the sorted list
    total_players = @oline_players.count
    
    @oline_players_with_ranks = @oline_players.map.with_index do |player, index|
      # Calculate percentile rank (lower number = better rank)
      # For pass block rankings
      if @sort_by == 'pass_block'
        pass_block_rank = index + 1
        run_block_rank = @oline_players.where("grades_run_block > ?", player.grades_run_block || 0).count + 1
      else # run_block sorting
        run_block_rank = index + 1
        pass_block_rank = @oline_players.where("grades_pass_block > ?", player.grades_pass_block || 0).count + 1
      end
      
      # Calculate percentiles (lower = better)
      pass_block_percentile = (pass_block_rank / total_players.to_f * 100).round(1)
      run_block_percentile = (run_block_rank / total_players.to_f * 100).round(1)
      
      # Add rank and percentile attributes to the player object
      # Note: These singleton methods will override the model's pass_block_rank/run_block_rank methods
      # which now use stored rankings. This fallback is only used when no stored rankings exist.
      player.define_singleton_method(:pass_block_rank) { pass_block_rank }
      player.define_singleton_method(:run_block_rank) { run_block_rank }
      player.define_singleton_method(:percentile_pass_block) { pass_block_percentile }
      player.define_singleton_method(:percentile_run_block) { run_block_percentile }
      
      player
    end
    
    # Replace the original collection with the ranked one
    @oline_players = @oline_players_with_ranks
    
    # Create a hash to quickly check if a player is a starter and their position
    @starter_positions = {}
    
    if @current_matchups.any?
      @current_matchups.each do |matchup|
        @starter_positions[matchup.c] = 'C' if matchup.c
        @starter_positions[matchup.lt] = 'LT' if matchup.lt
        @starter_positions[matchup.rt] = 'RT' if matchup.rt
        @starter_positions[matchup.lg] = 'LG' if matchup.lg
        @starter_positions[matchup.rg] = 'RG' if matchup.rg
      end
    elsif @current_teams_weeks&.any?
      @current_teams_weeks.each do |teams_week|
        @starter_positions[teams_week.c] = 'C' if teams_week.c
        @starter_positions[teams_week.lt] = 'LT' if teams_week.lt
        @starter_positions[teams_week.rt] = 'RT' if teams_week.rt
        @starter_positions[teams_week.lg] = 'LG' if teams_week.lg
        @starter_positions[teams_week.rg] = 'RG' if teams_week.rg
      end
    end
    
    # Get available weeks for navigation
    @available_weeks = Week.where(season_year: @year).order(:sequence).pluck(:sequence)
    @available_seasons = Week.distinct.pluck(:season_year).sort.reverse
    
    # Set page title and meta description for SEO
    @page_title = "NFL Offensive Line Rankings - Week #{@week} #{@year} Season"
    @meta_description = "Comprehensive NFL offensive line rankings for Week #{@week} of the #{@year} season. Compare pass block and run block grades for all starting offensive linemen."
  end
end
