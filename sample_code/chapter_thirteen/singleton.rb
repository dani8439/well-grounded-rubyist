str = "I am a string"
class << str
  def twice
    self + " " + self
  end
end
puts str.twice

# I am a string I am a string

N = 1
obj = Object.new
class << obj
  N = 2
end

def obj.a_method
  puts N
end
class << obj
  def another_method
    puts N
  end
end

obj.a_method
obj.another_method

# 1
# 2

class Ticket 
  class << self 
    def most_expensive(*tickets)
      tickets.may_by(&:price)
    end 
  end
end
