class TeamsSeason < ApplicationRecord
  include ScoringConcern
  include RankingConcern
  
  belongs_to :team, primary_key: :slug, foreign_key: :team_slug, optional: true

  validates :team_slug, :season_year, presence: true

  has_many :teams_weeks, ->(team_season) { where(season_year: team_season.season_year) }, primary_key: :team_slug, foreign_key: :team_slug

  # Starting lineup attributes: qb, rb1, rb2, wr1, wr2, wr3, te, c, lt, rt, lg, rg (offense)
  # eg1, eg2, dl1, dl2, dl3, lb1, lb2, cb1, cb2, cb3, s1, s2 (defense)
  # Coach attributes: hc (head coach), oc (offensive coordinator), dc (defensive coordinator)

  # Coach methods
  def head_coach
    Coach.find_by_slug(hc)
  end
  def offensive_coordinator
    Coach.find_by_slug(oc)
  end
  def defensive_coordinator
    Coach.find_by_slug(dc)
  end
  def offensive_play_caller_coach
    Coach.find_by_slug(offensive_play_caller)
  end
  def defensive_play_caller_coach
    Coach.find_by_slug(defensive_play_caller)
  end
  def coaches
    Coach.where(slug: [hc, oc, dc, offensive_play_caller, defensive_play_caller].compact)
  end
  def self.offensive_play_callers
    Coach.where(slug: all.pluck(:offensive_play_caller).flatten.compact)
  end
  def self.defensive_play_callers
    Coach.where(slug: all.pluck(:defensive_play_caller).flatten.compact)
  end

  # Player methods
  def qb_player
    Player.find_by_slug(qb)
  end
  def rb1_player
    Player.find_by_slug(rb1)
  end
  def rb2_player
    Player.find_by_slug(rb2)
  end
  def wr1_player
    Player.find_by_slug(wr1)
  end
  def wr2_player
    Player.find_by_slug(wr2)
  end
  def wr3_player
    Player.find_by_slug(wr3)
  end
  def te_player
    Player.find_by_slug(te)
  end
  def center_player
    Player.find_by_slug(c)
  end
  def left_tackle_player
    Player.find_by_slug(lt)
  end
  def right_tackle_player
    Player.find_by_slug(rt)
  end
  def left_guard_player
    Player.find_by_slug(lg)
  end
  def right_guard_player
    Player.find_by_slug(rg)
  end
  def edge1_player
    Player.find_by_slug(eg1)
  end
  def edge2_player
    Player.find_by_slug(eg2)
  end
  def dl1_player
    Player.find_by_slug(dl1)
  end
  def dl2_player
    Player.find_by_slug(dl2)
  end
  def dl3_player
    Player.find_by_slug(dl3)
  end
  def lb1_player
    Player.find_by_slug(lb1)
  end
  def lb2_player
    Player.find_by_slug(lb2)
  end
  def cb1_player
    Player.find_by_slug(cb1)
  end
  def cb2_player
    Player.find_by_slug(cb2)
  end
  def cb3_player
    Player.find_by_slug(cb3)
  end
  def safety1_player
    Player.find_by_slug(s1)
  end
  def safety2_player
    Player.find_by_slug(s2)
  end


  # Collection methods
  def offense_starters
    Player.where(slug: [qb, rb1, rb2, wr1, wr2, wr3, te, c, lt, rt, lg, rg].compact)
  end
  def defense_starters
    Player.where(slug: [eg1, eg2, dl1, dl2, dl3, lb1, lb2, cb1, cb2, cb3, s1, s2].compact)
  end
  def bench_players
    roster_players = Player.where(team_slug: team_slug)
    starter_slugs = (offense_starters + defense_starters).map(&:slug).compact
    roster_players.where.not(slug: starter_slugs)
  end
  def self.qbs
    Player.where(slug: all.pluck(:qb).flatten.compact)
  end
  def self.receivers
    Player.where(slug: all.pluck(:wr1, :wr2, :wr3, :te).flatten.compact)
  end

  def rushers
    Player.where(slug: [qb, rb1, rb2].compact)
  end
  def receivers
    Player.where(slug: [wr1, wr2, wr3, te].compact)
  end
  def top_three_receivers
    Player.where(slug: receivers.sort_by { |player| -(player.receiving_grade_x || 0) }.first(3).pluck(:slug))
  end
  def oline_players
    slugs = [lt, lg, c, rg, rt].compact
    players = Player.where(slug: slugs)
    # Sort players to match the order of slugs in the original array
    players.sort_by { |player| slugs.index(player.slug) }
  end
  def edge_players
    Player.where(slug: [eg1, eg2].compact)
  end
  def dinterior_players
    Player.where(slug: [dl1, dl2, dl3].compact).sort_by { |player| -(player.rush_defense_grade_x || 0) }
  end
  def dline_players
    Player.where(slug: [eg1, eg2, dl1, dl2, dl3].compact)
  end
  def pass_rush_players
    Player.where(slug: dline_players.sort_by { |player| -(player.pass_rush_grade_x || 0) }.pluck(:slug))
  end
  def linebacker_players
    Player.where(slug: [lb1, lb2].compact).sort_by { |player| -(player.rush_defense_grade_x || 0) }
  end
  def corner_back_players
    Player.where(slug: [cb1, cb2, cb3]).sort_by { |player| -(player.coverage_grade_x || 0) }
  end
  def safety_players
    Player.where(slug: [s1, s2]).sort_by { |player| -(player.coverage_grade_x || 0) }
  end
  def secondary_players
    Player.where(slug: [cb1, cb2, cb3, s1, s2].compact)
  end

  def rushing_players
    # Get all potential rushing players and sort by rushing grade
    potential_rushers = [rb1_player, rb2_player, qb_player].compact
    potential_rushers.sort_by { |player| -(player.rush_grade_x || 0) }.first(2)
  end

  def self.pass_rush_position_weight(position)
    case position
    when 'edge-rusher'
      1.0  # EDGE
    when 'defensive-end'
      0.7  # DT
    when 'linebacker'
      0.4  # LB
    when 'safety', 'cornerback'
      0.2  # CB/S
    else
      0.5  # Default weight for unknown positions
    end
  end
  
  def block_title(block)
    block.at_css(".Table__Title")&.text&.strip.to_s
  end

  def defensive_block?(title)
    tl = title.downcase
    tl.include?(" base") || tl.end_with?(" d") || tl.include?("nickel") || tl.include?("dime")
  end

  def parse_block(block)
    left_tbody  = block.at_css(".Table--fixed-left tbody")
    right_tbody = block.at_css(".Table__Scroller tbody") || block.css(".Table:not(.Table--fixed-left) tbody").first
    return [] unless left_tbody && right_tbody

    lrows = left_tbody.css("tr")
    rrows = right_tbody.css("tr")
    n = [lrows.size, rrows.size].min

    rows = []
    n.times do |i|
      pos = clean_pos(lrows[i].at_css("td"))
      cells = rrows[i].css("td")
      rows << [cell_info(cells, 0),cell_info(cells, 1),cell_info(cells, 2),cell_info(cells, 3)]
    end
    rows
  end

  def clean_pos(td)
    return nil unless td
    span = td.at_css('[data-testid="statCell"]')
    return nil unless span

    # In your HTML, the first text node is the label like "QB"
    # Nokogiri doesn’t expose raw child text nodes as easily; split by spaces as a safe fallback
    txt = span.text.strip
    # txt might be "QB" or "QB O" depending on spacing; take the first token and strip ":" just in case
    txt.split(/\s+/).first.to_s.delete(":")
  end

  def cell_info(cells, idx)
    return { name: nil, injury: "" } if idx >= cells.size
    c = cells[idx]
    name_el = c.at_css("a") || c.at_css('[data-testid="statCell"]')
    name = name_el ? name_el.text.strip : c.text.strip
    injury = c.at_css(".nfl-injuries-status")&.text&.strip.to_s

    name = nil if name == "-" || name.empty?
    { name: name, injury: injury }
  end

  def first_healthy_starter(position_group)
    return nil if position_group.nil? || position_group.empty?
    
    position_group.find do |player|
      player[:name] && player[:injury].blank?
    end
  end

  def espn_starters
    require 'nokogiri'
    require 'httparty'
    
    # ESPN depth chart URL format
    url = "https://www.espn.com/nfl/team/depth/_/name/#{team.slug.downcase}"
    
    begin
      response = HTTParty.get(url, {
        headers: {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
      })
      
      if response.success?
        doc = Nokogiri::HTML(response.body)

        h1 = doc.at_css("h1")
        return nil unless h1
        team_name = h1.text.strip.sub(/ Depth Chart\z/, "")

        # Get the depth blocks
        depth_blocks = doc.css(".nfl-depth-table .ResponsiveTable")

        def defensive_block?(title)
          tl = title.downcase
          tl.include?(" base") || tl.end_with?(" d") || tl.include?("nickel") || tl.include?("dime")
        end

        offense_rows = depth_blocks.reject { |b| block_title(b) =~ /special teams/i }
                                    .reject { |b| defensive_block?(block_title(b)) }
                                    .flat_map { |b| parse_block(b) }

        defense_rows ||= depth_blocks.select { |b| defensive_block?(block_title(b)) }
                                    .flat_map { |b| parse_block(b) }

        special_teams_rows ||= depth_blocks.select { |b| block_title(b) =~ /special teams/i }
                                    .flat_map { |b| parse_block(b) }

        qbs   = offense_rows[0]
        rbs   = offense_rows[1]
        wr1s  = offense_rows[2]
        wr2s  = offense_rows[3]
        wr3s  = offense_rows[4]
        tes   = offense_rows[5]
        if offense_rows.count == 11
          lts   = offense_rows[6]
          lgs   = offense_rows[7]
          cs    = offense_rows[8]
          rgs   = offense_rows[9]
          rts   = offense_rows[10]
        elsif offense_rows.count == 12
          fbs   = offense_rows[6]
          lts   = offense_rows[7]
          lgs   = offense_rows[8]
          cs    = offense_rows[9]
          rgs   = offense_rows[10]
          rts   = offense_rows[11]
        end
        de1s  = defense_rows[0]
        de2s  = defense_rows[1]
        de3s  = defense_rows[2]
        eg1s  = defense_rows[3]
        eg2s  = defense_rows[6]
        lb1s  = defense_rows[4]
        lb2s  = defense_rows[5]
        cb1s  = defense_rows[7]
        cb2s  = defense_rows[10]
        cb3s  = defense_rows[11]
        sf1s  = defense_rows[8]
        sf2s  = defense_rows[9]
        pks   = special_teams_rows[0]


        starting_qb   = nil
        starting_rb1  = nil
        starting_rb2  = nil
        starting_wr1  = nil
        starting_wr2  = nil
        starting_wr3  = nil
        starting_te   = nil
        starting_c    = nil
        starting_lt   = nil
        starting_rt   = nil
        starting_lg   = nil
        starting_rg   = nil
        starting_eg1  = nil
        starting_eg2  = nil
        starting_dl1  = nil
        starting_dl2  = nil
        starting_dl3  = nil
        starting_lb1  = nil
        starting_lb2  = nil
        starting_cb1  = nil
        starting_cb2  = nil
        starting_cb3  = nil
        starting_sf1  = nil
        starting_sf2  = nil
        starting_pk   = nil

        out_injury = ['O', 'D', 'IR', 'SUSP', 'PUP']
        # Starting QB
        qbs.each do |qb|
          next unless player = Player.find_by_player(qb[:name])
          unless out_injury.include?(qb[:injury])
            starting_qb = player
            break
          end
        end
        # Starting RBs
        rbs.each do |rb|
          next unless player = Player.find_by_player(rb[:name])
          unless out_injury.include?(rb[:injury])
            if starting_rb1.nil?
              starting_rb1 = player
              next
            else
              starting_rb2 = player
              break
            end
          end
        end
        # Starting WRs  
        wr1s.each do |wr1|
          next unless player = Player.find_by_player(wr1[:name])
          unless out_injury.include?(wr1[:injury])
            starting_wr1 = player
            break
          end  
        end
        wr2s.each do |wr2|
          next unless player = Player.find_by_player(wr2[:name])
          unless out_injury.include?(wr2[:injury])
            starting_wr2 = player
            break
          end  
        end
        wr3s.each do |wr3|
          next unless player = Player.find_by_player(wr3[:name])
          unless out_injury.include?(wr3[:injury])
            starting_wr3 = player
            break
          end  
        end
        # Starting TEs
        tes.each do |te|
          next unless player = Player.find_by_player(te[:name])
          unless out_injury.include?(te[:injury])
            starting_te = player
            break
          end  
        end
        # Starting C
        cs.each do |c|
          next unless player = Player.find_by_player(c[:name])
          unless out_injury.include?(c[:injury])
            starting_c = player
            break
          end  
        end
        # Starting LTs
        lts.each do |lt|
          next unless player = Player.find_by_player(lt[:name])
          unless out_injury.include?(lt[:injury])
            starting_lt = player
            break
          end
        end
        rts.each do |rt|
          next unless player = Player.find_by_player(rt[:name])
          unless out_injury.include?(rt[:injury])
            starting_rt = player
            break
          end
        end

        # Starting LGs
        lgs.each do |lg|
          next unless player = Player.find_by_player(lg[:name])
          unless out_injury.include?(lg[:injury])
            starting_lg = player
            break
          end
        end
        rgs.each do |rg|
          next unless player = Player.find_by_player(rg[:name])
          unless out_injury.include?(rg[:injury])
            starting_rg = player
            break
          end
        end

        # Starting DEs
        de1s.each do |de1|  
          next unless player = Player.find_by_player(de1[:name])
          unless out_injury.include?(de1[:injury])
            starting_dl1 = player
            break
          end
        end
        de2s.each do |de2|
          next unless player = Player.find_by_player(de2[:name])
          unless out_injury.include?(de2[:injury])
            starting_dl2 = player
            break
          end
        end
        de3s.each do |de3|
          next unless player = Player.find_by_player(de3[:name])
          unless out_injury.include?(de3[:injury])
            starting_dl3 = player
            break
          end
        end
        # Starting EGs
        eg1s.each do |eg1|
          next unless player = Player.find_by_player(eg1[:name])
          unless out_injury.include?(eg1[:injury])
            starting_eg1 = player
            break
          end
        end
        eg2s.each do |eg2|
          next unless player = Player.find_by_player(eg2[:name])
          unless out_injury.include?(eg2[:injury])
            starting_eg2 = player
            break
          end
        end
        # Starting LB
        lb1s.each do |lb1|
          next unless player = Player.find_by_player(lb1[:name])
          unless out_injury.include?(lb1[:injury])
            starting_lb1 = player
            break
          end
        end
        lb2s.each do |lb2|
          next unless player = Player.find_by_player(lb2[:name])
          unless out_injury.include?(lb2[:injury])
            starting_lb2 = player
            break
          end
        end
        # Starting CBs
        cb1s.each do |cb1|
          next unless player = Player.find_by_player(cb1[:name])
          unless out_injury.include?(cb1[:injury])
            starting_cb1 = player
            break
          end
        end
        cb2s.each do |cb2|
          next unless player = Player.find_by_player(cb2[:name])
          unless out_injury.include?(cb2[:injury])
            starting_cb2 = player
            break
          end
        end
        cb3s.each do |cb3|
          next unless player = Player.find_by_player(cb3[:name])
          unless out_injury.include?(cb3[:injury])
            starting_cb3 = player
            break
          end
        end
        # Starting S
        sf1s.each do |sf1|  
          next unless player = Player.find_by_player(sf1[:name])
          unless out_injury.include?(sf1[:injury])
            starting_sf1 = player
            break
          end
        end
        sf2s.each do |sf2|
          next unless player = Player.find_by_player(sf2[:name])
          unless out_injury.include?(sf2[:injury])
            starting_sf2 = player
            break
          end
        end
        # Starting PK
        pks.each do |pk|
          next unless player = Player.find_by_player(pk[:name])
          unless out_injury.include?(pk[:injury])
            starting_pk = player
            break
          end
        end

        # Use TeamsSeason data
        update(
          # Offensive players
          qb:   starting_qb.slug,
          rb1:  starting_rb1.slug,
          rb2:  starting_rb2.slug,
          wr1:  starting_wr1.slug,
          wr2:  starting_wr2.slug,
          wr3:  starting_wr3.slug,
          te:   starting_te.slug,
          c:    starting_c.slug,
          lt:   starting_lt.slug,
          rt:   starting_rt.slug,
          lg:   starting_lg.slug,
          rg:   starting_rg.slug,
          # Defensive players
          eg1:  starting_eg1.slug,
          eg2:  starting_eg2.slug,
          dl1:  starting_dl1.slug,
          dl2:  starting_dl2.slug,
          dl3:  starting_dl3.slug,
          lb1:  starting_lb1.slug,
          lb2:  starting_lb2.slug,
          cb1:  starting_cb1.slug,
          cb2:  starting_cb2.slug,
          cb3:  starting_cb3.slug,
          s1:   starting_sf1.slug,
          s2:   starting_sf2.slug,
          place_kicker:   starting_pk.slug
        )
        # Puts self 
        ap self
      else
        { error: "Failed to fetch depth chart. Status: #{response.code}" }
      end
    rescue => e
      { error: "Error parsing depth chart: #{e.message}" }
    end    
  end
end 