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
To list the non-private (i.e., public or protected) methods that an object knows about, you use the method `methods`, which returns an array of symbols. Arrays being arrays, you can perform some useful queries on the results of the initial query. Typically, you'll filter the array in some way so as to get a subset of methods.

Here, for example, is how you might ask a string what methods it knows about that involve modification of cases:

```irb 
>> string = "Test string"
=> "Test string"
>> string.methods.grep(/case/).sort
=> [:casecmp, :downcase, :downcase!, :swapcase, :swapcase!, :upcase, :upcase!]
```
The `grep` filters out any symbol that doesn't have `case` in it. (Remember that although they're not strings, symbols exhibit a number of stringlike behaviors, such as being greppable.) The `sort` command at the end is useful for most method-listing operations. It doesn't make much of a difference in this example, because there are only seven methods; but when you get back arrays of 100 or more symbols, sorting them can help a lot.

Grepping for `case` depends on the assumption, of course, that case-related methods will have `case` in their names. There's definitely an element of judgment, often along the lines of making educated guesses about what you think you'll find, in many method-capability queries. Things tend to work out, though, as Ruby is more than reasonably consistent and conventional in its choice of method names.

Some of the `case` methods are also bang(`!`) methods. Following that thread, let's find out all the bang methods a string has, agian using a `grep` operation:

```irb 
>> string.methods.grep(/.!/).sort
=> [:capitalize!, :chomp!, :chop!, :delete!, :downcase!, :encode!, :gsub!, :lstrip!, :next!, :reverse!, :rstrip!, :scrub!, :slice!, 
:squeeze!, :strip!, :sub!, :succ!, :swapcase!, :tr!, :tr_s!, :unicode_normalize!, :upcase!]
```
Why the dot before the `!` in the regular expression? Its purpose is to ensure that there's at least one character before the `!` in the method name, and thus to exclude the `!`, `!=`, and `!~` methods, which contain `!` but aren't bang methods in the usual sense. We want methods that end with a bang, but not those that begin with one.

Let's use `methods` a little further. Here's a question we can answer by interpreting method query results: do strings have any bang methods that don't have corresponding non-bang methods?

```ruby
string = "Test string"
methods = string.methods
bangs = string.methods.grep(/.!/)           #<-----1.
unmatched = bangs.reject do |b|
  methods.include?(b[0..-2].to_sym)                          #<-----2.
end
if unmatched.empty?
  puts "All bang methods are matched by non-bang methods."                 #<-----3.
else
  puts "Some bang methods have no non-bang partner:"
  puts unmatched
end

# Output: All bang methods are matched by non-bang methods.
```
The code works by collecting all of a string's public methods and, separately, all of its bang methods (#1). Then, a reject operation filgers out all bang method names for which a corresponding non-bang name can be found in the larger method-name list (#2). The `[0..-2]` index grabs everything but the last character of the symbol-the method name minus the `!`, in other words-and the call to `to_sym` converts the resulting string back to a symbol so that the `include?` test can look for it in the array of methods. If the filtered list is empty, that means that no unmatched bang method names were found. If it isn't empty, then at least one such name was found and can be printed out (#3).

If you run the script as it is, it will always take the first (true) branch of the `if` statement. If you want to see a list of unmatched bang methods, you can add the following line to the program, just after the first line:

```ruby 
def string.surprise!; end
```
When you run the modified version of the script, you'll see this:

```irb 
Some bang methods have no non-bang partner:
surprise!
```
As you've already seen, writing bang methods without non-bang partners is usually bad practice-but it's a good way to see the `methods` method at work.

You can, of course, ask class and module objects what their methods are. After all, they're just objects. But remember that the `methods` method always lists the nonprivate methods of the object itself. In the case of classes and modules, that means you're not getting a list of the methods that instance of the class-or instances of classes that mix in the module-can call. You're getting the methods that the class or module itself knows about. Here's a (partial) result from calling `methods` on a newly created class object:

```irb 
>> class C; end
=> nil
>> C.methods.sort
=> [:!, :!=, :!~, :<, :<=, :<=>, :==, :===, :=~, :>, :>=, :__id__, :__send__, :allocate, :ancestors, :autoload, :autoload?, :class, :class
_eval, :class_exec, :class_variable_defined?, :class_variable_get, :class_variable_set, :class_variables, :clone, :const_defined?, :const_
get, :const_missing, :const_set, :constants, :define_singleton_method, :deprecate_constant, :display, :dup, :enum_for, :eql?, :equal?, :ex
tend, :freeze, :frozen?, :hash, :include, :include?, :included_modules, :inspect, :instance_eval, :instance_exec, :instance_method, :insta
nce_methods, :instance_of?, :instance_variable_defined?, :instance_variable_get, :instance_variable_set, :instance_variables, :is_a?, :its
elf, :kind_of?, :method, :method_defined?, :methods, :module_eval, :module_exec, :name, :new, :nil?, :object_id, :prepend, :private_class_
method, :private_constant, :private_instance_methods, :private_method_defined?, :private_methods, :protected_instance_methods, :protected_
method_defined?, :protected_methods, :public_class_method, :public_constant, :public_instance_method, :public_instance_methods, :public_me
thod, :public_method_defined?, :public_methods, :public_send, :remove_class_variable, :remove_instance_variable, :respond_to?, :send, :sin
gleton_class, :singleton_class?, :singleton_method, :singleton_methods, :superclass, :taint, :tainted?, :tap, :to_enum, :to_s, :trust, :un
taint, :untrust, :untrusted?]
```
Class and module objects share some methods with their own instances, because they're all objects and objects in general share certain methods. But the methods you see are those that the class or module itself can call. You can also ask classes and modules about the instance methods they define. We'll return to that technique shortly. First, let's look briefly at the process of listing an object's private and protected methods.

### *Listing private and protected methods* ###
Every object (except instances of `BasicObject`) has a `private_methods` method and a `protected_methods` method. They work as you'd expect; they provide arrays of symbols, but containing private and protected method names, respectively.

Freshly minted Ruby objects have a lot of private methos and no protected methods:

```
// ♥ ruby -e 'o = Object.new; p o.private_methods.size'
74
// ♥ ruby -e 'o = Object.new; p o.protected_methods.size'
0
```
What are those private methods? They're private instance methods defined mostly in the `Kernel` module and secondarily in the `BasicObject` class. Here's how you can track this down:

```
// ♥ ruby -e 'o = Object.new; p o.private_methods.size - 
    BasicObject.private_instance_methods(false) - 
    Kernel.private_instance_methods(false)'
[] #<---what supposed to get, vs what got--->   [:DelegateClass]
```
Note that after you subtract the private methods defined in `Kernel` and `BasicObjeect`, the original object has no private methods to list. The private methods defined in `Kernel` are the methods we think of as "top-level," like `puts`, `binding`, and `raise`. Play around a little with the method-listing techniques you're learning here and you'll see some familiar methods listed.

Naturally, if you define a private method yourself, it will also appear in the list of private methods. Here's an example: a simple `Person` class in which assigning a name to the person via the `name=` method triggers a name-normalization method that removes everything other than the letters and selected punctuation characters from the name. The `normalize_name` method is private:

```ruby
class Person
  attr_accessor :name
  def name=(name)         #<---Defines nondefault writing accessor
    @name = name
    normalize_name            #<---Normalizes name when assigned
  end
  private
  def normalize_name
    name.gsub!(/[^-a-z'.\s]/i, "")      #<----Removes undersired characters from name
  end
end
david = Person.new
david.name = "123David!! Bl%a9ck"
raise "Problem" unless david.name == "David Black"    #<----Makes sure normalization works
puts "Name has been normalized."                            #<----Prints success message
p david.private_methods.sort.grep(/normal/)                        #<----Result of private method inspection: [:normalize_name]

# Name has been normalized.
# [:normalize_name]
```

Protected methods can be examined in much the same way, using the `protected_methods` method.

In addition to asking objects what methods they know about, it's frequently useful to ask classes and modules what methods they provide.

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
