class Float
  def football_round
    # Rare football numbers that should be avoided
    rare_numbers = [11, 12, 15, 18, 25, 29]
    
    # Standard football rounding: round down for values below 0.5, round up for 0.5 and above
    standard_rounded = if self % 1 < 0.5
      self.floor
    else
      self.ceil
    end
    
    # If the standard rounding results in a rare number, adjust the rounding
    if rare_numbers.include?(standard_rounded)
      # For rare numbers, be more aggressive about avoiding them
      if self % 1 < 0.3
        # Round down more aggressively (below 0.3)
        self.floor
      elsif self % 1 > 0.7
        # Round up more aggressively (above 0.7)
        self.ceil
      else
        # In the middle range, round away from the rare number
        if standard_rounded > self
          # We rounded up to a rare number, try rounding down instead
          self.floor
        else
          # We rounded down to a rare number, try rounding up instead
          self.ceil
        end
      end
    else
      # Use standard football rounding for non-rare numbers
      standard_rounded
    end
  end

  def score_emojis
    # Convert score to integer for emoji calculation
    # score = self.to_i
    
    # Hardcoded score emoji mappings
    case self.football_round
    when 0..2
      "🙏"
    when 2..3
      "🦶"
    when 3..4
      "🙏🙏"
    when 4..5
      "🦶 🙏"
    when 5..6
      "🦶🦶"
    when 6..7
      "🏉"
    when 7..9
      "🦶🦶🦶"
    when 9..10
      "🏉 🦶"
    when 10..12
      "🦶🦶🦶🦶"
    when 12..13
      "🏉 🦶🦶"
    when 13..14
      "🏉🏉"
    when 14..15
      "🦶🦶🦶🦶🦶"
    when 15..16
      "🏉 🦶🦶🦶"
    when 16..17
      "🏉🏉 🦶"
    when 17..19
      "🏉 🦶🦶🦶🦶"
    when 19..20
      "🏉🏉 🦶🦶"
    when 20..21
      "🏉🏉🏉"
    when 21..23
      "🏉🏉 🦶🦶🦶"
    when 23..24
      "🏉🏉🏉 🦶"
    when 24..26
      "🏉🏉 🦶🦶🦶🦶"
    when 26..27
      "🏉🏉🏉 🦶🦶"
    when 27..28
      "🏉🏉🏉🏉"
    when 28..30
      "🏉🏉🏉 🦶🦶🦶"
    when 30..31
      "🏉🏉🏉🏉 🦶"
    when 31..32
      "🏉🏉🏉🏉 🦶🦶"
    when 32..34
      "🏉🏉🏉 🦶🦶🦶🦶"
    when 34..35
      "🏉🏉🏉🏉🏉"
    when 35..36
      "🏉🏉🏉 🦶🦶🦶🦶🦶"
    when 36..37
      "🏉🏉🏉🏉 🦶🦶🦶"
    when 37..38
      "🏉🏉🏉🏉🏉 🦶"
    when 38..39
      "🏉🏉🏉 🦶🦶🦶🦶🦶🦶"
    when 39..40
      "🏉🏉🏉🏉 🦶🦶🦶🦶"
    when 40..41
      "🏉🏉🏉🏉🏉 🦶🦶"
    when 41..42
      "🏉🏉🏉🏉🏉🏉"
    when 42..43
      "🏉🏉🏉🏉 🦶🦶🦶🦶🦶"
    when 43..44
      "🏉🏉🏉🏉🏉 🦶🦶🦶"
    when 44..45
      "🏉🏉🏉🏉🏉🏉 🦶"
    when 45..46
      "🏉🏉🏉🏉 🦶🦶🦶🦶🦶🦶"
    when 46..47
      "🏉🏉🏉🏉🏉 🦶🦶🦶🦶"
    when 47..48
      "🏉🏉🏉🏉🏉🏉🦶🦶"
    when 48..49
      "🏉🏉🏉🏉🏉🏉🏉"
    when 49..50
      "🏉🏉🏉🏉🏉🦶🦶🦶🦶🦶"
    when 50..51
      "🏉🏉🏉🏉🏉🏉🦶🦶🦶"
    when 51..52
      "🏉🏉🏉🏉🏉🏉🏉🦶"
    when 52..53
      "🏉🏉🏉🏉🏉🦶🦶🦶🦶🦶🦶"
    when 53..54
      "🏉🏉🏉🏉🏉🏉🦶🦶🦶🦶"
    when 54..55
      "🏉🏉🏉🏉🏉🏉🏉🦶🦶"
    when 55..56
      "🏉🏉🏉🏉🏉🦶🦶🦶🦶🦶🦶🦶"
    when 56..57
      "🏉🏉🏉🏉🏉🏉🦶🦶🦶🦶🦶"
    when 57..58
      "🏉🏉🏉🏉🏉🏉🏉🦶🦶🦶"
    when 58..59
      "🏉🏉🏉🏉🏉🏉🏉🏉🦶"
    else
      # Default case - you can add more specific mappings here
      "📈"
    end
  end
end
