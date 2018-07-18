# *Callbacks, hooks, and runtime introspection* #
In keeping with its dynamic nature and its encouragement of flexible, supple object and program design, Ruby provides a large number of ways to examine what's going on while your program is running and to set up event-based callbacks and hooks-essentially, tripwires that are pulled at specified times and for specific reasons-in the form of methods with special, reserved names for which you can, if you wish, provide definitions. Thus you can rig a module so that a particular method gets called every time a class includes that module, or write a callback method for a class that gets called every time the class is inherited, and so on.

In addition to runtime callbacks, Ruby lets you perform more passive but often critical acts of examination: you can ask objects what methods they can execute (in even more ways than you've seen already) or what instance variables they have. You can query classes and modules for their constants and their instance methods. You can examine a stack trace to determine what method calls got you to a particular point in your program-and you even get access to the filenames and line numbers of all the method calls along the way.

In short, Ruby invites you to the party: you get to see what's going on, in considerable detail, via techniques for runtime introspection; and you can order Ruby to push certain buttons in reaction to runtime events. This chapter, the last in the book, will explore a variety of these introspective and callback techniques and will equip you to take ever greater advantage of the facilities offered by this remarkable, and remarkably dynamic, language.

## *Callbacks and hooks* ##
The use of *callbacks* and *hooks* is a fairly common meta-programming technique. These methods are called when a particular even takes place during the run of a Ruby program. An event is something like

• A nonexistent method being called on an object.

• A module being mixed in to a class or another module.

• An object being extended with a module.

• A class being subclasses (inherited from).

• A reference being made to a nonexistant constant.

• An instance method being added to a class.

• A singletone method being added to an object.

For every event in that list, you can (if you choose) write a callback method that will be executed when the event happens. These callback methods are per-object or per-class, not global; if you want a method called when the class `Ticket` gets subclasses, you have to write the appropriate method specifically for class `Ticket`.

What follows are descriptions of each of these runtime event hooks. We'll look at them in the order they're listed above.

### *Intercepting unrecognized messages with method_missing* ### 
Back in chapter 4 (Section 4.3) you learned quite a lot about `method_missing`. To summarize: when you send a message to an object, the object executes the first method it finds on its method-lookup path with the same name as the message. If it fails to find any such method, it raises a `NoMethodError` exception-unless you've provided the object with a method called `method_missing`. (Refer back to section 4.3 if you want to refresh your memory on how `method_missing` works.)

Of course, `method_missing` deserves a berth in this chapter too, because it's arguably the most commonly used runtime hook in Ruby. Rather than repeat chapter 4's coverage, though, let's look at a couple of specific `method_missing` nuances. We'll consider using `method_missing` as a delegation technique; and we'll look at how `method_missing` works, and what happens when you override it, at the top of the class hierarchy.

#### DELEGATING WITH METHOD_MISSING ####
You can use `method_missing` to bring about an automatic extension of thew ay your object behaves. For example, let's say you're modeling an object that in some respects is a container but that also has other characteristics-perhaps a cookbook. You want to be able to program your cookbook as a collection of recipes, but it also has certain characteristics (title, author, perhaps a list of people with whom you've shared it or who have contributed to it) that need to be stored and handled separately from the recipes. Thus the cookbook is both a collection and the repository of metadata about the collection.

To do this in a `method_missing` based way, you would maintain an array of recipes and then forward any unrecognized messages to that array. A simple implementation might look like this:

```ruby 
class Cookbook
  attr_accessor :title, :author
  def initialize
    @recipes = []
  end
  def method_missing(m, *args, &block)
    @recipes.send(m, *args, &block)
  end  
end
```
Now we can perform manipulations on the collection of recipes, taking advantage of any array methods we wish. Let's assume there's a `Recipe` class, separate from the `Cookbook` class, and we've already created some `Recipe` objects:

```ruby
cb = Cookbook.new
cb << recipe_for_cake
cb << recipe_for_chicken
beef_dishes = cb.select {|recipe| recipe.main_ingredient == "beef" }
```
The cookbook instance, `cb`, doesn't have methods called `<<` and `select`, so those messages are passed along to the `@recipes` arracy courtesy of `method_missing`. We can still define any methods we want directly in the `Cookbook` class-we can even override array methods, if we want a more cookbook-specific behavior for any of those methods-but `method_missing` saves us from having to define a parallel set of methods for handling pages as an ordered collection.

This use of `method_missing` is very straightforward (though you can mix and match it with some of the bells and whistles from chapter 4) but very powerful; it adds a great deal of intelligence to a class in return for little efford. Let's look now at the other end of the spectrum: `method_missing` not in a specific class, but at the top of the class tree at the top level of your code.

**Ruby's method-delegating techniques** 
In this `method_missing` example, we've *delegated* the processing of messages (the unknown ones) to the array `@recipes`. Ruby has several mechanisms for delegating actions from one object to another. We won't go into them here, but you may come across both the `Delegator` class and the `SimpleDelegator` class in your further encounters with Ruby.

#### THE ORIGINAL: BASICOBJECT#METHOD_MISSING ####
`method_missing` is one of the few methods defined at the very top class tree, in the `BasicObject` class. Thanks to the fact that all classes ultimately derive from `BasicObject`, all objects have a `method_missing` method.

The default `method_missing` is rather intelligent. Look at the difference between the error messages in these two exchanges in irb:

```irb 
>> a
NameError: undefined local variable or method `a' for main:Object
>> a?
NoMethodError: undefined method `a?' for main:Object
```
That unknown identifier `a` could be either a method or a variable (if it weren't unknown, that is); and though it gets handled by `method_missing`, the error message reflects the fact that Ruby can't ultimately tell whether you meant it as a method call or a variable reference. The second unknown identifier, `a?`, can only be a method, because variable names can't end with a question mark. `method_missing` picks up on this and refines the error message (and even the choice of which exception to raise).

It's possible to override the default `method_missing`, in either of two ways. First you can open the `BasicObject` class and redefine `method_missing`. The second, more common (though, admittedly, not all that common) technique is to define `method_missing` at the top level, thus installing it as a private instance method of `Object`.

If you use this second technique, all objects except actual instances of `BasicObject` itself will find the new version of `method_missing`:

```irb 
>> def method_missing(m,*args,&block)
>>    raise NameError, "What on earth do you mean by #{m}?"
>> end
=> :method_missing
>> a
NameError: What on earth do you mean by a?
      from (irb):2:in `method_missing'
>> BasicObject.new.a
NoMethodError: undefined method `a' for #<BasicObject:0x000000022e77f8>
```
(You can put a `super` call inside your new version, if you want to bounce it up to the version in `BasicObject`, perhaps after logging the error, instead of raising an exception yourself.)

Remember that if you define your own `method_missing`, you lose the intelligence that can discern variable naming from method naming:

```irb
>> a?
NameError: What on earth do you mean by a??
```
It probbaly doesn't matter, especially if you're going to call `super` anyway-and if you really want to, you can examine the details of the symbol `m` yourself. But it's an interesting glimpse into the subleties of the class hierarchy and the semantics of overriding.

#### METHOD_MISSING, RESPOND_TO?, AND RESPOND_TO_MISSING? #### 
An oft-cited problem with `method_missing` is that it doesn't align with `respond_to?` Consider this example. In the `Person` class, we intercept messages that start with `set_`, and transform them into setter methods: `set_age(n)` becomes `age=n` and so forth. For example:

```ruby
class Person 
  attr_accessor :name, :age 
  def initialize(name, age)
    @name, @age = name, age 
  end 
  
  def method_missing(m, *args, &block)
    if /set_(.*)/.match(m)
      self.send("#{$1}=", *args)
    else 
      super 
    end 
  end 
end
```
So does a person object have a `set_age` method, or not? Well, you can call that method, but the person object claims it doesn't respond to it:

```ruby
person = Person.new("David", 54)
person.set_age(55)      #<----55
p person.age
p person.respond_to?(:set_age)      #<----- false
```
The way to get `method_missing` and `respond_to?` to line up with each other is by defining the special method `respond_to_missing?`. Here's a definition you can add to the preceding `Person` class:

```
  def respond_to_missing?(m, include_private = false)
    /set_/.match(m) || super
  end
```
Now the new person object will respond differently given the same queries:

```irb 
55
true
```
You can control whether private methods are included by using a second argument to `respond_to?`. That second argument will be passed along to `respond_to_missing?`. In the example, it defaults to false.

As a bonus, methods that become visible through `respond_to_missing?` can also be objectified into method objects using `method`:

```ruby 
person = Person.new("David", 55)
p person.method(:set_age)   #<----- #<Method: Person#set_age>
```
Overall, `method_missing` is a highly useful event-trapping tool. But it's far from the only one. 

### *Trapping include and prepend operations* ### 
You know how to include a module in a class or other module, and you know how to prepend a module to a class or module. If you want to trap these events-to trigger a callback when the events occur-you can define special methods called `included` and `prepended`. Each of these methods receives the name of the including or prepending class or module as its single argument.

Let's look closely at `included`, knowing that `prepended` works in much the same way. You can do a quick test of `included` by having it trigger a message printout and then perform an `included` operation:

```ruby 
module M
  def self.included(c)
    puts "I have just been mixed into #{c}."
  end
end
class C
  include M
end
```
You see the message `"I have just been mixed indo C."` as a result of the execution of `M.included` when `M` gets included by (mixed into) `C`. (Because you can also mix modules into modules, the example would also work if `C` were another module.)

When would it be useful for a module to intercept its own inclusion like this? One commonly discussed case revolves around the difference between instance and class methods. When you mix a module into a class, you're ensuring that all the instance methods defined in the module become available to instances of the class. But the class object isn't affected. The following question often arises: What if you want to add class methods to the class by mixing in the module along with adding the instance methods?

Courtesy of `included`, you can trap the `included` operation and use the occasion to add class methods to the class that's doing the including. The following listing shows an example.

```ruby
module M
  def self.included(cl)
    def cl.a_class_method
      puts "Now the class has a new class method."
    end
  end
  def an_inst_method
    puts "This module supplies this instance method."
  end
end

class C
  include M
end
c = C.new
c.an_inst_method
C.a_class_method
```
The output from this listing is

```irb 
This module supplies this instance method.
Now the class has a new class method.
```
When class `C` includes module `M`, two things happen. First, an instance method called `an_instance_method` appears in the lookup path of its instances (such as `c`). Second, thanks to `M`'s `included` callback, a class method called `a_class_method` is defined for the class object `C`.

`Module#included` is a useful way to hook into the class/module engineering of your program. Meanwhile, let's look at another callback in the same general area of interest: `Module#extended`. 

### *Intercepting extend* ###
As you know from chapter 13, extending individual objects with modules is one of the most powerful techniques available in Ruby for taking advantage of the flexibility of objects and their ability to be customized. It's also the beneficiary of a runtime hook: using the `Module#extended` method, you can set up a callback that will be triggered whenever an object performs an `extended` operation that involves the module in question.

The next listing shows a modified verison of listing 15.1  that illustrates the workings of `Module#extended`.

```ruby 
module M
  def self.extended(obj)
    puts "Module #{self} is being used by #{obj}."
  end
  def an_inst_method
    puts "This module supplies this instance method."
  end
end

my_object = Object.new
my_object.extend(M)
my_object.an_inst_method
```
The output from this listing is:

```irb 
Module M is being used by #<Object:0x0000000210bc68>.
This module supplies this instance method.
```
It's useful to look at how the `included` and `extended` callbacks work in conjunction with singleton classes. There's nothing too surprising here; what you learn is how consistent Ruby's object and class model is.

#### SINGLETON-CLASS BEHAVIOR WITH EXTENDED AND INCLUDED ####
In effect, extending an object with a module is the same as including that module in the object's singleton class. Whichever way you describe it, the upshot is that the module is added to the object's method-lookup path, entering the chain right after the object's singleton class.

But the two operations trigger different callbacks: `extended` and `included`. The following listing demonstrates teh relevant behaviors.

```ruby 
module M
  def self.included(c)
    puts "#{self} included by #{c}."   #<----1.
  end
  def self.extended(obj)                     #<----2.
    puts "#{self} extended by #{obj}"
  end
end
obj = Object.new
puts "Including M in object's singleton class."      #<----3.
class << obj
  include M
end
puts
obj = Object.new
puts "Extending object with M:"        #<----4.
obj.extend(M)
```
Both callbacks are defined in the module `M`: `included` (#1) and `extended`(#2). Each callback prints out a report of what it's doing. Starting with a freshly minted, generic object, we include `M` in the object's singleton class (#3) and then repeat the process using another new object and extending the object with `M` directly (#4). 

The output from the lisitng is

```irb 
Including M in object's singleton class.
M included by #<Class:#<Object:0x00000001d6ef38>>.

Extending object with M:
M extended by #<Object:0x00000001d6ec40>
```
Sure enough, the include triggers the `included` callback, and the extended triggers `extended`, even though in this particular scenario the results of the two operations are the same: the object in question has `M` added to its method lookup path. It's a nice illustration of some of the subtlety and precision of Ruby's architecture and a useful reminder that manipulating an object's singleton class directly isn't *quite* identical to doing singleton-level operations directly on the object.

Just as modules can intercept include and extend operations, classes can tell when they're being subclassed. 

### *Intercepting inheritance with Class#inherited* ###
At this point in your work with Ruby, you can set your sights on doing more with lists of objects' methods than examining and discarding them. In this section we'll look at a few examples (and there'll be plenty of room left for you to create more, as your needs and interests demand) of ways in whcih you might use and interpret the information in method lists. 


**The limits of the `inherited` callback**

### *The Module#const_missing method* ###

### *The method_added and singleton_method_added methods* ###

## *Intercepting object capability queries* ##

### *Listing an object's non-private methods* ### 

### *Listing private and protected methods* ###

### *Getting class and module instance methods* ###

#### GETTING ALL THE ENUMERABLE OVERRIDES ####

### *Listing objects' singleton methods* ###

## *Introspection of variables and constants* ## 

### *Listing local and global variables* ###

### *Listing instance variables* ###

**The irb underscore variable** 

## *Tracing execution* ##

### *Examining the stack trace with caller* ###

### *Writing a tool for parsing stack traces* ###

#### THE CALLERTOOLS::CALL CLASS ####

#### THE CALLERTOOLS::STACK CLASS ####

#### USING THE CALLERTOOLS MODULE ####

## *Callbacks and method inspection in practice* ##

### *MicroTest background: MiniTest* ###

### *Specifying and implementing MicroTest* ### 

**Note** 

## *Summary* ##
