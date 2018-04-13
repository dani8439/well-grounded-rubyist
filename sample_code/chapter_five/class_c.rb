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

class C
  def C.x
    puts "Class method of class C"
    puts "self: #{self}"
  end
end

C.x

# Here's what it reports:
# Class method of class C
# self: C

class C
  def C.no_dot
    puts "As long as self is C, you can call this method with no dot"
  end
  no_dot
end

C.no_dot
