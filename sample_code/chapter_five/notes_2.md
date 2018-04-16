### *Resolving instance variables through self* ###
A simple rule governs instance variables and their resolution: every instance variable you'll ever see in a Ruby program belongs to whatever object is the current object (self) at that point in the program.

Here is a classic case where this knowledge comes in handy:

```ruby
class C
  def show_var
    @v = "I am an instance variable initialized to a string."  #1
    puts @v
  end
  @v = "Instance variables can appear anywhere...."   #2
end

C.new.show_var
```

The code prints the following:

```ruby
I am an instance variable initialized to a string.
```
The trap is that you may think it will print `Instance variables can appear anywhere....` The code prints what it does because the `@v` in the method definition(#1) and the `@v` outside it (#2) are completely unrelated to each other. They're both instance variables, and both are named `@v`, but they aren't the same variable. They belong to difference objects.

Whose are they?

The first `@v` (#1) lies inside the definition block of an instance method of `C`. That fact has implications not for a single object, but for instances of `C` in general: each instance of `C` that calls this method will have its own instance variable `@v`.

The second `@v` (#2) belongs to the class object `C`. This is one of the many occasions where it pays to remember that classes are objects. Any object may have its own instance variables-its own private stash of information and object state. Class objects enjoy this privilege as much as any other object.

Again, the logic required to figure out what object owns a given instance variable is simple and consistent: every instance variable belongs to whatever object is playing the role of self at the moment the code containing the instance variable is executed.

Let's do a quick rewrite of the example, this time making it a little chattier about what's going on:

```ruby
class C
  puts "Just inside class definition block. Here's self:"
  p self
  @v = "I am an instance variable at the top level of a class body."
  puts "And here's the instance variable @v, belonging to #{self}:"
  p @v
  def show_var
    puts "Inside an instance method definition block. Here's self:"
    p self
    puts "And here's the instance variable @v, belonging to #{self}:"
    p @v
  end
end
c = C.new
c.show_var
```

The output from this version is as follows:

```ruby
Just inside class definition block. Here's self:
C
And here's the instance variable @v, belonging to C:
"I am an instance variable at the top level of a class body."
Inside an instance method definition block. Here's self:
#<C:0x000000021dbd50>
And here's the instance variable @v, belonging to #<C:0x000000021dbd50>:
nil
```

Sure enough, each of these two different objects (the class object `C` and the instance of `C`, `c`) has its own instance variable `@v`. The fact that the instance's `@v` is `nil` demonstrates that the assignment to the class's `@v` had nothing to do with the instance's `@v`.

Understanding self-both the basic fact that such a role is being played by some object at every point in a program and knowing how to tell which object is self-is one of the most vital aspects of understanding Ruby. Another equally vital aspect is understanding scope, to which we'll now turn.

## *Determining Scope* ##
