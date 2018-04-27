print "Exiting the program? (yes or no): "
answer = gets.chomp
case answer
when "yes"
  puts "Good-bye!"
  exit
when "no"
  puts "OK, we'll continue"
else
  puts "That's an unknown answer -- assuming you meant 'no'"
end
puts "Continuing with program..."

case answer
when "y", "yes"
  puts "Good-bye!"
  exit
  #etc
end

if "yes" === answer
  puts "Good-bye!"
  exit
elsif "no" === answer
  puts "OK, we'll continue"
else
  puts "That's an unknown answer-assuming you meant 'no'"
end

# if "yes" === answer is equivalent to if "yes".===(answer)

case
when user.first_name == "David", user.last_name == "Black"
  puts "You might be David Black."
when Time.now.wday == 5
  puts "You're not David Black, but at least it's Friday!"
else
  puts "You're not David Black, and it's not Friday!"
end

# can be rewritten as:

if user.first_name == "David" or user.last_name == "Black"
  puts "You might be David Black."
elsif Time.now.wday == 5
  puts "You're not David Black, but at least it's Friday!"
else
  puts "You're not David Black, and it's not Friday."
end

puts case
     when user.first_name == "David", user.last_name == "Black"
       "You might be David Black."
     when Time.now.wday == 5
       "You're not David Black, but at least it's Friday!"
     else "You're not David Black, and it's not Friday."
   end
