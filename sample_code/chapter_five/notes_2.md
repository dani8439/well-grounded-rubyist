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

### *Class variable syntax, scope, and visibility* ###
Class variables begin with two at signs-for example, `@@var`. Despite their name, class variables aren't class scoped. Rather, they're class-hierarchy scoped, except...sometimes. Don't worry; we'll go through the details. After a look at how class variables work, we'll evaluate how well they fill the role of maintaining state for a class.

### CLASS VARIABLES ACROSS CLASSES AND INSTANCES ###
At its simplest, the idea behind a class variable is that it provides a storage mechanism that's shared between a class and instances of that class, and that's not visible to any other objects. No other entity can fill this role. Local variables don't survive the scope change between class definitions and their inner method definitions. Globals do, but they're also visible and mutable everywhere else in the program, not just in one class. Constants likewise: instance methods can see the constants defined in the class in which they're defined, but the rest of the program can see those constants, too. Instance variables, of course, are visible strictly per object. A class isn't the same object as any of its instances, and no two of its instances are the same as each other. Therefore, it's impossible, by definition, for a class to share instance variables with its instances.

So class variables have a niche to fill visibility to a class and its instances, and to no one else. Typically, this means being visible in class-method definitions and instance-method definitions, and sometimes at the top level of the class definition.

Here's an example: a little tracker for cars. Let's start with the trial run and the output; then, we'll look at how the program works. Let's say we want to register the makes (manufacturer names) of cars, which we'll do using the class method `Car.add_make(make)`. Once a make has been registered, we can create cars of that make, using `Car.new(make)`. We'll register Honda and Ford, and create two Hondas and one Ford:

```ruby
Car.add_make("Honda")
Car.add_make("Ford")
h = Car.new("Honda")
f = Car.new("Ford")
h2 = Car.new("Honda")
```
The program tells us which cars are being created:

```irb
Creating a new Honda!
Creating a new Ford!
Creating a new Honda!
```

At this point, we can get back some information. How many cars are there of the same make as `h2`? We'll use the instance method `make_makes` to find out, interpolating the result into a string:

```ruby
puts "Counting cars of same make as h2..."
puts "There are #{h2.make_mates}."
```

As expected, there are two cars of the same make as `h2` (namely, Honda).
How many cars are there altogether? Knowledge of this kind resides in the class, not in the individual cars, so we ask the class:

```ruby
puts "Counting total cars..."
puts "There are #{Cars.total_count}."
```

The output is:

```irb
Counting total cars...
There are 3.
```

Finally, we try to create a car of nonexistent make:

```ruby
x = Car.new("Brand X")
```

The program doesn't like it, and we get a fatal error:

```irb
car.rb:21:in `initialize'L No such make: Brand X. (RuntimeError)`
(car.rb:39:in `<main>': uninitialized constant Cars (NameError)
Did you mean?  Car)
```

The main action here is in the creation of cars and the ability of both individual cars and the `Car` class to store and return statistics about the cars that have been created. The next listing shows the program. If you save this listing and then add the previous sample code to the end of the file, you can run the whole file and see the output of the code. (Duh)

```ruby
class Car
  @@makes = []                                    #1.
  @@cars = {}                                     #1.
  @@total_count = 0                               #1.
  attr_reader :make                               #2.
  def self.total_count                            #3.
    @@total_count
  end
  def self.add_make(make)                         #4.
    unless @@makes.include?(make)
      @@makes << make
      @@cars[make] = 0
    end
  end
  def initialize(make)
    if @@makes.include?(make)
      puts "Creating a new #{make}!"
      @make = make                                #5.
      @@cars[make] += 1                           #6.
      @@total_count += 1                  
    else      
      raise "No such make: #{make}."              #7.
    end
  end
  def make_mates                                  #8.
    @@cars[self.make]
  end
end
```

The key to the program is the presence of the three class variables defined at the top of the class definition(#1). `@@makes` is an array and stores the names of makes. `@@cars` is a *hash:* a keyed structure whose keys are makes of cars and whose corresponding values are counts of how many of each make there are. Finally, `@@total_count` is a running tally of how many cars have been created overall.

The `Car` class also has a `make` reader attribute(#2), which enables us to ask every car what its make is. The value of the `make` attribute must be set when the car is created. There's no writer attributes for makes of cars, because we don't want code outside the class changing the makes of cars that already exist.

To provide access to the `@@total_count` class variable, the `Car` class defines a `total_count` method(#3), which returns the current value of the class variable. There's also a class method called `add_make`(#4); this method takes a single argument and adds it to the array of known makes of cars, using the << array-append operator. It first takes the precaution of making sure the array of makes doesn't already include that particular make. Assuming all is well, it adds the make and also sets the counter for this make's car tally to zero. Thus when we register the make Honda, we also establish the fact that zero Hondas exist.

Now we get to the `initialize` method, where new cars are created. Each new car needs a make. If the make doesn't exist (that is, if it isn't in the `@@makes` array), then we raise a fatal error(#7). If the make does exist, then we set this car's `make` attribute to the appropriate value(#5), increment by one the number of cars this make that are recorded in the `@@cars` hash(#6), and also increment by one the total number of existing cars stored in `@@total_count`. (You may have surmised that `@@total_count` represents the total of all the values in `@@cars`. Storing the total separately saves us the trouble of adding up all the values every time we want to see the total.) There's also an implementation of the instance method `make_mates`(#8), which returns a list of all cars of a given car's make.

The `initialize` method makes heavy use of the class variables defined at the top, outer level of the class-definition- a totally different local scope from the inside of `initialize`, but not different for purposes of class-variable visibility. Those class variables were also used in the class methods `Car.total_count` and `Car.add-make`-each of which also has its own local scope. You can see the class variables follow their own rules: their visibility and scope don't line up with those of local variables, and they cut across multiple values of self. (Remember that at the outer level of a class definition and inside the class methods, self is the class object-`Car`-whereas in the instance methods, self is the instance of `Car` that's calling the method).

So far, we've seen the simplest aspects of class variables. Even at this level, opinions differ as to whether, or at least how often, it's a good idea to create variables that cut this path across multiple self objects. Does the fact that a car is an instance of `Car` really mean that the `car` object and the `Car` class object need to share data? Or should they be treated throughout like the two separate objects they are?

There's no single (or simple) answer. But there's a little more to how class variables work; and at the very least, you'll probably conclude that they should be handled with car.


### CLASS VARIABLES AND THE CLASS HIERARCHY ###
As noted earlier, class variables aren't class-scoped variables. They're class-hierarchy-scoped variables.

Here's an example. What would you expect the following code to print?

```ruby
class Parent
  @@value = 100        #<--- Sets class variable in class Parent.
end
class Child < Parent
  @@value = 200        #<--- Sets class variable in class Child, a subclass of Parent.
end
class Parent
  puts @@value        #<--- Back in Parent class: what's the output?
end
```

What gets printed is 200. The `Child` class is a subclass of `Parent`, and that means `Parent` and `Child` share the same class variables-not different class variables with the same names, but the same actual variables. When you assign to `@@value` in `Child`, you're setting the one and only `@@value` variable that's shared throughout the hierarchy-that is, by `Parent` and `Child` and any other descendant classes of either of them. The term *class variable* becomes a bit difficult to reconcile with the fact that two (and potentially a lot more) classes share exactly the same ones.

As promised, we'll end this section with a consideration of the pros and cons of using class variables as a way to maintain state in a class.
