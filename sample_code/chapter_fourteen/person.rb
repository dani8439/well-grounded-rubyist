class Person
  attr_accessor :name
  def self.to_proc
    Proc.new {|person| person.name }
  end
end
d = Person.new
d.name = "David"
m = Person.new
m.name = "Matz"
puts [d,m].map(&Person)

# David
# Matz
