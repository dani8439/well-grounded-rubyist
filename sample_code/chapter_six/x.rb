# The value of statements:

x = 1
if x < 0
  puts "negative"
elsif x > 0
  puts "positive"
else
  puts "zero"
end

# positive

# x = 1
# if x == 2
#   "it's 2!"
# elsif x == 3
#   "it's 3!"
# end

#entire statement evaluates to nil because it fails (in irb).

# if false
#   x = 1
# end
# p x # output is nil
# p y # fatal error: y is unknown
#
# # x.rb:27:in `<main>': undefined local variable or method `y' for main:Object (NameError)
#

if x = 1
  puts "Hi!"
end

# (irb):2: warning: found = in conditional, should be ==
# Hi!
# => nil

# whereas
if x = y # No warning. 
