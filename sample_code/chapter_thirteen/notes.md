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

**Some objects are more individualizable than others** 

### *Dual determination through singleton class* ###

### *Examining and modifying a singleton class directly* ### 

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
