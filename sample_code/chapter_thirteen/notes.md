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
```

**The difference between def obj.meth and class << obj; def meth** 

#### DEFINING CLASS METHODS WITH CLASS << ####

### *Singletone classes on the method-lookup path* ### 

#### INCLUDING A MODULE IN A SINGLETON CLASS ####

#### SINGLETONE MODULE INCLUSION VS. ORIGINAL-CLASS MODULE INCLUSION #### 

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
