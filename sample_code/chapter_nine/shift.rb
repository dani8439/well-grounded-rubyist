a = [1,2,3,4,5]
print "The original array: "
p a
popped = a.pop
print "The popped item: "
puts popped
print "The new state of the array: "
p a
shifted = a.shift
print "The shifted item: "
puts shifted
print "The new state of the array: "
p a

# The original array: [1, 2, 3, 4, 5]
# The popped item: 5
# The new state of the array: [1, 2, 3, 4]
# The shifted item: 1
# The new state of the array: [2, 3, 4]
