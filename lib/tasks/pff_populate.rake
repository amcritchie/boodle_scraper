namespace :players do
  desc "Populate players from CSV"
  task pff_populate: :environment do
    # # Populate QBs
    # pff_quarterback_populate
    # # Populate RBs
    # pff_runningback_populate
    # # Populate WRs
    # pff_wide_receiver_populate
    # # Populate TEs
    # pff_tight_end_populate
    # # Populate FBs
    # pff_fullback_populate
    # # Populate Cs
    # pff_center_populate
    # # Populate Gs
    # pff_gaurd_populate
    # Populate Ts
    pff_tackle_populate

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
  end
end

def pff_populate(file_name, position)
  puts "Populating #{position.to_s.upcase}s"
  require 'csv'
  file_path = Rails.root.join('lib', 'pff', file_name)

  CSV.foreach(file_path, headers: true) do |row|
    player_name = row['Player']
    first_name = player_name.split.first.downcase rescue ""
    last_name = player_name.split.last.downcase rescue ""
    college = row['College'].downcase.gsub(' ', '-') rescue 'undrafted'
    draft_year = row['Draft_Year']
    slug = "#{position}-#{last_name}-#{college}-#{draft_year}"
    puts player_name
    puts slug

    player = Player.find_or_create_by(slug: slug) do |player|
        player.position = position
        player.rank = row['Rank']
        player.player = player_name
        player.first_name = first_name
        player.last_name = last_name
        player.team = row['Team']
        player.jersey = row['Jersey']
        player.overall_grade = row['Overall_Grade']
        player.passing_grade = row['Passing_Grade']
        player.running_grade = row['Running_Grade']
        player.rpo_grade = row['RPO_Grade']
        player.dropback_grade = row['Dropback_Grade']
        player.pocket_grade = row['Pocket_Grade']
        player.total_snaps = row['Total_Snaps']
        player.pass_snaps = row['Pass_Snaps']
        player.rush_snaps = row['Rush_Snaps']
        player.rpo_snaps = row['RPO_Snaps']
        player.dropback_snaps = row['Dropback_Snaps']
        player.pocket_snaps = row['Pocket_Snaps']
        player.age = row['Age']
        player.hand = row['Hand']
        player.height = row['Height']
        player.weight = row['Weight']
        player.speed = row['Speed']
        player.college = row['College']
        player.draft_year = row['Draft_Year']
        player.draft_round = row['Draft_Round']
        player.draft_pick = row['Draft_Pick']
    end
    # Puts description
    puts player.errors
    puts player.errors.inspect
    puts player.description
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
  puts "="*100
  puts "TEs"
  puts "-"*100
  pff_populate('pff-te-5-5-2025.csv', :tight_end)
  puts Player.where(position: "tight_end").last.inspect
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
  puts "="*100
  puts "Tackles"
  puts "-"*100
    pff_populate('pff-tackle-5-5-2025.csv', :tackle)
    puts Player.where(position: "tackle").last.inspect
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
