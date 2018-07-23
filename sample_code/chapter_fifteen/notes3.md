### *Listing objects' singleton methods* ###
A singleton method, as you know, is a method defined for the sole use of a particular object (or, if the object is a class, for the use of the object and its subclasses) and stored in that object's singleton class. You can use the `singleton_methods` method to list all such methods. Note that `singleton_methods` lists public and protected singleton methods but not private ones. Here is an example:

```ruby
class C
end
c = C.new           #<-----1.
class << c            #<-----2.
  def x                 #|
  end                   #|
  def y                 #|
  end                   #|<------3.
  def z                 #|
  end                   #|
  protected :y
  private :z
end
p c.singleton_methods.sort  #<------4.
```
An instance of class `C` is created (#1), and its singleton class is opened (#2). Three methods are defined in the singleton class, one each at the public (`x`), protected (`y`), and private (`z`) levels (#3). The printout of the singleton methods of `c` (#4) looks like this:

```irb 
[:x, :y]
```
Singleton methods are also considered just methods. The methods `:x` and `:y` will show up if you call `c.methods`, too. You can use the class-based method-query methods on the singleton class. Add this code to the end of the last example:

```ruby
class << c
  p private_instance_methods(false)
end
```
When you run it, you'll see this:

```irb 
[:z]
```
The method `:z` is a singleton method of `c`, which means it's an instance method (a private instance method, as it happens, of `c`'s singleton class.

You can ask a class for its singleton methods, and you'll get the singleton methods defined for that class and for all of its ancestors:

```irb
>> class C; end
=> nil
>> class D < C; end
=> nil
>> def C.a_class_method_on_C; end
=> :a_class_method_on_C
>> def D.a_class_method_on_D; end
=> :a_class_method_on_D
>> D.singleton_methods
=> [:a_class_method_on_D, :a_class_method_on_C]
```

## *Introspection of variables and constants* ## 
Ruby can tell you several things about which variables and constants you have access to at a given point in runtime. You can get a listing of local or global variables, an object's instance variables, the class variables of a class or module, and the constants of a class or module.

### *Listing local and global variables* ###
The local and global variable inspections are straightforward, you use the top-level methods `local_variables` and `global_variables`. In each case, you get back an array of symbols corresponding to the local or global variables currently defined:

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
