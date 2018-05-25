array = ["ruby", "diamond", "emerald"]
hash = { 0 => "ruby", 1 => "diamond", 2 => "emerald" }
puts array[0]
puts hash[0]

# ruby
# ruby

hash = { "red" => "ruby", "white" => "diamond", "green" => "emerald" }
hash.each.with_index {|(key,value), i|
  puts "Pair #{i} is: #{key}/#{value} "
}

# Pair 0 is: red/ruby
# Pair 1 is: white/diamond
# Pair 2 is: green/emerald

a = [1,2,3,4,5]
p a[2]

# 3

array = ["the", "dog", "ate", "the", "cat"]
articles = array.values_at(0, 3)
p articles

# ["the", "the"]
