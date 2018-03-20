ticket = Object.new

def ticket.date
  "01/02/03"
end

def ticket.venue
  "Town Hall"
end

def ticket.event
  "Author's reading"
end

def ticket.performer
  "Mark Twain"
end

def ticket.seat
  "Second Balcony, row J, seat 12"
end

def ticket.price
  5.50
end

def ticket.availability_status
  "sold"
end

# OR

def ticket.available?
  false
end

if ticket.available?
  puts "You're in luck!"
else
  puts "Sorry--that seat has been sold"
end

puts "This ticket is for: #{ticket.event}, at #{ticket.venue}. " +
  "The performer is #{ticket.performer}. " +
  "The seat is #{ticket.seat}, " + "and it costs $#{"%.2f" % ticket.price}"

print "Information desired: "
request = gets.chomp
if ticket.respond_to?(request)
  puts ticket.send(request)
else
  puts "No such information available."
end

# print "This ticket is for: "
# print ticket.event + ", at "
# print ticket.venue + ", on "
# print ticket.date + ". "
# print "The performer is "
# puts ticket.performer + "."
# print "The seat is "
# print ticket.seat + ", "
# print "and it costs $"
# puts "%.2f." % ticket.price #print's floating point number to two decimal places

# Remember that nil has a Boolean value of false. A call to puts returns nil, and is therefore false, even though
# the string gets printed. If you put puts in an if clause, the clause will be false. But it will still be evaluated.
