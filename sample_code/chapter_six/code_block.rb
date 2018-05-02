def block_scope_demo
  x = 100
  1.times do     #<--- Single iteration serves to create code block context
    puts x
  end
end

block_scope_demo

# 100

def block_scope_demo_2
  x = 100
  1.times do
    x = 200
  end
  puts x
end
block_scope_demo_2

#200
