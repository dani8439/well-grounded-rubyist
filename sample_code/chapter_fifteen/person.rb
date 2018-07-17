class Person
  attr_accessor :name, :age
  def initialize(name, age)
    @name, @age = name, age
  end

  def method_missing(m, *args, &block)
    if /set_(.*)/.match(m)
      self.send("#{$1}=", *args)
    else
      super
    end
  end

  def respond_to_missing?(m, include_private = false)
    /set_/.match(m) || super
  end
end

person = Person.new("David", 54)
person.set_age(55)
p person.age
p person.respond_to?(:set_age)

# 55
# false  --- then add respond_to_missing? and false becomes true.

person = Person.new("David", 55)
p person.method(:set_age)

#<Method: Person#set_age>
