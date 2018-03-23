# class Ticket
#   def initialize(venue, date, price)
#     @venue = venue
#     @date = date
#     @price = price
#   end
#
#   def price
#     @price
#   end
#
#   def venue
#     @venue
#   end
#
#   def date
#     @date
#   end
#
#   def discount(percent)
#     @price = @price * (100 - percent) / 100.0
#   end
# end
#
# th = Ticket.new("Town Hall", "11/12/13", 63.00)

# It's all gotten too darn long, can rewrite the initialize method so that it doesn't expect a price figure:

class Ticket
  def initialize(venue, date)
    @venue = venue
    @date = date
  end

  def set_price(amount)
    @price = amount
  end

  def price
    @price
  end
end

ticket = Ticket.new("Town Hall", "11/12/13")
ticket.set_price(63.00)
puts "The ticket costs $#{"%.2f" % ticket.price}."  #<-- format price to two decimal places
ticket.set_price(72.50)
puts "Whoops -- it just went up. It now costs $#{"%.2f" % ticket.price}."
