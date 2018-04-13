obj = Object.new
def obj.show_me
  puts "Inside singleton method show_me of #{self}"
end

obj.show_me
puts "Back from call to show_me by #{obj}"

# Output is : Inside singleton method show_me of #<Object:0x000000015fd5b0>
# Back from call to show_me by #<Object:0x000000015fd5b0>
