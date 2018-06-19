str = "Leopold Auer was the teacher of Jascha Heifetz."
# "Leopold Auer was the teacher of Jascha Heifetz."
violinists = str.scan(/([A-Z]\w+)\s+([A-Z]\w+)/)
# [["Leopold", "Auer"], ["Jascha", "Heifetz"]]

violinists.each do |fname, lname|
  puts "#{lname}'s first name was #{fname}."
end

# Auer's first name was Leopold.
# Heifetz's first name was Jascha.

str.scan(/([A-Z]\w+)\s+([A-Z]\w+)/) do |fname, lname|
  puts "#{lname}'s first name was #{fname}."
end
