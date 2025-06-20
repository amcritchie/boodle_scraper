module SportRadarConcern
  extend ActiveSupport::Concern

  # Class variables for play processing
  @@play                   = nil
  @@result_slug_max_length = 30
  @@sport_radar_event      = {}
  @@detail1                = {}
  @@detail2                = {}
  @@detail3                = {}
  @@detail4                = {}
  @@detaillast             = {}
  @@down                   = "〰️"
  @@period                 = "❓"
  @@turnover               = false
  @@scoring_play           = false
  @@play_type              = 'unknown'
  @@event_type             = 'unknown'
  @@sequence               = 999
  @@no_play                = false

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
      response = self.fetch_sport_radar_pbp
      # Print game info
      puts "Game | #{self.slug} | #{self.away_team.emoji} @ #{self.home_team.emoji}"
      # Check if response is successful
      if response.success?
        # Parse response
        json_data = JSON.parse(response.body)
        # Each Through Periods
        json_data['periods'].each do |period_json|
          # Get period emoji
          period_emoji = self.initialize_period(period_json)
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
              self.process_event_sport_radar(drive, self.week, period_emoji)
            elsif drive['type'] == "play"
              self.process_event_sport_radar(drive, self.week, period_emoji)
            else
              drive['events'].each do |event|
                # Process event
                self.process_event_sport_radar(event, self.week, period_emoji)
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
    # Get plays
    plays = self.plays.order(sport_radar_sequence: :asc)
    plays.each do |play|
        # Process play
        process_event_sport_radar(play.sport_radar_event, play.week_slug, play.period)
    end
  end

  def process_event_sport_radar(event_json, week, period_emoji="❓")
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
    if ['period_end','tv_timeout','timeout','two_minute_warning','game_over'].include?(@@event_type)
      result = @@event_type
      puts "#{@@event_type} | ".rjust(@@result_slug_max_length + 52).bold

      if @event_type == 'game_over'
        puts "Game Over"
        puts "Home Total: #{self.home_total}"
        puts "Away Total: #{self.away_total}"
        sleep(5)
      end
      return result
    end
    
    if @@sport_radar_event['deleted'] == true
      puts "Deleted Event | ".rjust(@@result_slug_max_length + 52)
      return result
    end

    # Set Variables
    @@play_type = @@sport_radar_event['play_type']       # pass
    @@stat1     = @@sport_radar_event["statistics"].first   rescue {"category": nil}
    @@stat2     = @@sport_radar_event["statistics"].second  rescue {"category": nil}
    @@stat3     = @@sport_radar_event["statistics"].third   rescue {"category": nil}
    @@stat4     = @@sport_radar_event["statistics"].fourth  rescue {"category": nil}
    
    @@details   = @@sport_radar_event["details"]  rescue []
    @@detail1   = @@details.first   rescue {"category": nil}
    @@detail2   = @@details.second  rescue {"category": nil}
    @@detail3   = @@details.third   rescue {"category": nil}
    @@detail4   = @@details.fourth  rescue {"category": nil}
    @@detaillast = @@details.last  rescue {"category": nil}
    @@period    = period_emoji
    @@turnover  = false
    @@no_play   = (@@detaillast["category"] == "no_play")
    @@scoring_play   = @@sport_radar_event['scoring_play']
    
    # Set score
    @@score = nil
    if @@scoring_play && @@details
      @@score = @@details.find { |detail| detail["result"] == "touchdown" }
      @@score = @@details.find { |detail| detail["result"] == "safety" } unless @@score.present?
    end

    if @@no_play
      puts "no-play | ".rjust(@@result_slug_max_length + 52).bold
      return result
    end

    # Set turnover
    start_situation = @@sport_radar_event['start_situation']
    end_situation   = @@sport_radar_event['end_situation']
    start_team      = Team.find_by(sportsradar_id: start_situation['possession']['id']) rescue nil
    end_team        = Team.find_by(sportsradar_id: end_situation['possession']['id']) rescue nil
    @@turnover       = (start_team.slug != end_team.slug)
    
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
    offense_team = start_team
    if offense_team == the_home_team
      defence_team = the_away_team
    else
      defence_team = the_home_team
    end

    @@play.play_type                  = @@play_type
    @@play.down                       = @@down
    @@play.period                     = @@period
    @@play.turnover                   = @@turnover
    @@play.possession_start_team_slug = start_team.slug
    @@play.possession_end_team_slug   = end_team.slug
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
    @@play.possession_start_team_slug = start_team.slug if start_team.present?
    @@play.possession_end_team_slug   = end_team.slug if end_team.present?
    @@play.category                   = @@sport_radar_event["category"]
    @@play.description                = @@sport_radar_event["description"]
    @@play.result                     = result
    @@play.save!
    
    # Save results to events array
    self.events_array << result
    self.save!

    # Format play result
    result_puts = result.rjust(@@result_slug_max_length)
    result_puts = result_puts.light_green     if result == "rushing-touchdown"
    result_puts = result_puts.light_green     if result == "passing-touchdown"
    result_puts = result_puts.light_green     if result == "kickoff-touchdown"
    result_puts = result_puts.light_green     if result == "punt-return-touchdown"
    result_puts = result_puts.on_green        if result == "defensive-touchdown"
    result_puts = result_puts.on_green        if result == "special-teams-touchdown"
    result_puts = result_puts.green           if result == "successful-extra-point"
    result_puts = result_puts.light_blue      if result == "successful-field-goal"
    result_puts = result_puts.on_red          if result == "failed-field-goal" || result == "failed-extra-point"
    result_puts = result_puts.blue.on_yellow  if result == "weird-field-goal" || result == "weird-extra-point"
    result_puts = result_puts.on_red          if result == "failed-two-point-conversion"
    result_puts = result_puts.on_red          if result == "failed-extra-point"
    result_puts = result_puts.on_yellow       if result == "penalty"

    # Result of events
    begin
      puts  "#{@@period}  | #{clock.to_s.rjust(5)} > #{end_clock.to_s.rjust(5)}| #{offense_team.emoji} > #{defence_team.emoji} | #{@@down} | #{@@play_type.rjust(11)} | #{result_puts} | #{description.truncate(130).rjust(130)}"
    rescue => e
      puts "margot - Event Error 2"
      puts "Error: #{e}"
      e.backtrace.each{ |line| puts line }
      puts "--------------------------------"
      ap event_json
      ap event_json['start_situation']
    end
  end

  def long_strange_event(result_slug)
    puts "mason - strange event - #{result_slug}"
    ap @@sport_radar_event
    # Save special teams touchdown if not another event
    self.stangest_events << @@sport_radar_event
    self.save! 
  end

  def process_conversion
    if @@scoring_play
      result_slug = "two-point-conversion"
      week.increment!(:two_point_conversions)
      # Save special teams touchdown if not another event
      self.stangest_events << @@sport_radar_event
      self.save!                       
    else  
      result_slug = "failed-two-point-conversion"
      self.stangest_events << @@sport_radar_event
      self.save!
    end
    return result_slug
  end

  def process_extra_point
    if @@detail1["category"] == "extra_point_attempt"
      if @@detail1["result"] == "good"
        result_slug = "successful-extra-point"
        week.increment!(:extra_points)
      elsif @@detail1["result"] == "no good"
        result_slug = "failed-extra-point"
      else
        result_slug = "weird-field-goal"
        long_strange_event(result_slug)
      end
    else
      # Weird
      result_slug = "weird-field-goal"
      long_strange_event(result_slug)
    end
    return result_slug
  end

  def process_field_goal
    if @@detail1["category"] == "field_goal"
      if @@detail1["result"] == "good"
        result_slug = "successful-field-goal"
        week.increment!(:field_goals)
      elsif @@detail1["result"] == "no good"
        result_slug = "failed-field-goal"
      else
        result_slug = "weird-field-goal"
        long_strange_event(result_slug)
      end
    else
      # Weird
      result_slug = "weird-field-goal"
      long_strange_event(result_slug)
    end
    return result_slug
  end

  def process_pass
    if @@scoring_play
      if @@turnover
        result_slug = "defensive-touchdown"
        week.increment!(:defensive_touchdowns)
        long_strange_event(result_slug)
      else
        result_slug = "passing-touchdown"
        week.increment!(:passing_touchdowns)
        long_strange_event(result_slug) if rand(1..100) == 1
      end
    else
      result_slug = "pass"
      long_strange_event(result_slug) if rand(1..1000) == 1
    end
    return result_slug
  end

  def process_rush
    if @@scoring_play
      if @@turnover
        result_slug = "defensive-touchdown"
        week.increment!(:defensive_touchdowns)
        long_strange_event(result_slug)
      else
        result_slug = "rushing-touchdown"
        week.increment!(:rushing_touchdowns)
        long_strange_event(result_slug) if rand(1..60) == 1
      end
    else
      result_slug = "rush"
    end
    return result_slug
  end

  def process_punt
    result_slug = "weird-punt"
    if @@detail1["category"] == "punt"
      if @@detail1["result"] == "returned"
        if @@detail1["touchdown"] == 1
          week.increment!(:special_teams_touchdowns)
          result_slug = "punt-return-touchdown"
        else
          result_slug = "punt"
        end
      elsif @@detail1["result"] == "downed"
        result_slug = "punt"
      elsif @@detail1["result"] == "fair catch"
        result_slug = "punt"
      elsif @@detail1["result"] == "touchback"
        result_slug = "punt"
      elsif @@detail1["result"] == "blocked" || @@detail1["result"] == "muffed"
        if @@turnover
          if @@scoring_play
            result_slug = "defensive-touchdown"
            week.increment!(:defensive_touchdowns)
          else
            # Punt turnover
            result_slug = "punt"
          end
        else
          # Recovered Punt
          result_slug = "punt"
        end
        long_strange_event(result_slug)
      else
        if @@detail1["result"] == "out_of_bounds"
          result_slug = "punt"
        else
          result_slug = "weird-punt"
          long_strange_event(result_slug)
        end
      end
    elsif @@detail1["category"] == "aborted_snap"
      result_slug = "aborted-snap"
      # TODO: Check for touchdown
    else
      result_slug = "weird-punt"
      long_strange_event(result_slug)
    end
    return result_slug
  end

  def process_kickoff
    result_slug = "weird-kickoff"
    if @@detail1["category"] == "kick_off"
      if @@detail2["category"] == "kick_off_return"
        if @@detail2["touchdown"] == 1
          week.increment!(:special_teams_touchdowns)
          result_slug = "kickoff-touchdown"
          long_strange_event(result_slug)
        else
          result_slug = "kickoff"
        end
      elsif @@detail2["category"] == "touchback"
        result_slug = "kickoff"
      elsif @@detail2["category"] == "out_of_bounds"
        result_slug = "kickoff"
      else
        result_slug = "weird-kickoff"
        long_strange_event(result_slug)
      end
    else
      result_slug = "weird-kickoff"
      long_strange_event(result_slug)
    end
    return result_slug
  end

  def initialize_period(period_json)
    period_type     = period_json['period_type']
    period_number   = period_json['number']      
    period_sequence = period_json['sequence']
    period_id       = period_json['id']
    
    # Period Data
    period_emoji = case period_number
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

    puts "#{period_emoji}  | New Period | #{period_type}-#{period_number}-#{period_sequence} | #{period_id}"
    puts "--------------------------------"
    return period_emoji
  end

  def fetch_sport_radar_pbp
    access_level  = "trial"
    language_code = "en"
    game_id       = self.sportsradar_id
    format        = "json"
    url_string    = "https://api.sportradar.com/nfl/official/#{access_level}/v7/#{language_code}/games/#{game_id}/pbp.#{format}"

    # api_key = 'dBqzgfZiBp0sTpz06FIx3AjcLzCA2EzwFID6ZCl0' # amcr
    # api_key = 'xtsJqdNDRcvoGeXZ5kcG7iVYVJkpX4umc8bxIoGh' # free@b
    # api_key = 'HmAyXEUSsvWllyEVSCaniv3cnq8cLxKExAr2oAQD' # laurenalexm@g
    api_key = 'c9IaDr6BFd7tSrQdEDbtIclRe6gqHexujsLdevJw' # alex@boodle
    
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