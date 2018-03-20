obj = Object.new

#* ats as a sponge.
def obj.multiple_args(*x)
  puts "I can take zero or more arguments!"
end

obj.multiple_args

def two_or_more(a, b, *c)
  puts "I require two or more arguments!"
  puts "And sure enough, I got: "
  p a, b, c
  # Using p rather than print or puts results in the array being printed out in array notation.
  #Otherwise, each array element would appear on a separate line, making it harder to see that an array
  #is involved at all.
end

two_or_more(1, 2, 3, 4, 5)

def default_args(a,b,c=1)
  puts "Values of variables: ", a,b,c
end

default_args(3,2)
default_args(4,5,6)

def mixed_args(a,b,*c,d)
  puts "Arguments:"
  p a,b,c,d
end

mixed_args(1,2,3,4,5)
mixed_args(1,2,3)

def args_unleashed(a,b=1,*c,d,e)
  puts "Arguments: "
  p a,b,c,d,e
end

args_unleashed(1,2,3,4,5)
args_unleashed(1,2,3,4)
args_unleashed(1,2,3)
args_unleashed(1,2,3,4,5,6,7,8)

# Required arguments are handled first, then the default-valued options argument, and then the sponge.
