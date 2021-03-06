class Rainbow
  include Enumerable
  def each
    yield "red"
    yield "orange"
    yield "yellow"
    yield "green"
    yield "blue"
    yield "indigo"
    yield "violet"
  end
end

r = Rainbow.new
r.each do |color|
  puts "Next color: #{color}"
end

# Next color: red
# Next color: orange
# Next color: yellow
# Next color: green
# Next color: blue
# Next color: indigo
# Next color: violet

r = Rainbow.new
y_color = r.find {|color| color.start_with?('y')}
puts "First color starting with 'y' is #{y_color}"

# First color starting with 'y' is yellow

>> r = Rainbow.new
=> #<Rainbow:0x000000011d4088>
>> r.select { |color| color.size == 6 }
=> ["orange", "yellow", "indigo", "violet"]
>> r.map {|color| color[0,3] }
=> ["red", "ora", "yel", "gre", "blu", "ind", "vio"]
>> r.drop_while {|color| color.size < 5 }
=> ["orange", "yellow", "green", "blue", "indigo", "violet"]
