def my_loop
  while true
    yield
  end
end

def my_loop
  yield while true
end

# my_loop { puts "My-looping forever!"} ---> will My-looping forever! (forever)

# 2.3.1 :003 > array.map do |n| n * 10 end
#  => [10, 20, 30]
# 2.3.1 :004 > puts array.map {|n| n * 10 }
# 10
# 20
# 30
#  => nil
# 2.3.1 :005 > puts array.map do |n| n * 10 end
# #<Enumerator:0x0000000210f868>
#  => nil
# 2.3.1 :006 > 5.times {puts "Writing this 5 times!" }
# Writing this 5 times!
# Writing this 5 times!
# Writing this 5 times!
# Writing this 5 times!
# Writing this 5 times!
#  => 5
# 2.3.1 :007 > 5.times {|i| puts "I'm on iteration #{i}!" }
# I'm on iteration 0!
# I'm on iteration 1!
# I'm on iteration 2!
# I'm on iteration 3!
# I'm on iteration 4!
#  => 5
# 2.3.1 :008 > class Integer
# 2.3.1 :009?>   def my_times
# 2.3.1 :010?>     c = 0
# 2.3.1 :011?>     until c == self
# 2.3.1 :012?>       yield(c)
# 2.3.1 :013?>       c += 1
# 2.3.1 :014?>       end
# 2.3.1 :015?>     self
# 2.3.1 :016?>     end
# 2.3.1 :017?>   end
#  => :my_times
# 2.3.1 :018 > 5.my_times {|i| puts "I'm on iteration #{i}!" }
# I'm on iteration 0!
# I'm on iteration 1!
# I'm on iteration 2!
# I'm on iteration 3!
# I'm on iteration 4!
