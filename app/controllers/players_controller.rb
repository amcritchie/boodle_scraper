class PlayersController < ApplicationController
  def index
    @year = 2025 # Default to 2025 season
    
    # Get all teams for filtering
    @teams = Team.active.order(:name)
    
    # Build the base query
    @players = Player.includes(:team)
    
    # Apply filters
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @players = @players.where(
        "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?", 
        search_term, search_term
      )
      
      # Also search by team name if search term matches
      team_matches = @teams.where("LOWER(name) LIKE ?", search_term)
      if team_matches.any?
        team_slugs = team_matches.pluck(:slug)
        @players = @players.or(Player.where(team_slug: team_slugs))
      end
    end
    
    if params[:team].present?
      @players = @players.where(team_slug: params[:team])
    end
    
    if params[:position].present?
      @players = @players.where(position: params[:position])
    end
    
    # Get all teams seasons for checking starters
    @teams_seasons = TeamsSeason.where(season_year: @year)
    
    # Create a hash to quickly check if a player is a starter
    @starter_positions = {}
    @teams_seasons.each do |ts|
      # Offense starters
      @starter_positions[ts.qb] = 'QB' if ts.qb
      @starter_positions[ts.rb1] = 'RB1' if ts.rb1
      @starter_positions[ts.rb2] = 'RB2' if ts.rb2
      @starter_positions[ts.wr1] = 'WR1' if ts.wr1
      @starter_positions[ts.wr2] = 'WR2' if ts.wr2
      @starter_positions[ts.wr3] = 'WR3' if ts.wr3
      @starter_positions[ts.te] = 'TE' if ts.te
      @starter_positions[ts.c] = 'C' if ts.c
      @starter_positions[ts.lt] = 'LT' if ts.lt
      @starter_positions[ts.rt] = 'RT' if ts.rt
      @starter_positions[ts.lg] = 'LG' if ts.lg
      @starter_positions[ts.rg] = 'RG' if ts.rg
      
      # Defense starters
      @starter_positions[ts.eg1] = 'EDGE1' if ts.eg1
      @starter_positions[ts.eg2] = 'EDGE2' if ts.eg2
      @starter_positions[ts.dl1] = 'DL1' if ts.dl1
      @starter_positions[ts.dl2] = 'DL2' if ts.dl2
      @starter_positions[ts.dl3] = 'DL3' if ts.dl3
      @starter_positions[ts.lb1] = 'LB1' if ts.lb1
      @starter_positions[ts.lb2] = 'LB2' if ts.lb2
      @starter_positions[ts.cb1] = 'CB1' if ts.cb1
      @starter_positions[ts.cb2] = 'CB2' if ts.cb2
      @starter_positions[ts.cb3] = 'CB3' if ts.cb3
      @starter_positions[ts.s1] = 'S1' if ts.s1
      @starter_positions[ts.s2] = 'S2' if ts.s2
    end
    
    # Order players by last name
    @players = @players.order(:last_name, :first_name)
    
    # Paginate results
    @players = @players.page(params[:page]).per(50)
  end


end 