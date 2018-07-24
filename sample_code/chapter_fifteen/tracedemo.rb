def x
  y
end
def y
  z
end
def z
  puts "Stacktrace: "
  p caller
end
# def z
#   raise
# end
x

# Stacktrace:
# ["tracedemo.rb:5:in `y'", "tracedemo.rb:2:in `x'", "tracedemo.rb:11:in `<main>'"]


# tracedemo.rb:12:in `z': unhandled exception
#         from tracedemo.rb:5:in `y'
#         from tracedemo.rb:2:in `x'
#         from tracedemo.rb:14:in `<main>'
