class Ticket
  # def initialize
  #   puts "Creating a new ticket!"
  # end

  def initialize(venue, date)
    @venue = venue
    @date = date
  end

  def venue
    @venue
  end

  def date
    @date
  end

  # def event
  #   "Can't really be specified yet..."
  # end
end


# ticket = Ticket.new("Town Hall", "11/12/13")
# puts ticket
# puts ticket.event

#Overriding Methods:
# class C
#   def m
#     puts "First definition of method m"
#   end
#
#   def m
#     puts "Second definition of method m"
#   end
# end
#
# C.new.m

th = Ticket.new("Town Hall", "11/12/13")
cc = Ticket.new("Convention Center", "12/13/14")
puts "We've create two tickets."
puts "The first is for the #{th.venue} event on #{th.date}."
puts "The second is for an event on #{cc.date} at #{cc.venue}."
