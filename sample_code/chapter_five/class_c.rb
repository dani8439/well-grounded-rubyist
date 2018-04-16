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
  no_dot   # 1
end

C.no_dot  # 2

# 1 First call to no_dot doesn't have an explicit receiver; it's a bareword. When Ruby sees this (and determines
# that it's a method call rather than a variable or keyword), it figures that you mean it as shorthand for: self.no_dot
# and the message gets printed. In the case of our example, self.no_dot would be the same as C.no_dot, because we're inside
# C's definition block and therefore, self is C. The result is that the method C.no_dot is called, and we see the output.
# 2. The second time we call the method (2) we're back outside the class-defintion block, so C is no longer self.
# Therefore, to call no_dot, we need to specify the receiver C. The result is a second call to no_dot (albeit with a dot) and
# another printing of the output from that method.

class C
  def x
    puts "This is method 'x'"
  end
  def y
    puts "This is method 'y', about to call x without a dot."
    x
  end
end
c = C.new
c.y

# This is method 'y', about to call x without a dot.
# This is method 'x'
