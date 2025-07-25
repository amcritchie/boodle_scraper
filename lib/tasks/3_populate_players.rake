namespace :players do
  desc "Populate players from CSV"
  task populate: :environment do
    # Populate QBs
    pff_passing_grade_populate
    # Populate RBs
    pff_rushing_grade_populate
    # Populate WRs
    pff_receiving_grade_populate
    # Populate Blocking
    pff_blocking_grade_populate
    # Populate Defense
    pff_defense_grade_populate

    # Total playes output
    puts "============="
    puts "Players: #{Player.count}"
    puts "============="
  end
end

def pff_passing_grade_populate
  Team.pff_passer_import 'lib/pff/2024-qb/passing_summary.csv'
end

def pff_rushing_grade_populate
  Team.pff_rusher_import 'lib/pff/2024-flex/rushing_summary.csv'
end

def pff_receiving_grade_populate
  Team.pff_receiver_import 'lib/pff/2024-flex/receiving_summary.csv'
end

def pff_blocking_grade_populate
  Team.pff_blocker_import 'lib/pff/2024-oline/offense_blocking.csv'
end

def pff_defense_grade_populate
  Team.pff_defense_import 'lib/pff/2024-defense/defense_summary.csv'
end

# # def pff_populate(file_name, position)
# #   puts "Populating #{position.to_s.upcase}s"
# #   require 'csv'
# #   file_path = Rails.root.join('lib', 'pff', file_name)

# #   CSV.foreach(file_path, headers: true) do |row|
# #     puts row['Team']
# #     # ID team
# #     team_slug = row['Team'] rescue "unknown"
# #     # Find and validate team_slug
# #     unless team = Team.pff_team(team_slug)
# #       puts "No Team Found for #{team}"
# #       next
# #     end
# #     # Import PFF player
# #     team.pff_player_import(row,position)
# #   end
# # end

# def pff_tight_end_populate
#   pff_populate('pff-te-5-5-2025.csv', :tight_end)
# end

# def pff_fullback_populate
#     pff_populate('pff-fb-5-5-2025.csv', :fullback)
# end;'lpp'

# def pff_center_populate
#     pff_populate('pff-center-5-5-2025.csv', :center)
# end

# def pff_gaurd_populate
#     pff_populate('pff-gaurd-5-5-2025.csv', :gaurd)
# end

# def pff_tackle_populate
#   pff_populate('pff-tackle-5-5-2025.csv', :tackle)
# end

# def pff_cornerback_populate
#   pff_populate('pff-cb-5-5-2025.csv', :cornerback)
# end

# def pff_safeties_populate
#   pff_populate('pff-safe-5-5-2025.csv', :safeties)
# end

# def pff_linebackers_populate
#   pff_populate('pff-lb-5-5-2025.csv', :linebackers)
# end

# def pff_edge_populate
#   pff_populate('pff-edge-5-5-2025.csv', :edge_rusher)
# end

# def pff_de_populate
#   pff_populate('pff-de-5-5-2025.csv', :defensive_end)
# end
