require_relative "stacklike"
# require and load take strings are their arguments, whereas include or prepend takes the name of a module in the form of a
# constant. More fundamentally, it's because require and load are locating and loading disk files, whereas include and prepend
# perform a program-space, in-memory operation that has nothing to do with files. It's a common sequence to require a feature
# and then include a module that the feature defines. The two operations thus often go together, but they're completely different
# from each other.

# Also -- our class name is a noun, our module is an adjective. Not mandatory, but common practices.

class Stack
  include Stacklike
end

s = Stack.new #instantiation of a new Stack object, which is assigned to variable s. That Stack object is born with the
# knowledge of what to do when we ask it to perform stack-related actions, thanks to the fact that its class mixed in the
# Stacklike module.
s.add_to_stack("item one") # asking the object to add items (strings)
s.add_to_stack("item two") # asking the object to add items (strings)
s.add_to_stack("item three") # asking the object to add items (strings)
puts "Objects currently on the stack:"
puts s.stack # asking the object to report on it's state
taken = s.take_from_stack #asking the object to remove the last object.
puts "Removed this object"
puts taken
puts "Now on stack:"
puts s.stack

# => Objects currently on the stack:
# => item one
# => item two 
# => item three
# => Removed this object:
# => item three 
# => Now on stack:
# => item one 
# => item two

# Could very well have put all the functionality of Stacklike module directly into the Stack class. ex:

#class Stack
  #attr_reader :stack
  #def initialize
    #@stack = []
  #end
  #def add_to_stack(obj)
    #@stack.push(obj)
  #end
  #def take_from_stack
    #@stack.pop
  #end
#end

# But modules are not pointless. The modularization buys you: it lets you apply a general concept like stacklikeness to
# several cases, not just one. So hat else is stacklike?
