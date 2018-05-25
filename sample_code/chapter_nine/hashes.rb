state_hash = { "Connecticut" => "CT",
               "Delaware" => "DE",
               "New Jersey" => "NJ",
               "Virginia" => "VA" }
print "Enter the name of a state: "
state = gets.chomp
abbr = state_hash[state]
puts "The abbreviation is #{abbr}."


# Enter the name of a state: New Jersey
# The abbreviation is NJ.

h = Hash.new
h["a"] = 1
h["a"] = 2
puts h["a"]

# 2
