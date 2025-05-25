class Matchup < ApplicationRecord
#   belongs_to :team

  validates :season, :week, :game, :team, presence: true

  # Add methods to fetch offensive and defensive players if needed

  def self.phi
    find_by(season: 2025, week: 1, team: :phi)
  end

  def index_grade

    puts "=QB=============="
    puts qb.slug
    puts "🏈 #{qb.passing_grade}  🏃 #{qb.rushing_grade} 🙌 #{qb.receiving_grade}"
    puts "---------------"

    puts "=O-LINE=============="
    oline.each do |blocker|
      puts blocker.slug
      puts "🏈 #{blocker.pass_block_grade}  🏃 #{blocker.run_block_grade}"
    end

    puts "=RB=============="
    puts rb.slug
    puts "🏈 #{rb.pass_block_grade}  🏃 #{rb.rushing_grade} 🙌 #{rb.receiving_grade}"
    puts "---------------"

    puts "=Receivers=============="
    receivers.each do |receiver|
      puts receiver.slug
      puts "🏈 #{receiver.receiving_grade}  🏃 #{receiver.run_block_grade}"
    end

    puts "=D-Line=============="
    dline.each do |rusher|
      puts rusher.slug
      puts "🏈 #{rusher.pass_rush_grade}  🏃 #{rusher.rush_defense_grade} 🙌 #{rusher.coverage_grade}"
    end
    puts "=Linebackers=============="
    linebackers.each do |lb|
      puts lb.slug
      puts "🏈 #{lb.pass_rush_grade}  🏃 #{lb.rush_defense_grade} 🙌 #{lb.coverage_grade}"
    end
    puts "=Secondary=============="
    secondary.each do |back|
      puts back.slug
      puts "🏈 #{back.pass_rush_grade}  🏃 #{back.rush_defense_grade} 🙌 #{back.coverage_grade}"
    end


    # ap oline.first
    # ap oline.last


    # What is grade on Offensive Line

    # What is grade on Offensive Line + RB

    # What is grade on Offensive Line + WR

  end

  def offense_starters
    [self.o1, self.o2, self.o3, self.o4, self.o5, self.o6, self.o7, self.o8, self.o9, self.o10, self.o11].filter_map { |slug| Player.find_by_slug(slug) }
  end

  def qb
    Player.find_by_slug(self.o1)
  end

  def rb
    Player.find_by_slug(self.o2)
  end

  def wide_receivers
    offense_starters.filter_map { |player| player if player.slug&.start_with?("wide_receiver") }
  end

  def tight_ends
    offense_starters.filter_map { |player| player if player.slug&.start_with?("tight_end") }
  end

  def fullbacks
    [] # Add logic if fullbacks are included in the dataset
  end

  def receivers
    wide_receivers + tight_ends
  end

  def oline
    [center] + guards + tackles
  end

  def center
    Player.find_by_slug(self.o7)
  end

  def guards
    offense_starters.filter_map { |player| player if player.slug&.start_with?("gaurd") }
  end

  def tackles
    offense_starters.filter_map { |player| player if player.slug&.start_with?("tackle") }
  end

  def defense_starters
    [self.d1, self.d2, self.d3, self.d4, self.d5, self.d6, self.d7, self.d8, self.d9, self.d10, self.d11].filter_map { |slug| Player.find_by_slug(slug) }
  end

  def edge_rushers
    defense_starters.filter_map { |player| player if player.slug&.start_with?("edge_rusher") }
  end

  def defensive_ends
    defense_starters.filter_map { |player| player if player.slug&.start_with?("defensive_end") }
  end

  def dline
    defensive_ends + edge_rushers
  end

  def linebackers
    defense_starters.filter_map { |player| player if player.slug&.start_with?("linebackers") }
  end

  def cornerbacks
    defense_starters.filter_map { |player| player if player.slug&.start_with?("cornerback") }
  end

  def safeties
    defense_starters.filter_map { |player| player if player.slug&.start_with?("safeties") }
  end

  def secondary
    cornerbacks + safeties
  end

  def back_7
    secondary + linebackers
  end


  # Stack error
  # def kicker
  #   Player.find_by_slug(self.place_kicker) # Replace `k1` with the actual key for kicker if available
  # end

  # def punter
  #   Player.find_by_slug(self.punter) # Replace `p1` with the actual key for punter if available
  # end

end

# o1: nil,
# o2: "runningback-robinson-alabama-2022",
# o3: "wide_receiver-mclaurin-ohio-state-2019",
# o4: "wide_receiver-samuel-s-carolina-2019",
# o5: "tight_end-ertz-stanford-2013",
# o6: "runningback-mcnichols-boise-st-2017",
# o7: "center-biadasz-4-146",
# o8: "gaurd-cosmi-texas-2021",
# o9: "gaurd-allegretti-illinois-2019",
# o10: "tackle-tunsil-ole-miss-2016",
# o11: "tackle-wylie-e-michigan-2017",
# d1: "defensive_end-day-notre-dame-2016",
# d2: "defensive_end-kinlaw-s-carolina-2020",
# d3: "edge_rusher-armstrong-kansas-2018",
# d4: "linebackers-wagner-utah-st-2012",
# d5: "linebackers-luvu-wash-state-2018",
# d6: "safeties-martin-illinois-2023",
# d7: "safeties-harris-boston-col-2019",
# d8: "cornerback-sainristil-michigan-2024",
# d9: "cornerback-jones-auburn-2016",
# d10: "edge_rusher-jr.-arkansas-2017",
# d11: "cornerback-lattimore-ohio-state-2017",