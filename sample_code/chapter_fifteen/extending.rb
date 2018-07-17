module M
  def self.included(c)
    puts "#{self} included by #{c}."
  end
  def self.extended(obj)
    puts "#{self} extended by #{obj}"
  end
end
obj = Object.new
puts "Including M in object's singleton class."
class << obj
  include M
end
puts
obj = Object.new
puts "Extending object with M:"
obj.extend(M)


# Including M in object's singleton class.
# M included by #<Class:#<Object:0x00000001d6ef38>>.
#
# Extending object with M:
# M extended by #<Object:0x00000001d6ec40>
