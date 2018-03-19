obj = Object.new

def obj.talk
  puts "I am an object"
  puts "(Do you object?)"
end

def obj.c2f(c)
  # parentheses are optional --> Could write def obj.c2f c (not always optional, such as when stringing method calls together)
  c * 9.0 / 5 + 32
end

obj.talk

puts obj.c2f(100)
# or write obj.c2f 100
