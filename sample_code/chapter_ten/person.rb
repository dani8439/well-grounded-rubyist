class Person
  attr_accessor :age
  def initialize(options)
    self.age = options[:age]
  end
  def teenager?
    (13..19) === age
  end
end

people = 10.step(25,3).map {|i| Person.new(:age =>i)}

# => [#<Person:0x000000027512f8 @age=10>, #<Person:0x00000002751280 @age=13>, #<Person:0x00000002750088 @age=16>, #<Person:0x00000002750038 @age=19>, #
# <Person:0x00000002753f08 @age=22>, #<Person:0x00000002743f40 @age=25>]

teens = people.partition {|person| person.teenager?}

# => [[], [#<Person:0x000000027512f8 @age=10>, #<Person:0x00000002751280 @age=13>, #<Person:0x00000002750088 @age=16>, #<Person:0x00000002750038 @age=1
# 9>, #<Person:0x00000002753f08 @age=22>, #<Person:0x00000002743f40 @age=25>]]

puts "#{teens[0].size} teens; #{teens[1].size} non-teens"
# 3 teens; 3 non-teens
