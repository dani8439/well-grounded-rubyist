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


```ruby
x = 1
p local_variables
[:x]
p global_variables.sort
[:$!, :$", :$$, :$&, :$', :$*, :$+, :$,, :$-0, :$-F, :$-I, :$-K, :$-W, :$-a, :$-d, :$-i, :$-l, :$-p, :$-v, :$-w, :$., :$/, :$0, :$1, :$2,
:$3, :$4, :$5, :$6, :$7, :$8, :$9, :$:, :$;, :$<, :$=, :$>, :$?, :$@, :$DEBUG, :$FILENAME, :$KCODE, :$LOADED_FEATURES, :$LOAD_PATH, :$PROG
RAM_NAME, :$SAFE, :$VERBOSE, :$\, :$_, :$`, :$stderr, :$stdin, :$stdout, :$~]
```
The global variable list includes globals like `$:` (the library load path, also available as `$LOAD_PATH`), `$~` (the global `MatchData` object based on the most recent pattern-matching operation), `$0` (the name of the file in which execution of the current program was initiated), `$FILENAME` (the name of the file currently being executed), and others. The local variable list includes all currently defined local variables.

Note that `local_variables` and `global_variables` don't give you the values of the variables they report on; they just give you the names. The same is true of the `instance_variables` method, which you can call on any object.

### *Listing instance variables* ###
Here's another rendition of a simple `Person` clas, which illustrates what's involved in an instance-variable query:

```ruby
class Person
  attr_accessor :name, :age
  def initialize(name)
    @name = name
  end
end
david = Person.new("David")
david.age = 55
p david.instance_variables
```
The output is

```irb 
[:@name, :@age]
```
The object `david` has two instance variables initialized at the time of the query. One of them, `@name`, was assigned a value at the time of the object's creation. The other, `@age`, is present because of the accessor attribute `age`. Attributes are implemented as read and/or write methods around instance variables, so even though `@age` doesn't appear explicitly anywhere in the program, it gets initialized when the object is assigned an age.

All instance variables begin with the `@` character, and all globals begin with `$`. You might expect Ruby not to bother with those characters when it gives you lists of variable names; but the names you get in the lists do include the beginning of characters. 

**The irb underscore variable** 
If you run `local_variables` in a new irb session, you'll see an underscore:

```irb
>> local_variables
=> [:_]
```
The underscore is a special irb variable: it represents the value of the last expression evaluated by irb. You can use it to grab values that otherwise will have disappeared:

```irb 
>> Person.new("David")
=> #<Person:0x00000001ea7878 @name="David">
>> david = _
=> #<Person:0x00000001ea7878 @name="David">
```
Now the `Person` object is bound to the variable `david`.

Next, we'll look at execution-tracing techniques that help you determine the method calling history at a given point in runtime. 

## *Tracing execution* ##
No matter where you are in the execution of your program, you got there somehow. Either you're at the top level or you're one or more method calls deep. Ruby provides information about how you got where you are. The chief tool for examining the method-calling history is the top-level method `caller`.

### *Examining the stack trace with caller* ###
The `caller` method provides an array of strings. Each string represents one step in the stack trace: a description of a single method call along the way to where you are now. The strings contain information about the file or program where the method call was made, the line on which the method call occurred, and the method from which the current method was called, if any.

Here's an example. Put these lines in a file called tracedemo.rb

```ruby
def x 
  y 
end 
def y 
  z 
end 
def z 
  puts "Stacktrace: "
  p caller 
end 
x
```
All thise program does is bury itself in a stack of method calls: `x` calls `y`, `y` calls `z`. Inside `z`, we get a stack trace, courtesy of `caller`. Here's the output from running tracedemo.rb:

```irb 
Stacktrace:
["tracedemo.rb:5:in `y'", "tracedemo.rb:2:in `x'", "tracedemo.rb:11:in `<main>'"]
```
Each string in the stack trace array contains one link in the chain of method calls that got us to the point where caller was called. The first string represents the most recent call in the history: we were at line 6 of tracedemo.rb, inside the method `y`. The second string shows that we got to `y` via `x`. The third, final string tells us that we were in `<main>`, which means the call to x was made from the top level rather than from inside a method.

You may recognize the stack trace syntax from the messages you've seen from fatal errors. If you rewrite the `z` method to look like this

```ruby
def z 
  raise 
end
```
The output will look like this:

```irb
tracedemo.rb:12:in `z': unhandled exception
        from tracedemo.rb:5:in `y'
        from tracedemo.rb:2:in `x'
        from tracedemo.rb:14:in `<main>'
```
This is, of course, just a slightly prettified version of the stack trace array we got the first time around from `caller`. 

Ruby stack traces are useful, but they're also looked askance at because they consist solely of strings. If you want to do anything with the information a stack trace provides, you have to scan or parse the string and extract the useful information. Another approach is to write a Ruby tool for parsing stack traces and turning them into objects.

### *Writing a tool for parsing stack traces* ###
Given a stack trace-an array of strings-we want to generate an array of objects, each of which has knowledge of a program or filename, a line number, and a method name (or `<main>`). We'll write a `Call` class, which will represent an entire stack trace, consisting of one or more `Call` objects. To minimize the risk of name clashes, let's put both of these classes inside a module, `CallerTools`. Let's start by describing in more detial what each of the two classes will do.

`CallerTools::Call` will have three reader attributes: `program`, `line`, and `meth`. (It's better to use `meth` than `method` as the name of the third attribute because classes already have a method called `method` and we don't want to override it.) Upon initialization, an object of this class will parse a stack trace string and save the relevant substrings to the appropriate instance variables for later retrieval via the attribute-reader methods.

`CallerTools::Stack` will store one or more `Call` objects in an array, which in turn will be stored in the instance variable `@backtrace`. We'll also write a `report` method, which will produce a (reasonably) pretty printable representation of all the information in this particular stack of calls.

Now, let's write the classes. 

#### THE CALLERTOOLS::CALL CLASS ####
The following listing shows the `Call` class along with the first line of the entire program, which wraps everything else in the `CallerTools` module.

#### THE CALLERTOOLS::STACK CLASS ####

#### USING THE CALLERTOOLS MODULE ####

## *Callbacks and method inspection in practice* ##

### *MicroTest background: MiniTest* ###

### *Specifying and implementing MicroTest* ### 

**Note** 

## *Summary* ##
