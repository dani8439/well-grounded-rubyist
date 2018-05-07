class Banner
  def initialize(text)
    @text = text
  end

  def to_s   #<---1.
    @text
  end

  def +@
    @text.upcase
  end

  def -@
    @text.downcase
  end

  def !
    @text.reverse
  end
end

banner = Banner.new("Eat at David's!")
puts banner
puts +banner
puts -banner
puts !banner
puts (not banner)

# Eat at David's!
# EAT AT DAVID'S!
# eat at david's!
# !s'divaD ta taE
# !s'divaD ta taE
