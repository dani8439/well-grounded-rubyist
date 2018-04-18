class C
  a = 5
  module M
    a = 4
    module N
      a = 3
      class D
        a = 2
        def show_a
          a = 1
          puts a
        end
        puts a  # Output 2
      end
      puts a  # Output 3
    end
    puts a  # Output 4
  end
  puts a  # Output 5
end

d = C::M::N::D.new
d.show_a    # Output 1

# 2
# 3
# 4
# 5
# 1


class C
  def x(value_for_a, recurse=false)  #1.
    a = value_for_a  #2.
    print "Here's the inspect-string for 'self'"  #3.
    p self
    puts "And here's a:"
    puts a
    if recurse  #4.
      puts "Calling myself (recursion)..."
      x("Second value for a")  #5.
      puts "Back after recursion; here's a:"   #6.
      puts a
    end
  end
end
c = C.new
c.x("First value for a", true)   #7.
