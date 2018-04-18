class Violin
  class String
    attr_accessor :pitch
    def initialize(pitch)
      @pitch = pitch
    end
  end
  def initialize
    @e = String.new("E")   #1. 
    @a = String.new("A")
    @d = String.new("D")
    @g = String.new("G")
  end
end
