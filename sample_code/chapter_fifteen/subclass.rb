class C
  def self.inherited(subclass)
    puts "#{self} just got subclassed by #{subclass}."
  end
end
class D < C
end

class E < D
end

# C just got subclassed by D.
# D just got subclassed by E.
