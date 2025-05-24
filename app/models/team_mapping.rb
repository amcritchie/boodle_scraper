module TeamMapping
  def kaggle_team(team_name)
    case team_name
    when "Buffalo Bills"              # AFC East
      Team.find_or_create_by(slug_long: :buffalo_bills)
    when "New York Jets"
      Team.find_or_create_by(slug_long: :new_york_jets)
    when "Miami Dolphins"
      Team.find_or_create_by(slug_long: :miami_dolphins)
    when "New England Patriots"
      Team.find_or_create_by(slug_long: :new_england_patriots)
    when "Kansas City Chiefs"       # AFC West
      Team.find_or_create_by(slug_long: :kansas_city_chiefs)
    when "Denver Broncos"
      Team.find_or_create_by(slug_long: :denver_broncos)
    when "Los Angeles Chargers"
      Team.find_or_create_by(slug_long: :los_angeles_chargers)
    when "Las Vegas Raiders"
      Team.find_or_create_by(slug_long: :las_vegas_raiders)
    when "Oakland Raiders"
      Team.find_or_create_by(slug_long: :oakland_raiders)
    when "Cincinnati Bengals"       # AFC North
      Team.find_or_create_by(slug_long: :cincinnati_bengals)
    when "Baltimore Ravens"
      Team.find_or_create_by(slug_long: :baltimore_ravens)
    when "Pittsburgh Steelers"
      Team.find_or_create_by(slug_long: :pittsburgh_steelers)
    when "Cleveland Browns"
      Team.find_or_create_by(slug_long: :cleveland_browns)
    when "Jacksonville Jaguars"     # AFC South
      Team.find_or_create_by(slug_long: :jacksonville_jaguars)
    when "Houston Texans"
      Team.find_or_create_by(slug_long: :houston_texans)
    when "Tennessee Titans"
      Team.find_or_create_by(slug_long: :tennessee_titans)
    when "Indianapolis Colts"
      Team.find_or_create_by(slug_long: :indianapolis_colts)
    when "Green Bay Packers"        # NFC North
      Team.find_or_create_by(slug_long: :green_bay_packers)
    when "Minnesota Vikings"
      Team.find_or_create_by(slug_long: :minnesota_vikings)
    when "Chicago Bears"
      Team.find_or_create_by(slug_long: :chicago_bears)
    when "Detroit Lions"
      Team.find_or_create_by(slug_long: :detroit_lions)
    when "Dallas Cowboys"           # NFC EAST
      Team.find_or_create_by(slug_long: :dallas_cowboys)
    when "New York Giants"
      Team.find_or_create_by(slug_long: :new_york_giants)
    when "Philadelphia Eagles"
      Team.find_or_create_by(slug_long: :philadelphia_eagles)
    when "Washington Commanders"
      team = Team.find_or_create_by(slug_long: :washington_commanders)
    when "Washington Football Team"
    #   team = Team.find_or_create_by(slug_long: :washington_football_team)
    when "Washington Redskins"
      # team = Team.find_or_create_by(slug_long: :washington_redskins)
    when "Seattle Seahawks"         # NFC West
      Team.find_or_create_by(slug_long: :seattle_seahawks)
    when "Los Angeles Rams"
      Team.find_or_create_by(slug_long: :los_angeles_rams)
    when "San Francisco 49ers"
      Team.find_or_create_by(slug_long: :san_francisco_49ers)
    when "Arizona Cardinals"
      Team.find_or_create_by(slug_long: :arizona_cardinals)
    when "Atlanta Falcons"          # NFC South
      Team.find_or_create_by(slug_long: :atlanta_falcons)
    when "Carolina Panthers"
      Team.find_or_create_by(slug_long: :carolina_panthers)
    when "Tampa Bay Buccaneers"
      Team.find_or_create_by(slug_long: :tampa_bay_buccaneers)
    when "New Orleans Saints"
      Team.find_or_create_by(slug_long: :new_orleans_saints)
    else
      :unknown
    end
  end
end
