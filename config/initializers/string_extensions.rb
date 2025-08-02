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

  def player_slugify
    downcase
    .gsub(' ', '-')
    .gsub('.', '')
    .gsub("'", "")
    .gsub('’', '')  # secondary-ji’ayir-brown
  end
end
