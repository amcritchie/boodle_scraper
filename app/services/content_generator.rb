class ContentGenerator
  ATHLETES = {
    nfl: {
      "Kansas City Chiefs" => ["Patrick Mahomes", "Travis Kelce", "Chris Jones"],
      "Buffalo Bills" => ["Josh Allen", "Stefon Diggs", "Von Miller"],
      "San Francisco 49ers" => ["Brock Purdy", "Christian McCaffrey", "Nick Bosa"],
      "Philadelphia Eagles" => ["Jalen Hurts", "AJ Brown", "Saquon Barkley"],
      "Dallas Cowboys" => ["Dak Prescott", "CeeDee Lamb", "Micah Parsons"],
      "Miami Dolphins" => ["Tua Tagovailoa", "Tyreek Hill", "Jaylen Waddle"],
      "Baltimore Ravens" => ["Lamar Jackson", "Derrick Henry", "Mark Andrews"],
      "Detroit Lions" => ["Jared Goff", "Amon-Ra St. Brown", "Aidan Hutchinson"],
      "Cincinnati Bengals" => ["Joe Burrow", "Ja'Marr Chase", "Trey Hendrickson"],
      "Green Bay Packers" => ["Jordan Love", "Josh Jacobs", "Jaire Alexander"]
    },
    nba: {
      "Boston Celtics" => ["Jayson Tatum", "Jaylen Brown", "Derrick White"],
      "Denver Nuggets" => ["Nikola Jokic", "Jamal Murray", "Michael Porter Jr."],
      "Milwaukee Bucks" => ["Giannis Antetokounmpo", "Damian Lillard", "Khris Middleton"],
      "Oklahoma City Thunder" => ["Shai Gilgeous-Alexander", "Chet Holmgren", "Jalen Williams"],
      "Los Angeles Lakers" => ["LeBron James", "Anthony Davis", "Austin Reaves"]
    },
    nhl: {
      "Edmonton Oilers" => ["Connor McDavid", "Leon Draisaitl", "Evan Bouchard"],
      "Colorado Avalanche" => ["Nathan MacKinnon", "Cale Makar", "Mikko Rantanen"],
      "Florida Panthers" => ["Aleksander Barkov", "Matthew Tkachuk", "Sergei Bobrovsky"]
    },
    mlb: {
      "Los Angeles Dodgers" => ["Shohei Ohtani", "Mookie Betts", "Freddie Freeman"],
      "Atlanta Braves" => ["Ronald Acuna Jr.", "Matt Olson", "Spencer Strider"],
      "New York Yankees" => ["Aaron Judge", "Juan Soto", "Gerrit Cole"]
    }
  }.freeze

  TEMPLATES = [
    "%{athlete} when the game is on the line: %{take}",
    "Who's more overrated: %{athlete1} or %{athlete2}? VOTE NOW",
    "Unpopular opinion: %{athlete} is %{take}",
    "%{athlete} is the most %{adjective} player in the %{sport}. Change my mind.",
    "Hot take: %{athlete} will %{prediction} this season",
    "Breaking it down: Why %{athlete} is %{take}",
    "Rate %{athlete}'s season so far: 1-10",
    "%{athlete} vs %{athlete2}: Who would you rather have on your team?",
    "Nobody wants to admit it but %{athlete} is %{take}",
    "The %{team} are %{take} and it's not even close"
  ].freeze

  TAKES = [
    "completely unstoppable",
    "overrated and everyone knows it",
    "the best player in the league",
    "not even a top 5 player at their position",
    "about to have a monster year",
    "carrying the entire franchise",
    "washed up and coasting on reputation",
    "the most underrated player in sports",
    "a walking highlight reel",
    "a system player who gets too much credit"
  ].freeze

  ADJECTIVES = [
    "underrated", "overrated", "clutch", "inconsistent",
    "dominant", "overpaid", "explosive", "polarizing"
  ].freeze

  PREDICTIONS = [
    "win MVP", "lead their team to a championship",
    "have a career year", "disappoint everyone",
    "get traded", "break multiple records",
    "prove all the haters wrong", "regress hard"
  ].freeze

  def generate_post
    sport = ATHLETES.keys.sample
    team = ATHLETES[sport].keys.sample
    players = ATHLETES[sport][team]
    template = TEMPLATES.sample

    athlete1 = players.sample
    athlete2 = pick_different_athlete(sport, athlete1)

    content = template % {
      athlete: athlete1,
      athlete1: athlete1,
      athlete2: athlete2,
      team: team,
      sport: sport.to_s.upcase,
      take: TAKES.sample,
      adjective: ADJECTIVES.sample,
      prediction: PREDICTIONS.sample
    }

    Post.new(
      title: content,
      content: content,
      sport: sport.to_s,
      stage: "draft"
    )
  end

  private

  def pick_different_athlete(sport, exclude)
    all_players = ATHLETES[sport].values.flatten
    candidates = all_players - [exclude]
    candidates.sample || exclude
  end
end
