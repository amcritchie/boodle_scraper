class Matchup < ApplicationRecord
#   belongs_to :team

  validates :season, :week, :game, :team, presence: true

  # Add methods to fetch offensive and defensive players if needed

  def qb
    Player.find_by_slug(self.o1)
  end

  def rb
    Player.find_by_slug(self.o2)
  end

  def wide_receivers
    positions = [self.o3, self.o4, self.o5, self.o6]
    positions.filter_map { |slug| Player.find_by_slug(slug) if slug&.start_with?("wide_receiver") }
  end

  def cornerbacks
    [self.d8, self.d9, self.d11].filter_map { |slug| Player.find_by_slug(slug) if slug&.start_with?("cornerback") }
  end

  def safeties
    [self.d6, self.d7].filter_map { |slug| Player.find_by_slug(slug) if slug&.start_with?("safeties") }
  end

  def secondary
    cornerbacks + safeties
  end

  def linebackers
    [self.d4, self.d5].filter_map { |slug| Player.find_by_slug(slug) if slug&.start_with?("linebackers") }
  end

  def back_7
    secondary + linebackers
  end

  def edge_rushers
    [self.d3, self.d10].filter_map { |slug| Player.find_by_slug(slug) if slug&.start_with?("edge_rusher") }
  end

  def defensive_ends
    [self.d1, self.d2].filter_map { |slug| Player.find_by_slug(slug) if slug&.start_with?("defensive_end") }
  end

  def defense_starters
    defensive_ends + edge_rushers + back_7
  end

  def offense_starters
    [qb, rb] + wide_receivers + tight_ends + [center] + guards + tackles
  end

  def center
    Player.find_by_slug(self.o7)
  end

  def guards
    [self.o8, self.o9].filter_map { |slug| Player.find_by_slug(slug) if slug&.start_with?("gaurd") }
  end

  def tackles
    [self.o10, self.o11].filter_map { |slug| Player.find_by_slug(slug) if slug&.start_with?("tackle") }
  end

  def tight_ends
    [self.o5].filter_map { |slug| Player.find_by_slug(slug) if slug&.start_with?("tight_end") }
  end

  def fullbacks
    [] # Add logic if fullbacks are included in the dataset
  end

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