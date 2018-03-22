class Ticket
  def event
    "Can't really be specified yet..."
  end
end

ticket = Ticket.new
puts ticket.event

#Overriding Methods: 
class C
  def m
    puts "First definition of method m"
  end

  def m
    puts "Second definition of method m"
  end
end

C.new.m
