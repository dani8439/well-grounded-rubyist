# loop { puts "Looping forever!"}
# loop do
#   puts "Looping forever!"
# end

# Controlling the loop:
# n = 1
# loop do
#   n = n + 1
#   break if n > 9
# end
# => won't be an output, will just execute(loop).

# n = 1
# loop do
#   n = n + 1
#   next unless n == 10
# end
# => won't be an output, will just execute.

# The While Keyword
# n = 1
# while n < 11
#   puts n
#   n = n + 1
# end
# puts "Done!"

# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10
# Done!

n = 1
begin
  puts n
  n = n + 1
end while n < 11
puts "Done!"

# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10
# Done!

# If you put while at the beginning and if the while condition is false, the code isn't executed
n = 10
while n < 10
  puts n
end

# But if you put the while test at the end...
n = 10
begin
  puts n
end while n < 10

# 10 is the output.

# The until keyword:
# The body of the loop (the printing & incrementing of n in this example) is executed repeatedly until condition is true.
n = 1
until n > 10
  puts n
  n = n + 1
end

# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10

# The while & until modifiers
n = 1
n = n + 1 until n == 10
puts "We've reached 10!"
# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10
# We've reached 10!

# Could also use while n < 10. The one-line modifier versions of while and until don't behave the same way as
# post-positioned while and until you use with a begin/end block. IOW:
a = 1
a += 1 until true
# won't execute because already true.

#But in this case:
a = 1
begin
  a += 1
end until true
# The body of the begin/end gets executes once.



celsius = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
puts "Celsius\tFahrenheit"
for c in celsius
  puts "#{c}\t#{Temperature.c2f(c)}"
end
