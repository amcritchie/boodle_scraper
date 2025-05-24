namespace :contracts do
  desc "Populate player contracts from CSV"
  task populate: :environment do

    # Scrape by team
    # https://github.com/the-data-analyst/python_portfolio_web_scraper-spotrac/blob/master/webScraping_sample.py

    # Total playes output
    puts "============="
    puts "Players w/ Contracts: #{Player.where.not(current_cap_hit: nil).count}"
    puts "============="
  end
end

def pff_populate(file_name, position)
  puts "Populating #{position.to_s.upcase}s"
  require 'csv'
  file_path = Rails.root.join('lib', 'pff', file_name)

  CSV.foreach(file_path, headers: true) do |row|
    # ID team
    team = row['Team'].downcase rescue "unknown"
    team = :lar if team == "la"
    team = :hou if team == "hst"
    team = :bal if team == "blt"
    team = :cle if team == "clv"
    # Validate team found
    next "Team not found" unless team = Team.find_by(slug: team)
    # Import PFF player
    team.pff_player_import(row,position)
  end
end

def pff_quarterback_populate
  pff_populate('pff-qb-5-5-2025.csv', :quarterback)
end

def pff_runningback_populate
   pff_populate('pff-rb-5-5-2025.csv', :runningback)
end

def pff_wide_receiver_populate
  pff_populate('pff-wr-5-5-2025.csv', :wide_receiver)
end

def pff_tight_end_populate
  pff_populate('pff-te-5-5-2025.csv', :tight_end)
end

def pff_fullback_populate
    pff_populate('pff-fb-5-5-2025.csv', :fullback)
end;'lpp'

def pff_center_populate
    pff_populate('pff-center-5-5-2025.csv', :center)
end

def pff_gaurd_populate
    pff_populate('pff-gaurd-5-5-2025.csv', :gaurd)
end

def pff_tackle_populate
  pff_populate('pff-tackle-5-5-2025.csv', :tackle)
end

def pff_cornerback_populate
  pff_populate('pff-cb-5-5-2025.csv', :cornerback)
end

def pff_safeties_populate
  pff_populate('pff-safe-5-5-2025.csv', :safeties)
end

def pff_linebackers_populate
  pff_populate('pff-lb-5-5-2025.csv', :linebackers)
end

def pff_edge_populate
  pff_populate('pff-edge-5-5-2025.csv', :edge_rusher)
end

def pff_de_populate
  pff_populate('pff-de-5-5-2025.csv', :defensive_end)
end
