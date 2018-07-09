def capture_block(&block)
  block.call
end
capture_block { puts "Inside the block" }
# Inside the block


p = Proc.new { puts "This proc argument will serve as a code block." }
capture_block(&p)

# This proc argument will serve as a code block.

capture_block(&p) { puts "This is the explicit block" }
# proc.rb:13: both block arg and actual block given

capture_block(p)
capture_block(p.to_proc)
# proc.rb:1:in `capture_block': wrong number of arguments (given 1, expected 0) (ArgumentError)
#         from proc.rb:16:in `<main>'
