require_relative 'callertools'
def x
  y
end
def y
  z
end
def z
  stack = CallerTools::Stack.new
  puts stack.report
end
x

#               callertest.rb    9              z
#               callertest.rb    6              y
#               callertest.rb    3              x
#               callertest.rb   12         <main>
