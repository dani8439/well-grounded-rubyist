class C
  def x
    puts "Class C, method x:"
    puts self
  end
end

c = C.new
c.x
puts "That was a call to x by: #{c}"

# Output: Class C, method x:
# #<C:0x000000026e8f78>
# That was a call to x by: #<C:0x000000026e8f78>
