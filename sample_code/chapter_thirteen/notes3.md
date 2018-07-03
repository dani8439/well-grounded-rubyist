### *Per-object changes with extend* ###
`Object#extend` is a kind of homecoming in terms of topic flow. We've wandered to the outer reaches of modifying core classes-and `extend` brings us back to the central process at the heart of all such changes: changing the behavior of an individual object. It also brings us back to an earlier topic from this chapter: the mixing of a module into an object's singleton class. That's essentially what `extend` does. 

#### ADDING TO AN OBJECT'S FUNCTIONALITY WITH EXTEND ####
Have another look at the earlier section and inparticular the `Person` example where we mixed the `Secretive` module into the singleton classes of some `Person` object. As a reminder, the technique was this (where `ruby` is a `Person` instance):

```ruby
class << ruby 
  include Secretive
end
```
Here's how the `Person` example would look, using `extend` instead of explicitly opening up the singleton class of the `ruby` object. Let's also use `extend` for `david` (instead of the singleton method definition with `def`):

```ruby 
module Secretive
  def name
    "[not available]"
  end
end
class Person
  attr_accessor :name
end
david = Person.new
david.name = "David"
matz = Person.new
matz.name = "Matz"
ruby = Person.new
ruby.name = "Ruby"
david.extend(Secretive)     #<---1.
ruby.extend(Secretive)
puts "We've got one person named #{matz.name}, " + "one person named #{david.name}, " + "and one named #{ruby.name}."

# We've got one person named Matz, one person named [not available], and one named [not available].
```
Most of this program is the same as the first version, as is the output. The key difference is the use of `extend` (#1), which has the effect of adding the `Secretive` module to the lookup paths of the individual objects `david` and `ruby` by mixing into their respective singleton classes. That inclusion process happens when you extend a class object, too.

#### ADDING CLASS METHODS WITH EXTEND ####
If you write a singleton method on a class object, like so

```ruby 
class Car 
  def self.makes 
    %w{ Honda Ford Toyota Chevrolet Volvo}
  end
end
```
or like so

```ruby 
class Car 
  class << self 
    def makes 
      %w{ Honda Ford Toyota Chevrolet Volvo}
    end 
  end 
end
```

or write any of the other notational variants available, you're adding an instance method to the singleton class of the class object. It follows that you can achieve this, in addition to the other ways, by using `extend`: 

```ruby 
module Makers 
  def makes 
    %w{ Honda Ford Toyota Chevrolet Volvo }
  end 
end 
class Car
  extend Makers 
end
```
If it's more appropriate in a given situation, you can extend the class object after it already exists:

`Car.extend(Makes)`

Either way, the upshot is that the class object `Car` now has access to the `makes` method. 

As with non-class objects, extending a class object with a module means mixing the module into the class's singleton class. You can verify this with the `ancestors` method:

`p Car.singleton_class.ancestors`

The output from this snippet is

`[#<Class:Car>, Makers, #<Class:Object>, #<Class:BasicObject>, Class, Module, Object, Kernel, BasicObject]`

The odd-looking entries in the list are singleton classes. The singleton class of `Car` itself is included; so are the singleton class of `Object` (which is the superclass of the singleton class of `Car`) and the singleton class of `BasicObject` (which is the superclass of the singleton class of `Object`). The main point for our purpose is that `Makers` is included in the list.

Remember too that subclasses have access to their superclass's class methods. If you subclass `Car` and look at the ancestors of the new class's singleton class, you'll see `Makers` in the list.

Our original purpose in looking at `extend` was to explore a way to add to Ruby's core functionality. Let's turn now to that purpose.

#### MODIFYING CORE BEHAVIOR WITH EXTEND ####
You've probably put the pieces together by this point. Modules let you define self-contained reusable collections of methods. `Kernel#extend` lets you give individual objects access to modules, courtesy of the singleton class and the mix-in mechanism. Put it all together, and you have a compact, safe way of adding functionality to core objects.

Let's take another look at the `String#gsub!` conundrum-namely, that it returns `nil` when the string doesn't change. By defining a module and using `extend`, it's possible to change `gsub!`'s behavior in a limited way, making only the changes you need and no more. Here's how:

```ruby 
module GsubBangModifier
  def gsub!(*args, &block)
    super || self             #<----1.
  end
end
str = "Hello there!"
str.extend(GsubBangModifier)      #<----2.
str.gsub!(/zzz/, "abc").reverse!      #<----3.
puts str

# Output: !ereht olleH
```
On the module `GsubBangModifier`, we define `gsub!`. Instead of the alias-and-call technique, we call `super`, returning either the value returned by that call or `self`-the latter if the call to `super` returns `nil` (#1). (You'll recall that `super` triggers execution of the next version of the current method up the method-lookup path. Hold that thought....)

Next, we create a string `stri` and extend it with `GsubBangModifier` (#2). Calling `str.gsub!` (#3) executes the `gsub!` in `GsubBangModifier`, becauuse `str` encounters `GsubBangModifier` in its method-lookup path before it encounters the class `String`- which, of course, also contains a `gsub!` definition. The call to `super` inside `GsubBangModifier#gsub!` jumps up the path and executes the original method, `String#gsub!` passing it the original arguments and code block, if any. (That's the effect of calling `super` with no arguments and no empty argument list.) And the result of the call to `super` is either the string itself or `nil`, depending on whether any changes were made to the string.

Thus you can change the behavior of core objects-strings, arrays, hashes, and so forth-without reopening their classes and without introducing changes on a global level. Having calls to `extend` in your code helps show what's going on. CHanging a method like `gsub!` inside the `String` class itself has the disadvantage not only of being global but also of being likely to be stashes away in a library file somewhere, making bugs hard to track down for people who get bitten by the global change.

There's one more important piece of the puzzle of how to change core objects behaviors: a new feature called *refinements*. 

### *Using refinements to affect core behavior* ###
Refinements were added to Ruby 2.0, but were considered "experimental" until the 2.1 release. The idea of a refinement is to make a temporary, limited-scope change to a class (which can, though needn't, be a core class).

Here's an example, in which a `shout` method is introduced to the `String` class but withou only a limited basis:

```ruby 
module Shout
  refine String do        #<---1.
    def shout
      self.upcase + "!!!"
    end
  end
end

class Person
  attr_accessor :name

  using Shout           #<----2.

  def announce
    puts "Announcing #{name.shout}"
  end
end

david = Person.new
david.name = "David"
david.announce

#Output:  Announcing DAVID!!!
```
Two different methods appear here, and they work hand in hand: `refine` (#1) and `using` (#2). The `refine` method takes a class name and a code block. Inside the code block you define the behaviors you want the class you're refining to adopt. In our example, we're refining the `String` class, adding a `shout` method that returns an upcased version of the string followed by three exclamation points.

The `using` method flips the switch: once you "use" the module in which you've defined the refinement you want, the target class adopts the new behaviors. In the example, we use the `Shout` module inside the `Person` class. That means that for the duration of that class (from the `using` statement to the end of the class definition), strings will be "refined" so that they have the `shout` method.

The effect of "using" a refinement comes to an end with the end of the class (or module) definition in which you declare you're using the refinement. You can actually use `using` outside of a class or module definition, in which case the effect of the refinement persists to the end of the file in which the call to `using` occurs. 

Refinements can help you make temporary changes to core classes in a relatively safe way. Other program files and libraries your program uses at runtime will not be affected by your refinements.

We'll end this chapter with a look at a slightly oddball topic: the `BasicObject` class. `BasicObject` isn't exclusitvely an object-individuation topic (as you know from having read the introductory material about it in chapter 3). But it pertains to the ancestroy of all objects-including those whose behavior branches away from their original classes-and can play an important role in the kind of dynamism that Ruby makes possible. 

## *BasicObject as ancestor and class* ##

### *Using BasicObject* ###

### *Implementing a subclass of BasicObject* ###
