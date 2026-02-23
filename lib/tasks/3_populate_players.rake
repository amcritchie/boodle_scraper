namespace :players do
  desc "Populate players from CSV"
  task pff_player_grades: :environment do
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
