### *Resolving instance variables through self* ###
A simple rule governs instance variables and their resolution: every instance variable you'll ever see in a Ruby program belongs to whatever object is the current object (self) at that point in the program.

Here is a classic case where this knowledge comes in handy:

```ruby
class C
  def show_var
    @v = "I am an instance variable initialized to a string."
    puts @v
  end
  @v = "Instance variables can appear anywhere...."
end

C.new.show_var
```

The code prints the following:

```ruby
I am an instance variable initialized to a string.
```
