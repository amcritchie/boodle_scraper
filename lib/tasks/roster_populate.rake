namespace :rosters do
  desc "Populate roster for Week 1, Season 2025 Buffalo Bills"
  task populate: :environment do

    Team.active.each do |team|
        # Generate Week 1 Roster
        team.generate_roster(1,2024)
    end
  end
end
