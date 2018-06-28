# *Object Individuation* #
One of the cornerstones of Ruby's design is object individuation-that is, the ability of individual objects to behave differently from other objects of the same class. Every object is a full-fledged citizen of the runtime world of the program and can live the life it needs to.

The freedom of objects to veer away from the conditions of their birth has a kind of philisophical ring to it. On the other hand, it has 
some important technical implications. A remarkable number of Ruby features and characteristics derive from or converge on the 
individuality of objects. Much of Ruby is engineered to make object individuation possible. Ultimately, the individuation is more 
important than engineering: Matz has said over and over again that the principle of object individuality is what matters, and how Ruby 
implements it is secondary. Still, the implementation of object individuation has some powerful and useful components.

We'll look in this chapter at how Ruby goes about allowing objects to acquire methods and behaviors on a per-object basis, and how the
parts of Ruby that make per-object behavior possible can be used to greater advantage. We'll start by examining in detail *singleton
methods*-methods that belong to individual objects-in the context of *singleton classes,* which is where singleton-method definitions are 
stored. We'll then discuss class methods, which are at heart singleton methods attached to class objects. Another key technique in 
crafting per-object behavior is the `extend` method, which does something similar to module inclusion but for one object at a time. We'll 
look at how you can use `extend` to individuate your objects.

Perhaps the most crucial topic connected in any way with object individuation is changing the core behavior of Ruby classes. Adding a  
method to a class that already exists, such as `Array` or `String`, is a form of object individuation, because classes are objects. It's a 
powerful and risky technique. But there are ways to do it with comparatively little risk-and ways to do it per object (adding a behavior
to one string, rather than to the `String` class)-and we'll walk through the landscape of runtime core changes with an eye to how per-
object techniques can help you get the most out of Ruby's sometimes surprisingly open class model.

Finally, we'll renew an earlier acquaintance: the `BasicObject` class. `BasicObject` instances provide about the purest laboratory imaginable for creating individual objects, and we'll consider how that class and object individuation complement each other.

## *Where the singleton methods are: The singleton class* ## 
Most of what happens in Ruby involves classes and modules, containing definitions of instance methods:

```ruby
class C
  def talk 
    puts "Hi!"
  end
end
```
and subsequently, the instantiation of classes and the calling of those instance methods:

```ruby 
c = C.new 
c.talk   #<---Output: Hi!
```
But as you saw earlier (even earlier than you saw instance methods inside classes), you can also define singleton methods directly onto individual objects:

```ruby 
obj = Object.new 
def obj.talk 
  puts "Hi!"
end
obj.talk  #<---- Output: Hi!
```
And you've also seen that the most common type of singleton method is the class method-a method added to a `Class` object on an individual basis:

```ruby 
class Car 
  def self.makes 
    %w{ Honda Ford Toyota Chevrolet Volvo }
  end
end
```
But any object can have singleton methods added to it. (Almost any object; see side-bar.) The ability to define behavior on a per-object basis is one of the hallmarks of Ruby's design.

**Some objects are more individualizable than others** 
Almost every object in Rby can have methods added to it. The exceptions are instances of certain `Numeric` subclasses, including integer classes and floats, and symbols. If you try this:

`def 10.some_method; end` 

you'll get a syntax error. If you try this:

`class << 10; end`

you'll get a type error and a message saying "Can't define singleton." The same is true, in both cases, of floating-point numbers and symbols.

--
Instance methods-those available to any and all instances of a given class-live inside a class or module, where thy can be found by the objects that are able to call them. But what about isngleton methods? Where does a method live, if that method exists only to be called by a single object?

### *Dual determination through singleton class* ###
Ruby, true to character, has a simple answer to this tricky question: an object's singleton methods live in the object's *singletong class.* Every object ultimately has two classes:

• The class of which it's an instance 

• Its singleton class

An object can call instance methods from its original class, and it can also call methods from its singleton class. It has both. The method-calling capabilities of the object account, all together, to the sum of all the instance methods defined in these two classes, along with methods available through ancestral classes (the superclass of the object's class, that class's superclass, and so forth) or through any modules that have been mixed in or prepended to any of these classes. You can think of an object's singleton class as an exclusive stash of methods, tailor-made for that object and not shared with other object's-not even with other instances of the object's class. 

### *Examining and modifying a singleton class directly* ### 
Singleton classes are anonymous although they're class objects (instances of the class `Class`), they spring up automatically without being given a name. Nonetheless, you can open the class-definition body of a singleton class and add instance methods, class methods, and constants to it, as you would with a regular class.

You do this with a special form of the `class` keyword. Usually, a constant follows that keyword:

```ruby
class C
  # method and constant definitions here
end
```
But to get inside the definition body of a singleton class, you use a special notation:

```ruby
class << object
  # method and constant definitions here
end
```

The *<< object* notation means the anonymous, singleton class of `object`. When you're inside the singleton class-definition boyd, you can define methods-and these methods will be singleton methods of the object whose singleton class you're in.

Consider this program, for example:

```ruby 
str = "I am a string"
class << str 
  def twice
    self + " " + self 
  end
end
puts str.twice
```
The output is

`I am a string I am a string`

The method `twice` is a singleton method of the string `str`. It's exactly was if we had done this:

```ruby 
def str.twice 
  self + " " + self
end
```
The difference is that we've pried open the singleton class of `str` and defined the method there. 

**The difference between def obj.meth and class << obj; def meth** 
This question often arises: Is there any difference between defining a method directly on an object (using the `def obj.some_method` notation) and adding a method to an object's singleton class explicitly (by doing `class << obj; def some_method`)? The answer is that there's one difference: constants are resolved differently.

If you have a top-level constant `N`, you can also define an `N` inside an object's singleton class:

```ruby 
N = 1
obj = Object.new
class << obj
  N = 2
end
```
Given this sequence of instructions, the two ways of adding a singleton method to `obj` differ in which `N` is visible from within the method definition body:

```ruby
def obj.a_method
  puts N
end
class << obj
  def another_method
    puts N
  end
end

obj.a_method            #<--- Output: 1 (outer-level N)
obj.another_method      #<--- Output: 2 (N belonging to obj's singleton class)
```
It's relatively unusual for this difference in the visibility of constants to affect your code; in most circumstances, you can regard the two notations for singleton-method definition as interchangeable. But it's worth knowing about the difference, because it may matter in some situations and it may also explain unexpected results.

---
The `class << object` notation has a bit of a reputaiton as cryptic or confusing. It needn't be either. Think of it this way: it's the `class` keyword, and it's willing to accept either a constant or a `<< object` expression. What's new here is the ocncept of the singleton class. When you're comfortable with the idea that objects have singleton classes, it makes sense for you to be able to open those classes with the `class` keyword. The `<< object` notation is the way the concept "singleton class of object" is expressed when `class` requires it.

By far the most frequent use of the `class << object` notation for entering a singleton method class is in connection with class-method definitions.

#### DEFINING CLASS METHODS WITH CLASS << ####
Here's an idiom you'll see often:

```ruby 
class Ticket 
  class << self 
    def most_expensive(*tickets)
      tickets.may_by(&:price)
    end 
  end
end
```
This code results in the creation of the class method `Ticket.most_expensive`-much the same method as the one defined in chapter 3, but that time around we did this:

`def Ticket.most_expensive(*tickets)` # etc.

In the current version, we're using the `class << object` idiom, opening the singleton class of the object; and in this particular case, the object involved is the class object `Ticket`, which is the value of `self` at the point in the code where `class << self` is invoked. The result of defining the method `most_expensive` inside the class-definition block is that it gets defined as a singleton method on `Ticket`-which is to say, a class method.

The same class method could also be defined like this (assuming this code comes at a point in the program where the `Ticket` class already exists):

```ruby 
class << Ticket 
  def most_expensive(tickets)
  # etc.
end
```
Because `self` is `Ticket` inside the `class Ticket` definition body, `class << self` *inside* the body is the same as `class << Ticket` *outside* the body. (Technically, you could even do `class << Ticket` inside the body of class `Ticket`, but in practice you'll usually see `class << self` whenever the object whose singleton class needs opening is `self`.)

THe fact that `class << self` shows up frequently in connection with the creation of class methods sometimes leads to the false impression that the `class << object` notation can only be used to create class methods, or that the only expression you can legally put on the right is `self`. In fact, `class << self` inside a class-definition block is just one particular use case for `class << object`. The technique is general: it puts you in a definition block for the singleton class of `object`, whatever `object` may be.

In chapter 4, we looked at hte steps an object takes as it looks for a method among those defined in its class, its class's class, and so forth. Now we have a new item on the radar: the singleton class. What's the effect of this extra class on the method lookup process?

### *Singletone classes on the method-lookup path* ### 
Recall that method searching goes up the class-inheritance chain, with detours for any modules that have been mixed in or prepended. When we first discussed this process, we hadn't talked about singleton classes and methods, and they weren't present in the diagram. Now we can revise the diagram to encompass them, as shown in the figure. (see book p 395). 

The box containing `class << object` represents the singleton class of `object`. In its search for the method `x`, `object` looks first for any modules prepended to its singleton class; then it looks in the singleton class itself. It then looks in any modules that the singleton class has included. (In the diagram, there's one: the module `N`.) Next the search proceeds up to the object's original class (class `D`), and so forth. 

Note in particular that it's possible for a singleton class to prepend or include a module. After all, it's a class.

```ruby
# See book for diagram - this isn't quite right
class BasicObject
  module Kernel
  class Object
    include Kernel
    class C
      module N
      end
      class D < C
        module M
          module Y
        end
        prepend M
        include N
        class << object
          module X
          prepend X
          include Y
        end
      end
    end
  end
end

object = D.new 
object.x
```

#### INCLUDING A MODULE IN A SINGLETON CLASS ####
Let's build a little program that illustrates the effect of including a module ina singleton class. We'll start with a simple `Person` class and a couple of instances of that class:

```ruby 
class Person
  attr_accessor :name
end
david = Person.new
david.name = "David"
matz = Person.new 
matz.name = "Matz"
ruby = Person.new
ruby.name = "Ruby"
```
Now let's say that osme persons-that is, some `Person` objects-don't like to reveal their names. A logical way to add this kind of secrecy to individual objects is to add a singleton version of the `name` method to each of those objects:

```ruby
def david.name
  "[not available]"
end
```
At this point, Matz and Ruby reveal their names, but David is being secretive. When we do a roll call:

```ruby
puts "We've got one person named #{matz.name}, "
puts "one named #{david.name}, "
puts "and one named #{ruby.name}"
```
we get only two names:

```irb
We've got one person named Matz,
one named [not available],
and one named Ruby
```
So far, so good. But what if more than one person decides to be secretive? It would be a nuisance to have to write `def person.name`... for every such person.

The way around this is to use a module. Here's what the module looks like:

```ruby
module Secretive
  def name
    "[not available]"
  end
end
```
Now, let's make Ruby secretive. Instead of using `def` to define a new version of the `name` method, we'll include the module in Ruby's singleton class:

```ruby
class << Ruby 
  include Secretive
end
```
The roll call now shows that Ruby has gone over to the secretive camp; running the previous `puts` statements again produces the following output:

```irb
We've got one person named Matz,
one named [not available],
and one named [not available]
```
What happened in Ruby's case? We sent the message "name" to the object `ruby`. The object set out to find the method. First it looked in its own singleton class, where it didn't find the `name` method. Then it looked in the modules mixed into its singleton class. The singleton class of `ruby` mixed in the `Secretive` module, and, sure enough, that module contains an instance method called `name`. At that point, the method gets executed.

Given an understanding of the order in which objects search their lookip paths for methods, you can work out which version of a method (thiat is, which class or module's version of the method) an object will find first. Examples help, too, especially to illustrate the difference between including a module in a singleton class and in a regular class.

#### SINGLETONE MODULE INCLUSION VS. ORIGINAL-CLASS MODULE INCLUSION #### 
WHen you mix a module into an object's singleton class, you're dealing with that object specifically; the methods it learns from the module take precedence over any methods of the same name in its original class. The following listing shows the mechanics and outcomes of doing this kind of `include` operation.

```ruby 
class C
  def talk
    puts 'Hi from original class!'
  end
end

module M
  def talk
    puts "Hello from module!"
  end
end

c = C.new
c.talk            #<----- 1.

class << c
  include M         #<------ 2. 
end
c.talk                  #<------ 3.
```
The output from this listing is as follows:

```irb 
Hi from original class!
Hello from module!
```
The first call to `talk` (#1) executes the `talk` instance method defined in `c`'s class, `C`. Then, we mix the module `M`, which also defines a method called `talk`, into `c`'s singleton class (#2). As a result, the next time we call `talk` on `c` (#3), the `talk` that gets executed (the one that `c` sees first) is the one defined in `M`.

It's all a matter of how the classes and modules on the object's method lookip path are stacked. Modules included in the singleton class are encountered before the original class and before any modules included in the original class. 

You can see this graphically by using the `ancestors` method, which gives you a list of the classes and modules in the inheritance and inclusion hierarchy of any class or module. Starting from after the class and module definitions in the previous example try using `ancestors` to see what the hierarchy looks like:

```ruby 
c = C.new
class << c
  include M
  p ancestors
end
```
You get an array of ancestors-essentially, the method-lookup path for instances of this class. Because this is the singleton class of `c`, looking at its ancestors means looking at the method lookup path for `c`. Note that `c`'s singleton class comes first in the ancestor list:

```irb 
[#<Class:Object>, #<Class:BasicObject>, Class, Module, Object, M, Kernel, BasicObject]
```
Now look what happens when you not only mix `M` into the singleton class of `c` but also mix it into `c`'s class (`C`). Picking up after the previous example:

```ruby 
class C
  include M
end
class << c
  p ancestors
end
```
This time you see the following result:

```irb 
[#<Class:#<C:0x000000026e2ce0>>, C, M, Object, Kernel, BasicObject]
```
The module `M` appears twice! Two different classes-the singleton class of `c` and the class `C`-have mixed it in. Each mix-in is a separate transaction. It's the private business of each class; the classes don't consult with each other. (You could even mix `M` into `Object` and you'd get it three times in the ancestors list.)

You're encouraged to take these examples, modify them, turn them this way and that, and examine the results. Classes are objects, too-so see what happens when you take the singleton class of an object's singleton class. What about mixing modules into other modules? Try some examples with `prepend` too. Many permutations are possible; you can learn a lot through experimentation, using what we've covered here as a starting point.

The main lesson is that per-object behavior in Ruby is based on teh same principles as regular, class-derived object behavior: the definition of instance methods in classes and modules, the mixing in of modules to classes, and the following of a method-lookip path consisting of classes and modules. If you master these concepts and revert to them whenever something seems fuzzy, your understanding will scale upward successfully.

### *The singleton_class method* ###

### *Class methods in (even more) depth* ###

**SINGLETONE CLASSES AND THE SINGLETON PATTERN** 

## *Modifying Ruby's core classes and modules* ## 

### *The risks of changing core functionality* ### 

#### CHANGING REGEXP#MATCH (AND WHY NOT TO) ####

**NOTE**

#### THE RETURN VALUE OF STRING#GSUB! AND WHY IT SHOULD STAY THAT WAY ####

**The tap method**

### *Additive changes* ### 

### *Pass-through overrides* ### 

**Aliasing and its aliases** 

#### ADDITIVE/PASS-THROUGH HYBRIDS #### 

### *Per-object changes with extend* ###

#### ADDING TO AN OBJECT'S FUNCTIONALITY WITH EXTEND ####

#### ADDING CLASS METHODS WITH EXTEND ####

#### MODIFYING CORE BEHAVIOR WITH EXTEND ####

### *Using refinements to affect core behavior* ###

## *BasicObject as ancestor and class* ##

### *Using BasicObject* ###

### *Implementing a subclass of BasicObject* ###
