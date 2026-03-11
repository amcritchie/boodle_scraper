# Seed file for News
# Run with: rails runner db/seed_news.rb

News.destroy_all
puts "Cleared existing news data"

news_data = [
  {
    title: "Patrick Mahomes Throws 4 TDs in Chiefs' Dominant Week 1 Victory",
    title_short: "Mahomes 4 TDs in W1 win",
    stage: "posted",
    url: "https://example.com/mahomes-week1",
    author: "Adam Schefter",
    published_at: 2.days.ago,
    primary_person: "Patrick Mahomes",
    primary_person_slug: "patrick-mahomes",
    primary_team: "Kansas City Chiefs",
    primary_team_slug: "kansas-city-chiefs",
    summary: "Patrick Mahomes was in peak form during the Chiefs' Week 1 matchup, completing 28 of 35 passes for 327 yards and 4 touchdowns with zero interceptions.",
    opinion: "Mahomes continues to look like the best QB in football. The Chiefs offense is firing on all cylinders heading into Week 2."
  },
  {
    title: "Lamar Jackson Rushes for 120 Yards as Ravens Cruise Past Bengals",
    title_short: "Lamar rushes for 120",
    stage: "posted",
    url: "https://example.com/lamar-week1",
    author: "Jamison Hensley",
    published_at: 2.days.ago,
    primary_person: "Lamar Jackson",
    primary_person_slug: "lamar-jackson",
    primary_team: "Baltimore Ravens",
    primary_team_slug: "baltimore-ravens",
    summary: "Lamar Jackson reminded the league why he's a two-time MVP, rushing for 120 yards and a touchdown while adding 245 yards and 2 TDs through the air.",
    opinion: "The Ravens' dual-threat offense is nearly impossible to stop when Lamar is in this form. Cincinnati's defense had no answers."
  },
  {
    title: "Cowboys Release Veteran Linebacker in Surprise Roster Move",
    title_short: "Cowboys cut veteran LB",
    stage: "edited",
    url: "https://example.com/cowboys-roster",
    author: "Todd Archer",
    published_at: 1.day.ago,
    primary_team: "Dallas Cowboys",
    primary_team_slug: "dallas-cowboys",
    summary: "The Dallas Cowboys made a surprising roster move Tuesday, releasing veteran linebacker in a salary cap-driven decision ahead of Week 2.",
    opinion: "This signals a shift toward youth at the position. The Cowboys are clearly planning for the future rather than the present."
  },
  {
    title: "Brock Purdy Extension Talks Reportedly Stall Over Guaranteed Money",
    title_short: "Purdy extension stalls",
    stage: "content",
    url: "https://example.com/purdy-contract",
    author: "Matt Barrows",
    published_at: 1.day.ago,
    primary_person: "Brock Purdy",
    primary_person_slug: "brock-purdy",
    primary_team: "San Francisco 49ers",
    primary_team_slug: "san-francisco-49ers",
    summary: "Negotiations between the 49ers and Brock Purdy have hit a snag over the structure of guaranteed money in a potential long-term extension.",
    opinion: "Purdy has earned top-tier money but the 49ers are right to be cautious with the guaranteed structure given their cap situation."
  },
  {
    title: "Caleb Williams Shows Poise in First NFL Start Despite Bears Loss",
    title_short: "Caleb Williams NFL debut",
    stage: "content",
    url: "https://example.com/caleb-williams-debut",
    author: "Courtney Cronin",
    published_at: 3.days.ago,
    primary_person: "Caleb Williams",
    primary_person_slug: "caleb-williams",
    primary_team: "Chicago Bears",
    primary_team_slug: "chicago-bears",
    summary: "Caleb Williams completed 22 of 34 passes for 267 yards with 2 touchdowns and 1 interception in his NFL debut, showing flashes of brilliance.",
    opinion: "The raw talent is undeniable. Williams made at least three throws that only a handful of QBs in the league can make."
  },
  {
    title: "Derrick Henry Scores 3 TDs in Ravens Blowout Win",
    title_short: "Henry 3 TDs for Ravens",
    stage: "reviewed",
    url: "https://example.com/henry-3tds",
    author: "Jeff Zrebiec",
    published_at: 12.hours.ago,
    primary_person: "Derrick Henry",
    primary_person_slug: "derrick-henry",
    primary_team: "Baltimore Ravens",
    primary_team_slug: "baltimore-ravens",
    summary: "Derrick Henry ran for 156 yards and 3 touchdowns on 24 carries as the Ravens dominated their Week 2 opponent from start to finish.",
    opinion: "Henry looks rejuvenated in Baltimore. The combination of him and Lamar is the most dangerous rushing attack in the NFL."
  },
  {
    title: "Jalen Hurts Dealing with Knee Injury, Status Uncertain for Week 3",
    title_short: "Hurts knee injury update",
    stage: "reviewed",
    url: "https://example.com/hurts-injury",
    author: "Tim McManus",
    published_at: 6.hours.ago,
    primary_person: "Jalen Hurts",
    primary_person_slug: "jalen-hurts",
    primary_team: "Philadelphia Eagles",
    primary_team_slug: "philadelphia-eagles",
    summary: "Eagles QB Jalen Hurts is dealing with a knee injury suffered in the fourth quarter of Sunday's game. His status for Week 3 remains uncertain.",
    opinion: "This is a significant concern for Philly. The dropoff to the backup is steep and the NFC East race is tight."
  },
  {
    title: "NFL Week 2 Power Rankings: Lions Jump to No. 1 After Statement Win",
    title_short: "Lions top power rankings",
    stage: "new",
    url: "https://example.com/week2-power-rankings",
    author: "Dan Hanzus",
    published_at: 4.hours.ago,
    primary_team: "Detroit Lions",
    primary_team_slug: "detroit-lions",
    summary: "The Detroit Lions leap to the top of our power rankings after a convincing 38-17 victory over the 49ers on Sunday Night Football.",
    opinion: "Detroit is for real. The offensive line is the best in football and the defense has taken a massive step forward."
  },
  {
    title: "Josh Allen Accounts for 5 TDs in Bills Shootout Win Over Dolphins",
    title_short: "Allen 5 TDs vs Dolphins",
    stage: "new",
    url: "https://example.com/allen-5tds",
    author: "Alaina Getzenberg",
    published_at: 3.hours.ago,
    primary_person: "Josh Allen",
    primary_person_slug: "josh-allen",
    primary_team: "Buffalo Bills",
    primary_team_slug: "buffalo-bills",
    summary: "Josh Allen threw for 4 touchdowns and rushed for another as the Bills outlasted the Dolphins 42-38 in a wild AFC East showdown.",
    opinion: "Allen is playing at an MVP level early in the season. The Bills offense looks unstoppable when he's in rhythm."
  },
  {
    title: "Texans Sign Former Pro Bowl Pass Rusher to Bolster Defense",
    title_short: "Texans add pass rusher",
    stage: "new",
    url: "https://example.com/texans-signing",
    author: "DJ Bien-Aime",
    published_at: 1.hour.ago,
    primary_team: "Houston Texans",
    primary_team_slug: "houston-texans",
    summary: "The Houston Texans have signed a former Pro Bowl edge rusher to a one-year deal, adding veteran presence to an already talented defensive front.",
    opinion: "Smart move by Houston. They're going all-in this year and this addition makes their pass rush even more dangerous."
  }
]

news_data.each do |attrs|
  News.create!(attrs)
end

puts "Created #{News.count} news items"
News.group(:stage).count.each do |stage, count|
  puts "  #{stage}: #{count}"
end
