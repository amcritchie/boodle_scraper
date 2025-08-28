class String
  def skill_test
    return "Hello"
  end

  def skill_icon
    puts "=============="
    puts self
    case self
    when "A"
      "🦈"
    when "B"
      "🐠"
    when "C"
      "🦀"
    when "D"
      "🦐"
    else
      "🦐"
    end
  end

  def venue_slugify
    downcase
    .gsub(' ', '-')
  end

  def player_slugify
    downcase
    .gsub('.', '')
    .gsub("'", "")
    .gsub('’', '')  # secondary-ji’ayir-brown
    .gsub('.sr', '') # skill-aaron-jones-sr
    .gsub('.jr', '')
    .gsub('.ii', '')
    .gsub('.iii', '')
    .gsub('.iv', '')
    .gsub(' sr', '') # skill-aaron-jones-sr
    .gsub(' jr', '')
    .gsub(' ii', '')
    .gsub(' iii', '')
    .gsub(' iv', '')
    .strip  # Remove leading and trailing spaces
    .gsub('   ', '-') 
    .gsub('  ', '-')
    .gsub(' ', '-')
  end
end