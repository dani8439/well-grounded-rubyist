### *Class methods in (even more) depth* ###
Class methods are singleton methods defined on objects of class `Class`. In many ways, they behave like any other singleton method:

```ruby 
class C 
end
def C.a_class_method 
puts "Singleton method defined on C"
end 
C.a_class_method   #<---Output: Singleton method defined on C
```
But class methods also exhibit special behavior. Normally, when you define a singleton method on an object, no other object can serve as
the receiver in a call to that method. (That's what makes singleton methods singleton, or per-object.) Class methods are slightly different:a method defined as a singleton method of a class object can also be called on subclasses of that class. Given the previous example, with `C` you can do this:

```ruby 
class D < C 
end
D.a_class_method
```
Here's the rather confusing output (confuding because the class object we sent the message to is `D` rather than `C`:

`singleton method defined on C`

You're allowed to call `C`'s singleton methods on a subclass of `C` in addition to `C` because of a special setup involving the singleton classes of class objects. In our example, the singleton class of `C` (where the method `a_class_method` lives) is considered the superclass of the singleton class of `D`. 

When you send a message to the class of object `D`, the usual lookup path is followed except that after `D`'s singleton class, the superclass of `D`'s singleton class is searched. That's the singleton class of `D`'s superclass. And there's the method. 

Figure below shows the relationships among classes in an inheritance relationship and their singleton classes:

```irb 
| Class C | <--------- | Singleton Class of C |
     |                            |
     |                            ▽
| Class D | <----------| Singleton class of D |
```
As you can see, the singleton class of `C`'s child, `D`, is considered a child, (a subclass) of the singleton class of `C`.

Singleton classes of class objects are sometimes called *meta-classes*. You'll sometimes hear the term *meta-classes* applied to singleton classes in general, although there's nothing particularly meta about them and singleton class is more a descriptive general term.

You can treat this explanation as a bonus topic. It's unlikely that any urgent need to understand it will arise often. Still, it's a great example of how Ruby's design is based on a relatively small number of rules (such as every object having a singleton class, and the way methods are looked up). Classes are special-cased objects: after all, they're object factories as well as objects in their own right. But there's little in Ruby that doesn't arise naturally from the basic principles of the language's design-even the special cases.

Because Ruby's classes and modules are objects, changes you make to those classes and modules are per-object changes. Thus a discussion of how, when, and whether to make alterations to Ruby's core classes and modules has a place in this discussion of object individuation. We'll explore core changes next.

**SINGLETONE CLASSES AND THE SINGLETON PATTERN** 
The word "singleton" has a second, different meaning in Ruby (and elsewhere): it refers to the singleton pattern, which describes a class that only has one instance. The Ruby standard library includes an implementation of the singleton pattern (available via the comman `require 'singleton'`). Keep in mind that singleton classes aren't directly related to the singleton pattern; the word "singleton" is just a bit overloaded. It's generally clear from teh context which meaning is intended.

## *Modifying Ruby's core classes and modules* ## 
The openness of Ruby's classes and modules-the fact that you, the programmer, can get under the hood of the language and change what it does-is one of the most important features of RUby and also one of the hardest to ocme to terms with. It's like being able to eat the dishes along iwth the food at a restaurant. How do you know where one ends and the other begins? How do you know when to stop? Can you eat the tablecloth too?

Learning how to handle Ruby's openness is a bit about programming technique and a lot about best practices. It's not difficult to make modifications to the core language; the hard part is knowing hwen you should, when you shouldn't, and how to go about it safely.

In this section, we'll look at the landscape of core changes: the how, the what, and the why (and they why not). We'll examine the considerable pitfalls, the possible advantages, adn ways to thinka bout objects and their behaviors that allow you to have the best of both worlds: flexibility and safety.

We'll start with a couple of cautionary tales. 

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
