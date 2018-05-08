class Person
  attr_accessor :name
  def to_str
    name
  end
end

david = Person.new
david.name = "David"
puts "david is named " + david + "."

# david is named David.

class Person
  attr_accessor :name, :age, :email
  def to_ary
    [name, age, email]
  end
end

david = Person.new
david.name = "David"
david.age = 55
david.email = "david@whatever"
array = []
array.concat(david)
p array

# ["David", 55, "david@whatever"]
