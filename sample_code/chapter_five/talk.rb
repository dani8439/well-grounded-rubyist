def talk
  puts "Hello"
end
puts "Trying 'talk' with no receiver..."
talk #<-- #1
puts "Trying 'talk' with an explicit receiver..."
obj = Object.new
obj.talk #<-- #2

# Trying 'talk' with no receiver...
# Hello
# Trying 'talk' with an explicit receiver...
# talk.rb:8:in `<main>': private method `talk' called for #<Object:0x00000000f85138> (NoMethodError)
