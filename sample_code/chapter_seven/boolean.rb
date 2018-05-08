if (class MyClass; end)                     #<----1.
  puts "Empty class definition is true!"
else
  puts "Empty class definition is false!"
end

if (class MyClass; 1; end)                              #<----2.
  puts "Class definition with the number 1 in it is true!"
else
  puts "Class definition with the number 1 in it is false!"
end

if (def m; return false; end)              #<----3.
  puts "Method definition is true!"
else
  puts "Method definition is false!"
end

if "string"                              #<----4.
  puts "Strings appear to be true!"
else
  puts "Strings appear to be false!"
end

if 100 > 50                                #<----5.
  puts "100 is greater than 50!"
else
  puts "100 is not greater than 50!"
end

# boolean.rb:23: warning: string literal in condition
# Empty class definition is false!
# Class definition with the number 1 in it is true!
# Method definition is true!
# Strings appear to be true!
# 100 is greater than 50!
