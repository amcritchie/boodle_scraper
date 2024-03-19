class Team < ApplicationRecord
    
    def self.active
        where(active: true)
    end
    def self.afc
        where(conference: :afc)
    end
    def self.nfc
        where(conference: :nfc)
    end

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
                team.active = false if team.name == "Los Angeles Raiders"
                team.active = false if team.name == "Oakland Raiders"
            end
            # Output team saved
            puts "🏈 #{team.conference} | #{team.division} | (#{team.slug}) #{team.name} Saved" if team.active
        end
    end

    # Map team id for sportsoddshistory
    def self.sportsoddshistory_team_name_map(team_name)
        case team_name
        when "Buffalo Bills"              # AFC East
          :BUF
        when "New York Jets"
          :NYJ
        when "Miami Dolphins"
          :MIA
        when "New England Patriots"
          :NE
        when "Kansas City Chiefs"       # AFC West
          :KC
        when "Denver Broncos"
          :DEN
        when "Los Angeles Chargers"
          :LAC
        when "Las Vegas Raiders"
          :LV
        when "Cincinnati Bengals"       # AFC North
          :CIN
        when "Baltimore Ravens"
          :BAL
        when "Pittsburgh Steelers"
          :PIT
        when "Cleveland Browns"
          :CLE
        when "Jacksonville Jaguars"     # AFC South
          :JAX
        when "Houston Texans"
          :HOU
        when "Tennessee Titans"
          :TEN
        when "Indianapolis Colts"
          :IND
        when "Green Bay Packers"        # NFC North
          :GB
        when "Minnesota Vikings"
          :MIN
        when "Chicago Bears"
          :CHI
        when "Detroit Lions"
          :DET
        when "Dallas Cowboys"           # NFC EAST
          :DAL
        when "New York Giants"
          :NYG
        when "Philadelphia Eagles"
          :PHI
        when "Washington Commanders"
          :WAS
        when "Seattle Seahawks"         # NFC West
          :SEA
        when "Los Angeles Rams"
          :LAR
        when "San Francisco 49ers"
          :SF
        when "Arizona Cardinals"
          :ARI
        when "Atlanta Falcons"          # NFC South
          :ATL
        when "Carolina Panthers"
          :CAR
        when "Tampa Bay Buccaneers"
          :TB
        when "New Orleans Saints"
          :NO
        else
          :unknown
        end
    end
end
