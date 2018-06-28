# Original code before changing module
# class Person
#   attr_accessor :name
# end
#
# david = Person.new
# david.name = "David"
# matz = Person.new
# matz.name = "Matz"
# ruby = Person.new
# ruby.name = "Ruby"
#
# def david.name
#   "[not available]"
# end
#
# puts "We've got one person named #{matz.name}, "
# puts "one named #{david.name}, "
# puts "and one named #{ruby.name}"
#
# # We've got one person named Matz,
# # one named [not available],
# # and one named Ruby
#
# module Secretive
#   def name
#     "[not available]"
#   end
# end
#
# class << ruby
#   include Secretive
# end


class Person
  attr_accessor :name
end
module Secretive
  def name
    "[not available]"
  end
end

david = Person.new
david.name = "David"
matz = Person.new
matz.name = "Matz"
ruby = Person.new
ruby.name = "Ruby"

class << ruby
  include Secretive
end

def david.name
  "[not available]"
end


puts "We've got one person named #{matz.name}, "
puts "one named #{david.name}, "
puts "and one named #{ruby.name}"

# We've got one person named Matz,
# one named [not available],
# and one named [not available]
