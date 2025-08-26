module ApplicationHelper
  def get_grade_background_color(rank)
    return 'bg-gray-400' if rank.nil?
    
    case rank
    when 1..2
      'bg-green-600'
    when 3..5
      'bg-green-500'
    when 6..14
      'bg-green-400'
    when 15..20
      'bg-yellow-400'
    when 21..25
      'bg-orange-400'
    when 26..32
      'bg-red-400'
    else
      'bg-gray-400'
    end
  end
end
