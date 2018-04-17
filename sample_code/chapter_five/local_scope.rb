#Schematic View of local scopes at the top level, the class-definition level, and the method-definition level.

a = 0 # top-level outer scope

def t
  puts "Top level method t" # Method definition scope
end

class C
  a = 1   # Class-definition scope
  def self.x
    a = 2
    puts "C.x; a = #{a}" # Method definition scope
  end

  def M
    a = 3
    puts "C#m; a = #{a}" # Method definition scope
  end

  def N
    a = 4
    puts "C#n; a = #{a}" # Method definition scope
  end
  puts "Class scope: a = #{a}"
end

C.x
c = C.new
c.m   # top-level outer scope
c.n

puts "Top level: a = #{a}"
