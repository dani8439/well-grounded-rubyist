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
the receiver in a call to that method. (That's what makes singleton methods singleton, or per-object.) Class methods are slightly different:
a method defined as a singleton method of a class object can also be called on subclasses of that class. Given the previous example, with `C` you can do this:

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
