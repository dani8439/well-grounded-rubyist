def fussy_method(x)
  raise ArgumentError, "I need a number under 10" unless x < 10
end
fussy_method(20)

# fussy.rb:2:in `fussy_method': I need a number under 10 (ArgumentError)
#        from fussy.rb:4:in `<main>'

begin
  fussy_method(20)
rescue ArgumentError
  puts "That was not an acceptable number!"
end

begin

  fussy_method(20)
rescue ArgumentError => e                              #1
  puts "That was not an acceptable number!"
  puts "Here's the backtrace for this exception: "
  puts e.backtrace                                     #2
  puts "And here's the exception object's message: "
  puts e.message                                       #3
end

# That was not an acceptable number!
# Here's the backtrace for this exception:
# fussy.rb:2:in `fussy_method'
# fussy.rb:17:in `<main>'
# And here's the exception object's message:
# I need a number under 10
