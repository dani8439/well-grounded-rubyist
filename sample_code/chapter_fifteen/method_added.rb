class C
  def self.method_added(m)          #<----Defines callback
    puts "Method #{m} was just defined."
  end
  def a_new_method        #<-----Triggers it by defining instance method
  end
end

# Method a_new_method was just defined.

class C
  def self.singleton_method_added(m)
    puts "Method #{m} was just defined."
  end
end

# Method singleton_method_added was just defined.

class C
  def self.singleton_method_added(m)
    puts "Method #{m} was just defined."
  end
  def self.new_class_method
  end
end

# Method singleton_method_added was just defined.
# Method new_class_method was just defined.


obj = Object.new
def obj.singleton_method_added(m)
  puts "Singleton method #{m} was just defined."
end
def obj.a_new_singleton_method
end

# Singleton method singleton_method_added was just defined.
# Singleton method a_new_singleton_method was just defined.


obj = Object.new
class << obj
  def singleton_method_added(m)
    puts "Singleton method #{m} was just defined."
  end
  def a_new_singleton_method
  end
end

# Singleton method singleton_method_added was just defined.
# Singleton method a_new_singleton_method was just defined.

class C
  def singleton_method_added(m)
    puts "Singleton method #{m} was just defined."
  end
end
c = C.new
def c.a_singleton_method
end

# Singleton method a_singleton_method was just defined.
