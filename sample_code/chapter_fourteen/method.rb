class C
  def talk
    puts "Method-grabbing test! self is #{self}."
  end
end
c = C.new
meth = c.method(:talk)
meth.call

# Method-grabbing test! self is #<C:0x000000010e3ef8>.

class D < C 
end 
d = D.new 
unbound = meth.unbind 
unbound.bind(d).call

# Method-grabbing test! self is #<D:0x00000002487590>.


unbound = C.instance_method(:talk)

# Method-grabbing test! self is #<C:0x0000000278bac0>.
