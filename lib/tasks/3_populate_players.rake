namespace :players do
  desc "Populate players from CSV"
  task populate: :environment do
    # Populate QBs
    pff_quarterback_populate
    # Populate RBs
    pff_runningback_populate
    # Populate WRs
    pff_receiver_populate
    # # Populate TEs
    # pff_tight_end_populate
    # # Populate FBs
    # pff_fullback_populate
    # # Populate Cs
    # pff_center_populate
    # # Populate Gs
    # pff_gaurd_populate
    # # Populate Ts
    # pff_tackle_populate

    # # Populate DEs
    # pff_de_populate
    # # Populate Edges
    # pff_edge_populate
    # # Populate LBs
    # pff_linebackers_populate
    # # Populate Safeties
    # pff_safeties_populate
    # # Populate CBs
    # pff_cornerback_populate

    # Total playes output
    puts "============="
    puts "Players: #{Player.count}"
    puts "============="
    # ap Player.where.not(sportsradar_id: nil).where(first_name: "Lamar")
  end
end

def pff_quarterback_populate
  Team.pff_passer_import 'lib/pff/2024-qb/passing_summary.csv'
  # pff_populate('pff-qb-5-5-2025.csv', :quarterback) # First Version
end

def pff_runningback_populate
  Team.pff_rusher_import 'lib/pff/2024-flex/rushing_summary.csv'
  # pff_populate('pff-rb-5-5-2025.csv', :runningback) # First Version
end

def pff_receiver_populate
  Team.pff_receiver_import 'lib/pff/2024-flex/receiving_summary.csv'
  # pff_populate('pff-wr-5-5-2025.csv', :wide_receiver) # First Version
end

# def pff_populate(file_name, position)
#   puts "Populating #{position.to_s.upcase}s"
#   require 'csv'
#   file_path = Rails.root.join('lib', 'pff', file_name)

#   CSV.foreach(file_path, headers: true) do |row|
#     puts row['Team']
#     # ID team
#     team_slug = row['Team'] rescue "unknown"
#     # Find and validate team_slug
#     unless team = Team.pff_team(team_slug)
#       puts "No Team Found for #{team}"
#       next
#     end
#     # Import PFF player
#     team.pff_player_import(row,position)
#   end
# end

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
