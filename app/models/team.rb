class Team < ApplicationRecord
    
    def self.active_teams
        teams = Team.where(active: true).order(:conference, :division, :name)
        teams.each do |team|
            puts "#{team.conference} - #{team.division} - #{team.name} - #{team.active}"
        end
    end

    def self.kaggle_import
        require 'csv'
        # Parse CSV
        csv_text = File.read('lib/kaggle/nfl_teams.csv')
        csv = CSV.parse(csv_text, headers: true)
        # Each through rows in CSV
        csv.each do |row|
            # Get team attributes from row
            team_attrs = row.to_hash
            # Find of create based on slug and division (slug: "DEN", division: "AFC West")
            team = Team.find_or_create_by(name: team_attrs['team_name'], division: team_attrs['team_division']) do |team|
                # Set attributes for team
                team.name = team_attrs['team_name']
                team.slug = team_attrs['team_id']
                team.name_short = team_attrs['team_name_short']
                team.slug_pfr = team_attrs['team_id_pfr']
                team.conference = team_attrs['team_conference']
                team.division_pre_2002 = team_attrs['team_division_pre2002']
                team.conference_pre_2002 = team_attrs['team_conference_pre2002']
                # Denote team as active not active if they don't have a division or other criteria.
                team.active = false if team.division.nil? || team.division.empty?
                team.active = false if team.name == "Washington Football Team"
                team.active = false if team.name == "Washington Redskins"
                team.active = false if team.name == "San Diego Chargers"
                team.active = false if team.name == "Oakland Raiders"
            end
            # Output team saved
            puts "🏈 #{team.conference} | #{team.division} | #{team.name} Saved" if team.active
        end
    end
end
