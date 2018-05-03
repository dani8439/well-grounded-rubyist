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
