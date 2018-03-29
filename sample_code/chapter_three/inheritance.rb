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

#Single Inheritance - One to a customer. In some object-oriented languages, it's possible for a given class to inherit from more than one class
#Ruby doesn't allow mulitple inheritance; every Ruby class can have only one superclass, in keeping with the principle of single inheritance.


class C
end

class D < C
end

puts D.superclass
puts D.superclass.superclass

#The output is C, and Object, because C is D's superclass,and Object is C's superclass. If you go up the
#chain far enough from any class, you hit Object. Any method available to a bare instance of Object is available
#to every object, that is, if you can do obj = Object.new, obj.some_method then you can call .some_method on any objeect.
#THere's that "almost" though, there is another generation at the top
