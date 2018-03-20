def say_goodbye
  x = "Goodbye"
  puts x
end

def start_here
  x = "Hello"
  puts x
  say_goodbye
  puts "Let's check where x remained the same: "
  puts x
end

start_here

str = "Hello"
abc = str
str.replace("Goodbye")
puts str
puts abc

def say_goodbye
  str = "Hello"
abc = str
str.replace("Goodbye")
puts str
puts abc

end

say_goodbye

str = "Hello"
abc = str
str = "Goodbye"
puts str
puts abc

def change_string(str)
  str.replace("New string content!")
end

s = "Original string content!"
change_string(s)
puts s

s = "Original string content!"
change_string(s.dup)
puts s

s = "Original string content!"
s.freeze
change_string(s)
# Cannot manipulate frozen data - get an error message

numbers = ["one", "two", "three"]
#=> ["one", "two", "three"]
numbers.freeze
#=> ["one", "two", "three"]
numbers[2] = "four"
#=> RuntimeError: can't modify frozen array
numbers[2].replace("four")
#=>"four"
numbers
#=> ["one", "two", "three"]
