# point of this module exercise is to test idea that first person to check into a flight, your luggage will be the
# last off the plane....

require_relative "stacklike"

class Suitcase # barebones suitcase class - a placeholder (or stub) that lets us create suitcase objects to fling
  # into the cargo hold
end


class CargoHold
  include Stacklike # Mixes stacklike into the class
  def load_and_report(obj)  # prints a message it's adding a suitcase to the cargo hold, and gives us the suitcase's Object Id number.
    print "Loading object "
    puts obj.object_id # also does some reporting of the current state of the stack.

    add_to_stack(obj) # adding items to the instance (the stacklike thing-the cargo hold in this case)
  end

  def unload # unload sounds more like the term you would use to describe removing a suitcase from a cargo hold --
    # could say take_from_stack directly, but doesn't sound sufficiently plane like for the metaphor.
    take_from_stack # removing items from the instance.
  end
end

ch = CargoHold.new # creating an instance of the class
sc1 = Suitcase.new
sc2 = Suitcase.new
sc3 = Suitcase.new
ch.load_and_report(sc1)
ch.load_and_report(sc2)
ch.load_and_report(sc3)
first_unloaded = ch.unload
print "The first suitcase off the plane is...."
puts first_unloaded.object_id

# => Loading object 1001880
# => Loading object 1001860
# => Loading object 1001850
# => The first suitcase off the plane is....1001850


# this example shows how you can use an existing module for a new class. Sometimes it pays to wrap the methods in new
# methods with better names for the new domain (like unload instead of take_from_stack), although if you find yourself
# changing it too much, it may be a sign that the module isn't a good fit.
