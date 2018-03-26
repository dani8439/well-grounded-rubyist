class Publication
  attr_accessor :publisher
end

class Magazine < Publication
  attr_accessor :editor
end

class Ezine < Magazine
end

mag = Magazine.new
mag.publisher = "David A. Black"
mag.editor = "Joe Smith"
puts "Mag is published by #{mag.publisher}, and edited by #{mag.editor}."

# Any instance method you define in a given class can be called by instances of that class, and also by
# instances of any subclasses of that class.


class Person
  def species
    "Homo Sapiens"
  end
end

class Rubyist < Person
end

david = Rubyist.new
puts david.species

# In this example, the Rubyist class descends from Person. That means a given Rubyist instance, such as david
# can call the species method that was defined in the Person class. As always in Ruby, it's about objects: what
# a given object can do at a given point in the program. Objects get their behaviors from their classes, from their
# individual or singleton methods, and also from the ancestors (superclass, super-superclass, and so on) of their
# classes (and from one or two places haven't looked at ---> an Object is an Object, a Class is a class, but an object
# is also a class, and a class is also an object)

class C
end

class D < C
end

puts D.superclass
puts D.superclass.superclass
