module PositionConcern
  extend ActiveSupport::Concern

  class_methods do
    def pff_starter_position(position)
        case position
        when "QB"
          "quarterback"
        when "RB"
          "running-back"
        when "WR"
          "wide-receiver"
        when "TE"
          "tight-end"
        when "LT"
          "left-tackle"
        when "RT"
          "right-tackle"
        when "C"
          "center"
        when "LG"
          "left-gaurd"
        when "RG"
          "right-gaurd"
        when "DI"
          "defensive-end"
        when "Edge"
          "edge-rusher"
        when "LB"
          "linebacker"
        when "S"
          "safety"
        when "CB"
          "cornerback"
        else
          "place-kicker"
        end
    end

    def pff_starter_position_normalize_oline(position)
      case position
      when "quarterback"
        "quarterback"
      when "running-back"
        "running-back"
      when "wide-receiver"
        "wide-receiver"
      when "tight-end"
        "tight-end"
      when "left-tackle"
        "tackle"
      when "right-tackle"
        "tackle"
      when "center"
        "center"
      when "left-gaurd"
        "gaurd"
      when "right-gaurd"
        "gaurd"
      when "defensive-end"
        "defensive-end"
      when "edge-rusher"
        "edge-rusher"
      when "linebacker"
        "linebacker"
      when "safety"
        "safety"
      when "cornerback"
        "cornerback"
      else
        "place-kicker"
      end
    end

    def position_class(position)
      case position
      when "quarterback"
        :quarterback
      when 'running-back'
        :skill
      when 'wide-receiver'
        :skill
      when 'tight-end'
        :skill
      when 'full-back'
        :skill
      when "center"
        :oline
      when "gaurd"
        :oline
      when "tackle"
        :oline
      when "defensive-end"
        :dline
      when "edge-rusher"
        :dline
      when "linebacker"
        :linebacker
      when "safety"
        :secondary
      when "cornerback"
        :secondary
      else
        :special_teams
      end
    end

    def position_classs(position)
      case position
      when "quarterback"
        :quarterback
      when 'running-back'
        :skill
      when 'wide-receiver'
        :skill
      when 'tight-end'
        :skill
      when 'full-back'
        :skill
      when "center"
        :oline
      when "gaurd"
        :oline
      when "tackle"
        :oline
      when "defensive-end"
        :dline
      when "edge-rusher"
        :dline
      when "linebacker"
        :linebacker
      when "safety"
        :secondary
      when "cornerback"
        :secondary
      else
        :special_teams
      end
    end

    def sportsradar_position(position)
      case position
      when "QB"
        "quarterback"
      when "RB"
        "running-back"
      when "HB"
        "running-back"
      when "FB"
        "full-back"
      when "WR"
        "wide-receiver"
      when "TE"
        "tight-end"
      when "C"
        "center"
      when "OG"
        "gaurd"
      when "G"
        "gaurd"
      when "OL"
        "gaurd"
      when "T"
        "tackle"
      when "OT"
        "tackle"
      when "NT" # T'Vondre Sweat
        "defensive-end"
      when "DT" # Fabien Lovett Sr.
        "defensive-end"
      when "DL"
        "defensive-end"
      when "DE"
        "defensive-end"
      when "DI"
        "defensive-end"
      when "EDGE"
        "edge-rusher"
      when "OLB"
        "linebacker"
      when "LB"
        "linebacker"
      when "MLB"
        "linebacker"
      when "FS"
        "safety"
      when "SAF"
        "safety"
      when "DB"  # In some cases like kevin-byard-iii
        "safety"
      when "CB"
        "cornerback"
      when "P"
        "punter"
      when "K"
        "place-kicker"
      when "LS" # Long snapper
        "long-snapper"
      else
        "place-kicker"
      end
    end

    def pff_position(position)
      case position
      when "QB"
        "quarterback"
      when "HB"
        "running-back"
      when "FB"
        "full-back"
      when "WR"
        "wide-receiver"
      when "TE"
        "tight-end"
      when "C"
        "center"
      when "G"
        "gaurd"
      when "OL"
        "gaurd"
      when "T"
        "tackle"
      when "DL"
        "defensive-end"
      when "DE"
        "defensive-end"
      when "DI"
        "defensive-end"
      when "ED"
        "edge-rusher"
      when "EDGE"
        "edge-rusher"
      when "OLB"
        "linebacker"
      when "LB"
        "linebacker"
      when "S"
        "safety"
      when "CB"
        "cornerback"
      else
        "place-kicker"
      end
    end
  end
end 