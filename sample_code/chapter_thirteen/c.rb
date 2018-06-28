class C
  def talk
    puts 'Hi from original class!'
  end
end

module M
  def talk
    puts "Hello from module!"
  end
end

c = C.new
c.talk

# class << c
#   include M
# end

# Hi from original class!
# Hello from module!


# class << c
#   include M
#   p ancestors
# end
# c.talk

# Hi from original class!
# [#<Class:Object>, #<Class:BasicObject>, Class, Module, Object, M, Kernel, BasicObject]
# Hi from original class!

class C
  include M
end
class << c
  p ancestors
end

c.talk

# Hi from original class!
# [#<Class:#<C:0x000000026e2ce0>>, C, M, Object, Kernel, BasicObject]
# Hi from original class!
