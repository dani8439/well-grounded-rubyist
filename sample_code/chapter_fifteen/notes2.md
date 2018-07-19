### *The Module#const_missing method* ###
`Module#const_missing` is another commonly used callback. As the name implies, this method is called whenever an unidentifiable constant is referred to inside a given module or class:

```ruby 
class C
  def self.const_missing(const)
    puts "#{const} is undefined-setting it to 1."
    const_set(const,1)
  end
end
puts C::A
puts C::A
```
The output of this code is

```irb
A is undefined-setting it to 1.
1
1
```
Thanks to the callback, `C::A` is defined automatically when you use it without defining it. This is taken care of in such a way that `puts` can print the value of the constant; `puts` never has to know that the constant wasn't defined in teh first place. Then, on the second call to `puts`, the constant is already defined, and `const_missing` isn't called.

One of the most powerful event callback facilities in Ruby is `method_added`, which lets you trigger an event when a new instance method is defined.

### *The method_added and singleton_method_added methods* ###
If you define `method_added` as a class method in any class or module, it will be called when any instance method is defined. Here is a basic example:

```ruby 
class C
  def self.method_added(m)          #<----Defines callback
    puts "Method #{m} was just defined."
  end
  def a_new_method        #<-----Triggers it by defining instance method
  end
end

# Method a_new_method was just defined.
```
The `singleton_method_added` callback does much the same thing, but for singleton methods. Perhaps surprisingly, it even triggers itself. If you run this snippet

```ruby 
class C
  def self.singleton_method_added(m)
    puts "Method #{m} was just defined."
  end
end
```
You'll see that the callback-which is a singleton method on the class object `C`- triggers its own execution:

```irb 
Method singleton_method_added was just defined.
```
The callback will also be triggered by the definition of another singleton (class) method. Let's expand the previous example to include such a definition:

```ruby 
class C
  def self.singleton_method_added(m)
    puts "Method #{m} was just defined."
  end
  def self.new_class_method
  end
end
```
The new output is:

```irb 
Method singleton_method_added was just defined.
Method new_class_method was just defined.
```
In most cases, you should use `singleton_method_added` with objects other than class objects. Here's how its use might play out with a generic object:

```ruby 
obj = Object.new
def obj.singleton_method_added(m)
  puts "Singleton method #{m} was just defined."
end
def obj.a_new_singleton_method
end
```
The output in this case is:

```irb 
Singleton method singleton_method_added was just defined.
Singleton method a_new_singleton_method was just defined.
```
Again, you get the somewhat surprising effect that defining `singleton_method_added` triggers the callback's own execution.

Putting the class-based and object-based approaches together, you can achieve the object-specific effect by defining the relevant methods in the object's singleton class:

```ruby 
obj = Object.new
class << obj
  def singleton_method_added(m)
    puts "Singleton method #{m} was just defined."
  end
  def a_new_singleton_method
  end
end
```
The output for this snippet is exactly the same as for the previous example. 

```irb 
Singleton method singleton_method_added was just defined.
Singleton method a_new_singleton_method was just defined.
```
Finally, coming full circle, you can define `singleton_method_added` as a regular instance method of a class, in which case every instance of that class will follow the rule that the callback will be triggered by the creation of a singleton method:

```ruby 
class C
  def singleton_method_added(m)                           #<----1.
    puts "Singleton method #{m} was just defined."
  end
end
c = C.new
def c.a_singleton_method                                 #<----2.
end
```
Here, the definition of the callback(#1) governs every instance of `C`. The definition of a singleton method on such an instance (#2) therefore triggers the callback, resulting in this output:

```irb 
Singleton method a_singleton_method was just defined.
```
It's possible that you won't use either `method_added` or `singleton_method_added` often in your Ruby applications. But experimenting with them is a great way to get a deeper feel for how the various parts of the class, instance, and singleton-class pictures fit together.

We'll turn now to the subject of examining object capabilities (`"abc".methods` and friends). The basics of this topic were included in the "Built-in Essentials" survey in chapter 7, and as promised in that chapter, we'll go into them more deeply here.

## *Interpreting object capability queries* ##
At this point in your work with Ruby, you can set your sights on doing more with lists of objects' methods than examining and discarding them. In this section we'll look at a few examples (and there'll be plenty of room left for you to create more, as your needs and interests demand) of ways in whcih you might use and interpret the information in method lists. The Ruby you've learned since we last addressed this topic directly will stand you in good stead. You'll also learn a few fine points of the method querying methods themselves.

Let's start at the most familiar point of departure: listing non-private methods with the `methods` method.

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
