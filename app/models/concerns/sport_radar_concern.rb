module SportRadarConcern
  extend ActiveSupport::Concern

  # Class variables for play processing
  @@play                   = nil
  @@result_slug_max_length = 30
  @@result_slug_max_short  = @@result_slug_max_length + 56
  @@sport_radar_event      = {}
  @@detail1                = {}
  @@detail2                = {}
  @@detaillast             = {}
  @@down                   = "〰️"
  @@period                 = "❓"
  @@turnover               = false
  @@scoring_play           = false
  @@play_type              = 'unknown'
  @@event_type             = 'unknown'
  @@sequence               = 999
  @@no_play                = false
  @@touchdown              = false
  @@safety                 = false
  @@extra_point            = false
  @@start_team             = nil
  @@end_team               = nil

  # Class methods
  class_methods do
    
    def sportsradar_import(game_uuid="abc-123-def-456")
      superbowl_json = "lib/sportradar/2024-game-superbowl-play-by-play.json"
      json_data = JSON.parse(File.read(Rails.root.join(superbowl_json)))

      json_data['periods'].each do |period|
        puts "================================="
        puts "🪙 #{period['number']} Quarter"

        period['pbp'].each do |drive|
          puts "================================="
          puts "🚙 Drive | #{drive['start_clock']}"

          if drive['events'].nil?
            puts "No events for drive"
            next
          end

          drive['events'].each do |play|
            if play['play_type'] == "kickoff"
              type = "🦶 Kickoff"
            elsif play['play_type'] == "rush"
              type = "🏃🏻 Rush"
            elsif play['play_type'] == "pass"
              type = "🏈 Pass"
            elsif play['play_type'] == "field_goal"
              type = "🎯 Field Goal"
            elsif play['play_type'] == "extra_point"
              type = "🏆 Extra Point"
            elsif play['play_type'] == "conversion"
              type = "🏆 Two Point Conversion"
            else
              type = "🔴 Unknown"
            end

            puts "%-30s | %-10s | %-50s" % [type, play['play_type'], play['description']]
          end
        end
      end

      "Done"
    end
  end

  # Instance methods
  def sport_radar_play_by_play_seed
    if self.plays.count > 150
        puts "Reprocessing cached plays"
        self.reprocess_plays
    else
        puts "Fetching plays from SportRadar API"
        self.sport_radar_play_by_play
    end
  end

  def sport_radar_play_by_play
      # Get play by play from SportRadar
      response = self.fetch_sport_radar_pbp rescue 'tcp-crash'

      if response == 'tcp-crash'
        ap self 
        puts "TCP Crash - Retrying"
        sleep(10)
        response = self.fetch_sport_radar_pbp rescue 'tcp-crash'
        puts "TCP Crash - Retrying"
        return "tcp-crash" if response == 'tcp-crash'
      end

      # Print game info
      puts "Game | #{self.slug} | #{self.away_team.emoji} @ #{self.home_team.emoji}"
      ap response
      # Check if response is successful
      if response.success?
        # Parse response
        json_data = JSON.parse(response.body)

        if json_data['status'] == "postponed"
          puts "Game Postponed"
          return "postponed"
        end

        # Each Through Periods
        json_data['periods'].each do |period_json|
          # Get period emoji
          self.initialize_period(period_json)
          # Each Through Drives
          period_json['pbp'].each do |drive|
            # Pull data
            deleted       = drive['deleted']
            event_type    = drive['event_type']
            type          = drive['type']             # drive | play (extra point after def touchdown)
            sequence      = drive['sequence']         # 16
            team_sequence = drive['team_sequence']    # 8
            start_reason  = drive['start_reason']     # Punt
            end_reason    = drive['end_reason']       # Touchdown
            id            = drive['id']               # 1234567890
            duration      = drive['duration']         # 3:50
            first_downs   = drive['first_downs']      # 3
            gain          = drive['gain']             # 90
            penalty_yards = drive['penalty_yards']    # -10
            scoring_drive = drive['scoring_drive']    # true
            start_clock   = drive['start_clock']      # 3:37
            end_clock     = drive['end_clock']        # 14:47
            
            # Is drive a play or set of events
            if drive['type'] == "event"
              self.process_event_sport_radar(drive)
            elsif drive['type'] == "play"
              self.process_event_sport_radar(drive)
            else
              drive['events'].each do |event|
                # Process event
                self.process_event_sport_radar(event)
                # Sleep timer
                sleep(0.1)
                # Error During Event
                rescue => e
                  puts "margot - Event Error"
                  puts "Error: #{e}"
                  e.backtrace.each{ |line| puts line }
                  puts "--------------------------------"
                  puts "Event"
                  puts "--------------------------------"
                  ap event
                  puts "--------------------------------"
                  sleep(5)
              end
            end
            # Error During Drive
          rescue => e
            puts "margot - Drive Error"
            puts "Error: #{e}"
            e.backtrace.each{ |line| puts line }
            puts "--------------------------------"
            puts "Drive"
            puts "--------------------------------"
            ap drive
            puts "--------------------------------"
            sleep(5)
          end
        # Error During Period
        rescue => e
          puts "margot - Period Error"
          puts "Error: #{e}"
          e.backtrace.each{ |line| puts line }
          puts "--------------------------------"
          puts "Period"
          puts "--------------------------------"
          ap period_json
          puts "--------------------------------"
          sleep(5)
        end  
      else
        puts "margot - Response Error"
        puts "Response: #{response.code}"
        puts "Response: #{response.body}"
        ap response
        puts "--------------------------------"
        sleep(30)
      end
  end

  def reprocess_plays
    self.home_passing_touchdowns = 0
    self.away_passing_touchdowns = 0
    self.home_rushing_touchdowns = 0
    self.away_rushing_touchdowns = 0
    self.home_field_goals = 0
    self.away_field_goals = 0
    self.events_array = []
    self.save!
    # Get plays
    plays = self.plays.order(sport_radar_sequence: :asc)
    plays.each do |play|
        # Update period if it changed
        if play.period != @@period
            @@period = play.period
        end
        # Process play
        process_event_sport_radar(play.sport_radar_event)
    end
  end

  def process_event_sport_radar(event_json)
    # Set event type
    result              = "weird-event"
    @@sport_radar_event = event_json
    @@event_type        = event_json['event_type'] || event_json['type']
    @@sequence          = event_json['sequence']
    
    # Find or create play
    @@play = self.plays.find_or_create_by(
      season_slug: self.season, 
      week_slug: self.week_slug, 
      sportsradar_id: event_json['id'], 
      sport_radar_sequence: @@sequence.to_i, 
      event_type: @@event_type  
    )
    @@play.sport_radar_event = event_json
    @@play.save!
    
    # Skip on non-play events
    if ['period_end','tv_timeout','timeout','two_minute_warning','game_over','setup','comment'].include?(@@event_type)
      result = @@event_type
      puts "#{@@event_type} | ".rjust(@@result_slug_max_short).bold

      if @event_type == 'game_over'
        puts "Game Over"
        puts "Home Total: #{self.home_score}"
        puts "Away Total: #{self.away_score}"
        sleep(5)
      end
      return result
    end
    
    if @@sport_radar_event['deleted'] == true
      puts "Deleted Event | ".rjust(@@result_slug_max_short)
      return result
    end

    # Set Variables
    @@play_type     = @@sport_radar_event['play_type']       # pass    
    @@details       = @@sport_radar_event["details"]    || []
    @@detail1       = @@details.first                   || {}
    @@detail2       = @@details.second                  || {}
    @@detaillast    = @@details.last                    || {}
    @@turnover      = false
    @@no_play       = (@@detaillast["category"] == "no_play")
    @@scoring_play  = @@sport_radar_event['scoring_play']
    @@touchdown     = @@details.find { |detail| detail["result"] == "touchdown" }
    @@safety        = @@details.find { |detail| detail["category"] == "safety" }
    @@field_goal    = @@details.find { |detail| detail["category"] == "field_goal" && detail["result"] == "good" }
    @@extra_point   = @@details.find { |detail| detail["category"] == "extra_point_attempt" && detail["result"] == "good" }
    @@score         = @@touchdown || @@safety || @@field_goal || @@extra_point

    if @@no_play
      puts "no-play | ".rjust(@@result_slug_max_short).bold
      return result
    end

    # Set turnover
    start_situation = @@sport_radar_event['start_situation']
    end_situation   = @@sport_radar_event['end_situation']
    @@start_team    = Team.find_by(sportsradar_id: start_situation['possession']['id']) rescue nil
    @@end_team      = Team.find_by(sportsradar_id: end_situation['possession']['id']) rescue nil
    @@turnover      = (@@start_team.slug != @@end_team.slug)
    
    # Set down emoji
    @@down = "〰️"
    @@down = "☝️ " if (1 == start_situation['down']) rescue "❓"
    @@down = "✌️ " if (2 == start_situation['down']) rescue "❓"
    @@down = "🤟" if (3 == start_situation['down']) rescue "❓"
    @@down = "✊" if (4 == start_situation['down']) rescue "❓"
    if @@down == "❓"
      puts "mason - weird-down"
      ap @@sport_radar_event
    end

    # Fetch data
    clock           = @@sport_radar_event['clock']           # 2:55
    description     = @@sport_radar_event['description']     # L.Jackson pass deep right complete. Catch made by I.Likely for 49 yards. TOUCHDOWN.
    score           = @@sport_radar_event['score']
    statistics      = @@sport_radar_event['statistics']      # 5+ player events
    start_clock     = start_situation['clock'] rescue 'start'
    end_clock       = end_situation['clock'] rescue 'end'
    # Scoring Data
    points          = score['points'] rescue nil # 7
    home_points     = score['home_points'] rescue nil # 20
    away_points     = score['away_points'] rescue nil # 16
    details         = @@sport_radar_event['details']

    # Set teams for print
    offense_team = @@start_team
    if offense_team == the_home_team
      defence_team = the_away_team
    else
      defence_team = the_home_team
    end

    @@play.play_type                  = @@play_type
    @@play.down                       = @@down
    @@play.period                     = @@period
    @@play.turnover                   = @@turnover
    @@play.possession_start_team_slug = @@start_team.slug
    @@play.possession_end_team_slug   = @@end_team.slug
    @@play.clock_start_time           = start_clock
    @@play.clock_end_time             = end_clock
    @@play.save!

    result = process_punt        if @@play_type == "punt"
    result = process_kickoff     if @@play_type == "kickoff"
    result = process_field_goal  if @@play_type == "field_goal"
    result = process_rush        if @@play_type == "rush"
    result = process_pass        if @@play_type == "pass"
    result = process_extra_point if @@play_type == "extra_point"
    result = process_conversion  if @@play_type == "conversion"

    if result == "result_slug"
      puts "🎉 Weird Play"
      ap @@sport_radar_event
      sleep(5)
    end
   
    # Penalty
    if @@play_type == "penalty"
      result = "penalty".rjust(@@result_slug_max_length)
      # What to do about penalties?
    end
    
    # Strange scoring play
    if (points.to_i > 0) && (result == "rush" || result == "pass")
      puts "margot - Strange scoring play"
      self.stangest_events << @@sport_radar_event
      self.save!
      ap event_json
      sleep(5)
    end

    @@play.score                      = @@score
    @@play.possession_start_team_slug = @@start_team.slug if @@start_team.present?
    @@play.possession_end_team_slug   = @@end_team.slug if @@end_team.present?
    @@play.category                   = @@sport_radar_event["category"]
    @@play.description                = @@sport_radar_event["description"]
    @@play.result                     = result
    @@play.save!

    # Save results to events array
    self.events_array << result
    self.save!

    # Format play result
    result_puts = result.rjust(@@result_slug_max_length)
    # Reload
    week.reload

    running_count = ""
    if result == "rushing-touchdown"
        result_puts = result_puts.light_green
        running_count = week.rushing_touchdowns.to_i
    end
    if result == "passing-touchdown"
        result_puts = result_puts.light_green
        running_count = week.passing_touchdowns.to_i
    end
    if result == "field-goal"
        result_puts = result_puts.light_green
        running_count = week.field_goals.to_i
    end
    if result == "extra-point"
        result_puts = result_puts.green
        running_count = week.extra_points.to_i
    end
    if result == "two-point-conversion"
        result_puts = result_puts.on_green
        running_count = week.two_point_conversions.to_i
    end
    if result == "defensive-touchdown"
        result_puts = result_puts.on_green
        running_count = week.defensive_touchdowns.to_i
    end
    if result == "safety"
        result_puts = result_puts.on_green
        running_count = week.safeties.to_i
    end
    if result == "special-teams-touchdown" || result == "kickoff-touchdown" || result == "punt-return-touchdown" || result == "punt-recovery-touchdown"
        result_puts = result_puts.on_green
        running_count = week.special_teams_touchdowns.to_i
    end
    # result_puts = result_puts.light_green     if result == "rushing-touchdown"
    # result_puts = result_puts.light_green     if result == "passing-touchdown"
    # result_puts = result_puts.on_green        if result == "safety"
    result_puts = result_puts.on_blue        if result == "defensive-conversion"
    result_puts = result_puts.green           if result == "successful-extra-point"
    result_puts = result_puts.light_blue      if result == "field-goal"
    result_puts = result_puts.on_red          if result == "failed-field-goal" || result == "failed-extra-point"
    result_puts = result_puts.blue.on_yellow  if result == "weird-field-goal" || result == "weird-extra-point"
    result_puts = result_puts.on_red          if result == "failed-two-point-conversion"
    result_puts = result_puts.on_red          if result == "failed-extra-point"
    result_puts = result_puts.on_red          if result == "blocked-field-goal"
    result_puts = result_puts.on_yellow       if result == "penalty"

    # Result of events
    
    puts  "#{@@period}  | #{clock.to_s.rjust(5)} > #{end_clock.to_s.rjust(5)}| #{offense_team.emoji} > #{defence_team.emoji} | #{@@down} | #{@@play_type.rjust(11)} | #{result_puts} #{running_count.to_s.rjust(3)} | Play.find(#{@@play.id}) #{description.truncate(130).rjust(130)}"
  rescue => e
    puts "margot - Event Error"
    puts "Error: #{e}"
    e.backtrace.each{ |line| puts line }
    puts "--------------------------------"
    puts "Event"
    puts "--------------------------------"
    ap @@sport_radar_event
    puts "--------------------------------"
    sleep(5)
  end

  def log_strange_event(result_slug)
    puts "mason - strange event - #{result_slug}"
    ap @@sport_radar_event
    # Save special teams touchdown if not another event
    self.stangest_events << @@sport_radar_event
    self.save! 
  end

  def process_conversion
    if @@scoring_play
        if @@turnover
            result_slug = "defensive-conversion"
            self.increment!(:alt_points)
            log_strange_event(result_slug)
        else
            result_slug = "two-point-conversion"
            self.increment!(:alt_points)
            week.increment!(:two_point_conversions)
        end
    else  
      result_slug = "failed-two-point-conversion"
    end
    return result_slug
  end

  def process_extra_point
    if @@scoring_play
        if @@extra_point
            result_slug = "extra-point"
            if self.home_team.slug == @@end_team.slug
              self.increment!(:home_extra_points)
            else
              self.increment!(:away_extra_points)
            end       
              
            week.increment!(:extra_points)
        elsif @@turnover
            result_slug = "defensive-conversion"
            self.increment!(:alt_points)
            log_strange_event(result_slug)
        else
            result_slug = "two-point-conversion"
            self.increment!(:alt_points)
            week.increment!(:two_point_conversions)
        end
    else
        result_slug = "failed-extra-point"
    end
    return result_slug
  end

  def process_field_goal
    if @@scoring_play
      if @@field_goal
          result_slug = "field-goal"

          if self.home_team.slug == @@end_team.slug
            self.increment!(:home_field_goals, 3)
          else
            self.increment!(:away_field_goals, 3)
          end

          week.increment!(:field_goals)
      elsif @@touchdown
          if @@turnover
              result_slug = "defensive-touchdown"
              self.increment!(:alt_points, 6)
              week.increment!(:defensive_touchdowns)
          elsif @@safety
              week.increment!(:safeties)
              self.increment!(:alt_points, 2)
              result_slug = "safety"
          else
              result_slug = "passing-touchdown"

              if self.home_team.slug == @@end_team.slug
                self.increment!(:home_passing_touchdowns, 6)
              else
                self.increment!(:away_passing_touchdowns, 6)
              end

              week.increment!(:passing_touchdowns)
          end
      else
          result_slug = "failed-field-goal"
      end
    else
        result_slug = "failed-field-goal"
    end
    return result_slug
  end

  def process_pass
    if @@scoring_play
      if @@turnover
        result_slug = "defensive-touchdown"
        self.increment!(:alt_points, 6)
        week.increment!(:defensive_touchdowns)
      elsif @@safety
        week.increment!(:safeties)
        self.increment!(:alt_points, 2)
        result_slug = "safety"
      else
        result_slug = "passing-touchdown"

        if self.home_team.slug == @@end_team.slug
          self.increment!(:home_passing_touchdowns, 6)
        else
          self.increment!(:away_passing_touchdowns, 6)
        end

        week.increment!(:passing_touchdowns)
      end
    else
      result_slug = "pass"
    end
    return result_slug
  end

  def process_rush
    if @@scoring_play
      if @@turnover
        result_slug = "defensive-touchdown"
        self.increment!(:alt_points, 6)
        week.increment!(:defensive_touchdowns)
      elsif @@safety
        week.increment!(:safeties)
        self.increment!(:alt_points, 2)
        result_slug = "safety"
      else
        result_slug = "rushing-touchdown"

        if self.home_team.slug == @@end_team.slug
          self.increment!(:home_rushing_touchdowns, 6)
        else
          self.increment!(:away_rushing_touchdowns, 6)
        end

        week.increment!(:rushing_touchdowns)
      end
    else
      result_slug = "rush"
    end
    return result_slug
  end

  def process_punt
    if @@scoring_play
      if @@touchdown
          if @@turnover
              week.increment!(:special_teams_touchdowns)
              self.increment!(:alt_points, 6)
              result_slug = "punt-return-touchdown"
          else
              week.increment!(:special_teams_touchdowns)
              self.increment!(:alt_points, 6)
              result_slug = "punt-recovery-touchdown"
          end
      elsif @@safety
          week.increment!(:safeties)
          self.increment!(:alt_points, 2)
          result_slug = "safety"
      else
        result_slug = "punt"
      end
    else
      result_slug = "punt"
    end

  end

  def process_kickoff
    if @@touchdown
        if @@turnover
            week.increment!(:special_teams_touchdowns)
            self.increment!(:alt_points, 6)
            result_slug = "kickoff-touchdown"
        else
            week.increment!(:special_teams_touchdowns)
            self.increment!(:alt_points, 6)
            result_slug = "kicking-team-touchdown"
        end
    elsif @@safety
        week.increment!(:safeties)
        self.increment!(:alt_points, 2)
        result_slug = "safety"
    else
      result_slug = "kickoff"
    end
  end

  def initialize_period(period_json)
    period_type     = period_json['period_type']
    period_number   = period_json['number']      
    period_sequence = period_json['sequence']
    period_id       = period_json['id']
    
    # Period Data
    @@period = case period_number
    when 1 
      "1️⃣"
    when 2 
      "2️⃣"
    when 3 
      "3️⃣"
    when 4 
      "4️⃣"
    else 
      "❓"
    end

    puts "#{@@period}  | New Period | #{period_type}-#{period_number}-#{period_sequence} | #{period_id}"
    puts "--------------------------------"
    # return period_emoji
  end

  def fetch_sport_radar_pbp
    access_level  = ENV.fetch('SPORTRADAR_ACCESS_LEVEL', 'trial')
    base_url      = ENV.fetch('SPORTRADAR_BASE_URL', 'https://api.sportradar.com/nfl/official')
    language_code = "en"
    game_id       = self.sportsradar_id
    format        = "json"
    url_string    = "#{base_url}/#{access_level}/v7/#{language_code}/games/#{game_id}/pbp.#{format}"

    api_key = ENV['SPORTRADAR_API_KEY']
    
    if api_key.blank?
      raise "SPORTRADAR_API_KEY environment variable is required"
    end
    
    # Fetch data from SportRadar API
    response = HTTParty.get(url_string,
        headers: {
          'accept' => 'application/json',
          'x-api-key' => api_key
        }
      )
    return response
  end
end 