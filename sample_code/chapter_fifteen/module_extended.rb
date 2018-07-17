module M
  def self.extended(obj)
    puts "Module #{self} is being used by #{obj}."
  end
  def an_inst_method
    puts "This module supplies this instance method."
  end
end

my_object = Object.new
my_object.extend(M)
my_object.an_inst_method

# Module M is being used by #<Object:0x0000000210bc68>.
# This module supplies this instance method.
