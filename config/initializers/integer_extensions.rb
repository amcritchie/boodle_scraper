class Integer
  def ordinalize
    case self
    when 1, 21, 31
      "#{self}st"
    when 2, 22
      "#{self}nd"
    when 3, 23
      "#{self}rd"
    else
      "#{self}th"
    end
  end
end
