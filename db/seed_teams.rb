# Seed file for NFL Teams
# Run with: docker exec boodle_scraper-web-1 bin/rails runner "load 'db/seed_teams.rb'"
# Idempotent — uses find_or_create_by!(slug:)

teams_data = [
  { slug: "arizona-cardinals",      name: "Arizona Cardinals",      location: "Arizona",       alias: "Cardinals",  conference: "NFC", division: "NFC West",  active: true, hashtag: "#AZCardinals" },
  { slug: "atlanta-falcons",        name: "Atlanta Falcons",        location: "Atlanta",       alias: "Falcons",    conference: "NFC", division: "NFC South", active: true, hashtag: "#RiseUp" },
  { slug: "baltimore-ravens",       name: "Baltimore Ravens",       location: "Baltimore",     alias: "Ravens",     conference: "AFC", division: "AFC North", active: true, hashtag: "#RavensFlock" },
  { slug: "buffalo-bills",          name: "Buffalo Bills",          location: "Buffalo",       alias: "Bills",      conference: "AFC", division: "AFC East",  active: true, hashtag: "#BillsMafia" },
  { slug: "carolina-panthers",      name: "Carolina Panthers",      location: "Carolina",      alias: "Panthers",   conference: "NFC", division: "NFC South", active: true, hashtag: "#KeepPounding" },
  { slug: "chicago-bears",          name: "Chicago Bears",          location: "Chicago",       alias: "Bears",      conference: "NFC", division: "NFC North", active: true, hashtag: "#DaBears" },
  { slug: "cincinnati-bengals",     name: "Cincinnati Bengals",     location: "Cincinnati",    alias: "Bengals",    conference: "AFC", division: "AFC North", active: true, hashtag: "#WhoDey" },
  { slug: "cleveland-browns",       name: "Cleveland Browns",       location: "Cleveland",     alias: "Browns",     conference: "AFC", division: "AFC North", active: true, hashtag: "#Browns" },
  { slug: "dallas-cowboys",         name: "Dallas Cowboys",         location: "Dallas",        alias: "Cowboys",    conference: "NFC", division: "NFC East",  active: true, hashtag: "#DallasCowboys" },
  { slug: "denver-broncos",         name: "Denver Broncos",         location: "Denver",        alias: "Broncos",    conference: "AFC", division: "AFC West",  active: true, hashtag: "#BroncosCountry" },
  { slug: "detroit-lions",          name: "Detroit Lions",          location: "Detroit",       alias: "Lions",      conference: "NFC", division: "NFC North", active: true, hashtag: "#OnePride" },
  { slug: "green-bay-packers",      name: "Green Bay Packers",      location: "Green Bay",     alias: "Packers",    conference: "NFC", division: "NFC North", active: true, hashtag: "#GoPackGo" },
  { slug: "houston-texans",         name: "Houston Texans",         location: "Houston",       alias: "Texans",     conference: "AFC", division: "AFC South", active: true, hashtag: "#TexansFootball" },
  { slug: "indianapolis-colts",     name: "Indianapolis Colts",     location: "Indianapolis",  alias: "Colts",      conference: "AFC", division: "AFC South", active: true, hashtag: "#ForTheShoe" },
  { slug: "jacksonville-jaguars",   name: "Jacksonville Jaguars",   location: "Jacksonville",  alias: "Jaguars",    conference: "AFC", division: "AFC South", active: true, hashtag: "#DUUUVAL" },
  { slug: "kansas-city-chiefs",     name: "Kansas City Chiefs",     location: "Kansas City",   alias: "Chiefs",     conference: "AFC", division: "AFC West",  active: true, hashtag: "#ChiefsKingdom" },
  { slug: "las-vegas-raiders",      name: "Las Vegas Raiders",      location: "Las Vegas",     alias: "Raiders",    conference: "AFC", division: "AFC West",  active: true, hashtag: "#RaiderNation" },
  { slug: "los-angeles-chargers",   name: "Los Angeles Chargers",   location: "Los Angeles",   alias: "Chargers",   conference: "AFC", division: "AFC West",  active: true, hashtag: "#BoltUp" },
  { slug: "los-angeles-rams",       name: "Los Angeles Rams",       location: "Los Angeles",   alias: "Rams",       conference: "NFC", division: "NFC West",  active: true, hashtag: "#RamsHouse" },
  { slug: "miami-dolphins",         name: "Miami Dolphins",         location: "Miami",         alias: "Dolphins",   conference: "AFC", division: "AFC East",  active: true, hashtag: "#FinsUp" },
  { slug: "minnesota-vikings",      name: "Minnesota Vikings",      location: "Minnesota",     alias: "Vikings",    conference: "NFC", division: "NFC North", active: true, hashtag: "#Skol" },
  { slug: "new-england-patriots",   name: "New England Patriots",   location: "New England",   alias: "Patriots",   conference: "AFC", division: "AFC East",  active: true, hashtag: "#Patriots" },
  { slug: "new-orleans-saints",     name: "New Orleans Saints",     location: "New Orleans",   alias: "Saints",     conference: "NFC", division: "NFC South", active: true, hashtag: "#Saints" },
  { slug: "new-york-giants",        name: "New York Giants",        location: "New York",      alias: "Giants",     conference: "NFC", division: "NFC East",  active: true, hashtag: "#TogetherBlue" },
  { slug: "new-york-jets",          name: "New York Jets",          location: "New York",      alias: "Jets",       conference: "AFC", division: "AFC East",  active: true, hashtag: "#TakeFlight" },
  { slug: "philadelphia-eagles",    name: "Philadelphia Eagles",    location: "Philadelphia",  alias: "Eagles",     conference: "NFC", division: "NFC East",  active: true, hashtag: "#FlyEaglesFly" },
  { slug: "pittsburgh-steelers",    name: "Pittsburgh Steelers",    location: "Pittsburgh",    alias: "Steelers",   conference: "AFC", division: "AFC North", active: true, hashtag: "#HereWeGo" },
  { slug: "san-francisco-49ers",    name: "San Francisco 49ers",    location: "San Francisco", alias: "49ers",      conference: "NFC", division: "NFC West",  active: true, hashtag: "#FTTB" },
  { slug: "seattle-seahawks",       name: "Seattle Seahawks",       location: "Seattle",       alias: "Seahawks",   conference: "NFC", division: "NFC West",  active: true, hashtag: "#GoHawks" },
  { slug: "tampa-bay-buccaneers",   name: "Tampa Bay Buccaneers",   location: "Tampa Bay",     alias: "Buccaneers", conference: "NFC", division: "NFC South", active: true, hashtag: "#GoBucs" },
  { slug: "tennessee-titans",       name: "Tennessee Titans",       location: "Tennessee",     alias: "Titans",     conference: "AFC", division: "AFC South", active: true, hashtag: "#Titans" },
  { slug: "washington-commanders",  name: "Washington Commanders",  location: "Washington",    alias: "Commanders", conference: "NFC", division: "NFC East",  active: true, hashtag: "#HTTC" },
]

puts "Seeding #{teams_data.size} NFL teams..."

teams_data.each do |attrs|
  team = Team.find_or_create_by!(slug: attrs[:slug])
  team.update!(
    name:       attrs[:name],
    location:   attrs[:location],
    alias:      attrs[:alias],
    conference: attrs[:conference],
    division:   attrs[:division],
    active:     attrs[:active],
    hashtag:    attrs[:hashtag]
  )
  puts "  ✓ #{team.name} (#{team.hashtag})"
end

puts "\nDone — #{Team.count} teams in DB."
