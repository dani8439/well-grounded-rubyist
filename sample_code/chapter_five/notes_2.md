## *Determining Scope* ##
*Scope* refers to the reach or visibility of identifiers, specifically variables and constants. Different types of identifiers have different scoping rules; using, say, the identifier `x` for a local variable in each of the two method definitions has a different effect than using the global variable `$x` in the same two places, because local and global variables differ as to scope. This section considers three types of variables: global, local, and class variables. (As we've just seen, instance variables are self-bound, rather than scope-bound). We'll also look at the rules for resolving constants.

Self and scope are similar in that they both change over the course of a program, and in that you can deduce what's going on with them by reading the program as well as running it. But scope and self aren't the same thing. You can start a new local scope without self changing-but sometimes scope and self change together. They have in common the fact that they're both necessary to make sense of what your code is going to do. Like knowing which object self is, knowing what scope you're in tells you the significance of the code.

Let's star with global variables-not the most commonly used construct, but an important one to grasp.

### *Global scope and global variables* ###
*Global Scope* is scope that covers the entire program. Global scope is enjoyed by global variables, which are recognizable by their initial dollar-sign (`$`) character. They're available everywhere. They walk through walls: even if you start a new class or method definition, even if the identity of self changes, the global variables you've initialized are still available to you.

In other words, global variables never go out of scope (An exception to this is "thread-local globals", which we'll meet later on.) In this example, a method defined inside a class-definition body (two scopes removed from the outer- or top-level scope of the program) has access to a global variable initialized at the top:

```ruby
$gvar = "I'm a global!"
class C
  def examine_global
    puts $gvar
  end
end
c = C.new
c.examine_global

# I'm a global!
```

You'll be told by `$gvar` in no uncertain terms, "I'm a global!" If you change all the occurrences of `$gvar` to a non-global variable such as `local_var`, you'll see that the top-level `local_var` isn't in scope inside the method definition block.

```ruby
class_c_2.rb:4:in `examine_global': undefined local variable or method `local_var' for #<C:0x000000010950f0> (NameError)
Did you mean?  local_variables
        from class_c_2.rb:8:in `<main>'
```
### BUILT-IN GLOBAL VARIABLES ###

The Ruby interpreter starts up with a fairly large number of global variables already initialized. These variables store information that's of potential use anywhere and everywhere in your program. For example, the global variable `$0` contains the name of the startup file for the currently running program. The global `$:` (dollar sign followed by a colon) contains the directories that make up the path Ruby searches when you load an external file. `$$` contains the process ID of the Ruby process. And there are more.

**TIP**
To see descriptions of all the built-in global variables you're likely to need - can look them up in the file English.rb in your Ruby installation.

Creating your own global variables can be tempting, especially for beginning programmers and people learning a new language (not just Ruby either). But that's rarely a good or appropriate choice.

### PROS AND CONS OF GLOBAL VARIABLES ###
Globals appear to solve lots of design problems: you don't have to worry about scope, and multiple classes can share information by stashing it in globals rather than designing objects that have to be queried with method calls. Without doubt, global variables have a certain allure.

But they're used very little by experienced programmers. The reasons for avoiding them are similar to the reasons they're tempting. Using global variables tends to end up being a substitute for solid, flexible program design, rather than contributing to it. One of the main points of object-oriented programming is that data and actions are encapsulated in objects. You're *supposed* to have to query objects for information and to request that they perform actions.

And objects are supposed to have a certain privacy. When you ask an object to do something, you're not supposed to care what the object does internally to get the job done. Even if you yourself wrote the code for the object's methods, when you send the object a message, you treat the object as a black box that works behind the scenes and provides a response.

Global variables distort the landscape by providing a layer of information shared by every object in every context. The result is that objects stop talking to each other and, instead, share information by setting global variables.

Here's a small example-a rewrite of our earlier `Person` class (the one with the first, optional middle, and last names). This time, instead of attributes on the object, we'll generate the whole name from globals:

```ruby
class Person
  def whole_name
    n = $first_name + " "
    n << "#{$middle_name} " if $middle_name
    n << $last_name
  end
end
```

To use this class and to get a whole name from an instance of it, you'd have to do this:

```ruby
david = Person.new
$first_name = "David"
$middle_name = "Alan"
$last_name = "Black"
puts david.whole_name

# Output: David Alan Black
```

This version still derives the whole name, from outside, by querying the object. But the components of the name are handed around over the heads of the object, so to speak, in a separate network of global variables. It's concise and easy, but it's also drastically limited. What would happen if you had lots of `Person` objects, or if you wanted to save a `Person` object, including its various names, to a database? Your code would quickly become tangles to say the least.

Globally scoped date is fundamentally in conflict with the object-oriented philosophy of endowing objects with abilities and then getting things done by sending requests to those objects. Some Ruby programmers work for years and never use a single global variable (except perhaps a few of the built-in ones). That may or may not end up being your experience, but it's not a bad target to aim for.

Now that we've finished with the "try not to do this" part, let's move on to a detailed consideration of local scope.

## *Local Scope* ##
*Local Scope* is a basic layer of the fabric of every Ruby program. At any given moment, your program is in a particular local scope. The main thing that changes from one local scope to another is your supply of local variables. When you leave a local scope-by returning from a method call, or by doing something that triggers a new local scope-you get a new supply. Even if you've assigned to a local variable `x` in one scope, you can assign to a new `x` in a new scope, and the two `x`'s won't interfere with each other.

You can tell by looking at a Ruby program where the local scopes begin and end, based on a few rules:

• The top level (outside all definition blocks) has its own local scope.

• Every class or module-definition block (`class`, `module`) has its own local scope, even nested class-/module-definition blocks.

• Every method definition (`def`) has its own local scope; more precisely, every call to a method generates a new local scope, with all local variables reset to an undefined state.

Exceptions and additions to these rules exist, but they're fairly few and don't concern us right now.

(see local_scope.rb for chart)

Every time you cross into a class-, module-, or method-definition block-every time you step over a `class`, `module`, or `def` keyword-you start a new local scope. Local variables that lie very close to each other physically may in fact have nothing whatsoever to do with each other, as this example shows:

```ruby
class C
  a = 1  #1
  def local_a
    a = 2  #2
    puts a
  end
  puts a #3
end

c = C.new
c.local_a  #4

# => 1
# => 2
```
The variable `a` that gets initialized in the local scope of the class definition(1) is in a different scope than the variable `a` inside the method-definition(2). When you get to the `puts a` statement after the method definition(3), you're back in the class-definition local scope; the `a` that gets printed is the `a` you initialized back at the top(1), not the `a` that's in scope in the method definition(2). Meanwhile, the second `a` isn't printed until later, when you've created the instance `c` and sent the message `local_a` to it(4).

When you nest classes and modules, every crossing into a new definition black creates a new local scope. The following shoes some deep nesting of classes and modules, with a number of variables called `a` being initialized and printed out along the way (see nested.rb to manipulate):

```ruby
class C
  a = 5
  module M
    a = 4
    module N
      a = 3
      class D
        a = 2
        def show_a
          a = 1
          puts a
        end
        puts a  # Output 2
      end
      puts a  # Output 3
    end
    puts a  # Output 4
  end
  puts a  # Output 5
end

d = C::M::N::D.new
d.show_a    # Output 1
```

Every definition-block-whether for a class, a module, or a method-starts a new local scope-a new local-variable scratchpad-and gets is own variable `a`. This example also illustrates the fact that all the code in class- and module-definition blocks gets executed when it's first encountered, whereas methods aren't executed until an object is sent the appropriate message. That's why the value of `a` that's set inside the `show_a` method is displayed last along the five values that the program prints; the other four are executed as they're encountered in the class or module definitions, but the last one isn't executed until `show_a` is executed by the object `d`.

Local scope changes often, as you can see. So does the identity of self. Sometimes, but only sometimes, they vary together. Let's look a little closer at the relationship between scope and self.

### *The interaction between local scope and self* ###
When you start a definition block (method, class, module), you start a new local scope, and you also create a block of code with a particular self. But logical scope and self don't operate entirely in parallel, not only because they're not the same thing, but also because they're not the same *kind* of thing.

Consider the following listing. This program uses *recursion:* the instance method `x` calls itself. The point is to demonstrate that every time a method is called-even if a previous call to the method is still in the process of running-a new local scope is generated.

```ruby
class C
  def x(value_for_a, recurse=false)  #1.
    a = value_for_a  #2.
    print "Here's the inspect-string for 'self'"  #3.
    p self
    puts "And here's a:"
    puts a
    if recurse  #4.
      puts "Calling myself (recursion)..."  
      x("Second value for a")
      #5.^
      puts "Back after recursion; here's a:"   #6.
      puts a
    end
  end
end
c = C.new
c.x("First value for a", true)   #7.
```
The instance method `C#x` takes two arguments: a value to sign to the variable `a` and a flag telling the method whether to call itself(#1). (The use of the flag provides a way to prevent infinite recursion.) The first line of the method initializes `a` (#2), and the next several lines of the method print out the string representation of self and the value of `a`.

Now comes the decision: to recurse, or not to recurse. It depends on the value of the `recurse` variable (#4.). If the recursion happens, it calls `x` without specifying a value for the `recurse` parameter (#5); that parameter will default to `false`, and recursion won't happen the second time through.

The recursive call uses a different value for the `value_for_a` argument; therefore, different information will be printed out during that call. But upon returning from the recursive call, we find that the value of `a` in this run of `x` hasn't changed (#6). In short, every call to `x` generates a new local scope, even though self doesn't change.

The output from calling `x` on an instance of `C` and setting the `recurse` flag to true (#7), looks like this:

```irb
Here's the inspect-string for 'self'#<C:0x00000001ed2208>
And here's a:
First value for a
Calling myself (recursion)...
Here's the inspect-string for 'self'#<C:0x00000001ed2208>
And here's a:
Second value for a
Back after recursion; here's a:
First value for a
```

There's no change to self, but the local variables are reset.

### **TIP** ###
Instead of printing out the default string representation of an object, you can also use the `object_id` method to identify the object uniquely. Try changing `p self` to `puts self.object_id` and `puts a` to `puts a.object_id` in the previous example.

If this listing seems like the long way around to making the point that every method call has its own local scope, think of it as a template or model for the kinds of demonstrations you might try yourself as you develop an increasingly fine-grained sense of how scope and self work, separately and together.

### **NOTE** ###
It's also possible to do the opposite of what's listed in above example demonstrates- namely, to change self without entering a new local scope. This is accomplished with the `instance_eval` and `instance_exec` methods, which we'll look at later.

Like variables, constants are governed by rules of scope. We'll look next at how those rules work.

### *Scope and resolution of constants* ###
As you've seen, constants can be defined inside class- and method-definition blocks. If you know the chain of nested definitions, you can access a constant from anywhere. Consider this nest:

```ruby
module M
  class C
    class D
      module N
        X = 1
      end
    end
  end
end
```

You can refer to the module `M`, the class `M::C`, and so forth, down to the simple constant `M::C::D::N::X` (which is equal to 1).

Constants have a kind of global visibility or reachability: as long as you know the path to a constant through the classes and/or modules in which it's nested, you can get to that constant. Stripped of their nesting, however, constants definitely aren't globals. The constant `X` in one scope isn't the constant `X` in another:

```ruby
module M
  class C
    X = 2
    class D
      module N
        X = 1
      end
    end
  end
end
puts M::C::D::N::X    #1.
puts M::C::X #2.
```

As per the nesting, the first `puts` (#1); the second (#2) gives you 2. A particular constant identifier (like `X`) doesn't have an absolute meaning the way a global variable (like `$x`) does.

*Constant lookup*- the process of resolving a constant identifier, or finding the right match for it-bears a close resemblance to searching a file system for a file in a particular directory. For one thing, constants are identified relative to the point of execution. Another variant of our example illustrates this:

```ruby
module M
  class C
    class D
      module N
        X = 1
      end
    end
    puts D::N::X #<-- Output 1
  end
end
```

Here the identifier `D::N::X` is interpreted relative to where it occurs; inside the definition block of the class `M::C`. From `M::C`'s perspective, `D` is just one level away. There's no need to do `M::C::D::N::X`, when just `D::N::X` points the way down the path to the right constant. Sure enough, we get what we want: a printout of the number 1.

#### FORCING AN ABSOLUTE CONSTANT PATH ####
Sometimes you don't want a relative path. Sometimes you really want to start the constant-lookup process at the top level-just as you sometimes need to use an absolute path for a file.

This may happen if you create a class or module with a name that's similar to the name of a Ruby built-in class or module. For example, Ruby comes with a `String` class. But if you create a `Violin` class, you may also have `Strings`:

```ruby
class Violin
  class String
    attr_accessor :pitch
    def initialize(pitch)
      @pitch = pitch
    end
  end
  def initialize
    @e = String.new("E")   #1.
    @a = String.new("A")
    @d = String.new("D")
    @g = String.new("G")
  end
end
```

The constant `String` in this context(#1) resolves to `Violin::String`, as defined. Now let's say that elsewhere in the overall `Violin` class definition, you need to refer to Ruby's built-in `String` class. If you have a plain reference to `String`, it resolves to `Violin::String`. To make sure you're referring to the built-in original `String` class, you need to put the constant path separator `::` (double colon) at the beginning of the class name:

```ruby
def history
  ::String.new(maker + ", " + date)
end
```

This way, you get a Ruby `String` object instead of a `Violin::String` object. Like the slash at the beginning of a pathname, the `::` in front of a constant means "start the search for this at the top level." (Yes, you could just piece the string together inside the double quotes, using interpolation, and bypass `String.new`. But then we wouldn't have such a vivid name-clash example!)

In addition to constants and local, instance, and global variables, Ruby also features *class variables*, a category of identifier with some idiosyncratic scoping rules.
