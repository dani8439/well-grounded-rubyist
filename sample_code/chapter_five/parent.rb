class Parent
  @@value = 100        #<--- Sets class variable in class Parent.
end
class Child < Parent
  @@value = 200        #<--- Sets class variable in class Child, a subclass of Parent.
end
class Parent
  puts @@value        #<--- Back in Parent class: what's the output?
end


#200