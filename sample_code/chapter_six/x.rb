if false 
  x = 1
end
p x    #<-- Output: nil
p y    #<-- Fatal error: y is unknown

if x = 1
  puts "Hi!"
end

# warning: found = in conditional, should be ==

if x = y #<-- No warning. 
