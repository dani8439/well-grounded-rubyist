#An Instance variable maintining its value between method calls:

class Person
  def set_name(string)
    puts "Setting person's name..."
    @name = string
  end

  def get_name
    puts "Returning the person's name..."
    @name
  end
end

joe = Person.new
joe.set_name("Joe")
puts joe.get_name

# Thanks to the assignment that happens as a result of the call to set_name, when you ask for the person's name
# you get back what you put in: "Joe". Unlike a local variable, the instance variable @name retains the value assigned
# to it even after the method in which it was initialized has terminated. This property of instance variables -
# their survival across method calls - makes them suitable for maintaining state in an object.

#state = saved information
