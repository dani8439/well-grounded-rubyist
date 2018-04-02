module MyFirstModule
  def say_hello
    puts "Hello"
  end
end

class ModuleTester
  include MyFirstModule
end

mt = ModuleTester.new
mt.say_hello

# The ModuleTester object calls the appropriate method (say_hello) and outputs Hello. say_hello isn't defined in the
# class of which the object is an instance, instead it's defined in a module that the class mixes in.
