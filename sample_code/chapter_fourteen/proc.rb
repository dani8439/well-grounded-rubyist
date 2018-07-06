pr = Proc.new { puts "Inside a Proc's block" }
pr.call

# Inside a Proc's block

def call_a_proc(&block)
  block.call
end
call_a_proc { puts "I'm the block...or Proc...or something." }

# I'm the block...or Proc...or something.

p = Proc.new { |x| puts x.upcase }
%w{ David Black }.each(&p)

# DAVID
# BLACK
