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

```ruby 
module CallerTools
  class Call
    CALL_RE = /(.*):(\d+):in `(.*)'/     #<----1.
    attr_reader :program, :line, :meth      #<-----2.
    def initialize(string)
      @program, @line, @meth = CALL_RE.match(string).captures #<-----3.
    end
    def to_s
      "%30s%5s%15s" % [program, line, meth]    #<-----4
    end
  end
```
We need a regular expression with which to parse the stack trace strings; that regular expression is stored in the `CALL_RE` constant (#1). `CALL_RE` has three parenthetical capture groupings, separated by uncaptured literal substrings. Here's how the regular expression matches up against a typical stack trace string. Bold type shows the substrings that are captured by the corresponding regular expression subpatterns. The nonbold characters aren't included in the captures, but are matched literally (but can't figure out how to bold in irb):

```
myrubyfile.rb:234:in `a_method'
   .*        :\d+:in `  .*    '
```
The class has, as specified, three reader attributes for the three components of the call (#2). Initialization requires a string argument, the string is matched against `CALL_RE`, and the results, available via the `captures` method of the `MatchData` object, are placed in the three instance variables corresponding to the attributes, using parallel assignment (#3). (We get a fatal error for trying to call `captures` on `nil` if there's no match. You can alter the code to handle this condition directly if you wish.)

We also define a `to_s` method for `Call` objects (#4). This method comes into play in situations where it's useful to print out a report of a particular `backtrace` element. It involves Ruby's handy `%` technique. On the left of the `%` is a `sprintf`-style formatting string, and on the right is an array of replacement values. You might want to tinker with the lengths of the fields in the replacement string-or, for that matter, write your own `to_s` method, if you prefer a different style of output.

Now it's time for the `Stack` class. 

#### THE CALLERTOOLS::STACK CLASS ####
The `Stack` class, along with the closing `end` instruction for the entire `CallerTools` module, is shown in the following listing.

```ruby
class Stack
    def initialize
      stack = caller                    #<-----1.
      stack.shift
      @backtrace = stack.map do |call|    #<-----2.
        Call.new(call)
      end
    end
    def report
      @backtrace.map do |call|              #<-----3.
        call.to_s
      end
    end   
    def find(&block)                          #<-----4.
      @backtrace.find(&block)
    end
  end
end
```
Upon initialization, a new `Stack` object calls `caller` and saves the resulting array (#1). It then shifts that array, removing the first string; that string reports on the call to `Stack.new` itself and is therefore just noise.

The stored `@backtrace` should consist of one `Call` object for each string in the `my_caller` array. That's a job for `map` (#2). Note that there's no `backtrace` reader attribute. In this case, all we need is the instance variable for internal use by the object.

Next comes the `report` method, which uses `map` on the `@backtrace` array to generate an array of strings for all the `Call` objects in the stack (#3). This report array is suitable for printing or, if need be, for searching and filtering.

The `Stack` class includes one final method: `find` (#4). It works by forwarding its code block to the `fine` method of the `@backtrace` array. It works a lot like some of the deck-of-cards methods you've seen, which forward a method to an array containing the cards that make up the deck. Techniques like this allow you to fine-tune the interface of your objects, using underlying objects to provide them with exactly the functionality they ened. (You'll see the specific usefulness of `find` shortly.

Now, let's try out `CallerTools`. 

#### USING THE CALLERTOOLS MODULE ####
You can use a modified version of the "x,y,z" demo from the earlier section to try out `CallerTools`. Put this code in a file called callertest.rb:

```ruby 
require_relative 'callertools'
def x
  y
end
def y
  z
end
def z
  stack = CallerTools::Stack.new
  puts stack.report
end
x
```
When you run the program, you'll see this output:

```irb
// ♥ ruby callertest.rb
                 callertest.rb    9              z
                 callertest.rb    6              y
                 callertest.rb    3              x
                 callertest.rb   12         <main>

```
Nothing too fancy, but it's a nice programmatic way to address a stack trace rather than having to munge the strings directly every time. (There's a lot of blank space at the beginnings of the lines, but there would be less if the file paths were longer-and of course you can adjust the formatting to taste.)

Next on the agenda, and the last stop for this chapter, is a project that ties together a number of the techniques we've been looking at: stack tracing, method querying, and callbacks, as well as some techniques you know from elsewhere in the book. We'll write a test framework.

## *Callbacks and method inspection in practice* ##
In this section, we'll implement MicroTest, a tiny test framework. It doesn't have many features, but the ones it has will demonstrate some of the power and expressiveness of the callbacks and inspection techniques you've just learned.

First, a bit of backstory.

### *MicroTest background: MiniTest* ###
Ruby ships with a testing framework called MiniTest. You use MiniTest by writing a class that inherits from the class `MiniTest::Unit::TestCase` and that contains methods whose names begin with the string `test`. You can then either specify which test methods you want to execute, or arrange (as we will below) for every `test`-named method to be executed automatically when you run the file. Inside those methods, you write *assertions*. The truth or falsehood of your assertions determines whether your test passes.

The exercise we'll do here is to write a simple testing utility based on some of the same principles as MiniTest. To help you get your bearings, we'll look first at a full example of MiniTest in action and then do the implementation exercise.

We'll test dealing cards. The following listing shows a version of a class for a deck of cards. The deck consists of an array of 52 strings held in the `@cards` instance variable. Dealing one or more cards means popping that many cards off the top of the deck.

```ruby 
module PlayingCards
  RANKS = %w{ 2 3 4 5 6 7 8 9 10 J Q K A }
  SUITS = %w{ clubs diamonds hearts spades }
  class Deck
    def initialize                            #<-----1.
      @cards = []
      RANKS.each do |r|
        SUITS.each do |s|
          @cards << "#{r} of #{s}"
        end
      end
      @cards.shuffle!
    end
    def deal(n=1)                             #<------2.
      @cards.pop(n)
    end
    def size
      @cards.size
    end
  end
end
```
Creating a new deck (#1) involves initializing `@cards`, inserting 52 strings into it, and shuffling the array. Each string takes the form *"rank of suit,"* where *rank* is one of the ranks in the constant array `RANKS` and *suit* is one of `SUITS`. In dealing from the deck (#2), we return an array of cards, where `n` is the number of cards being dealt and defaults to `1`. 

So far, so good. Now, let's test it. Enter MiniTest. The next listing shows the test code for the cards class. The test code assumes that you've saved the cards code to a separate file called cards.rb in the same directory as the test code file (which you can call cardtest.rb).

```ruby 
require 'minitest/unit'                       #<-----1.
require 'minitest/autorun'
require_relative 'cards'
class CardTest < MiniTest::Unit::TestCase     #<-----2.
  def setup                                   #<-----3.
    @deck = PlayingCards::Deck.new
  end
  def test_deal_one                           #<-----4.
    @deck.deal
    assert_equal(51, @deck.size)              #<-----5.
  end
  def test_deal_many                          #<-----6.
    @deck.deal(5)
    assert_equal(47, @deck.size)
  end
end 
```
The first order of business is to require both the `minitest/unit` library and the cards.rb file (#1). We also require `minitest/autorun`; this feature causes MiniTest to run the test methods it encounters without our having to make explicit method calls. Next, we create a `CardTest` class that inherits from `MiniTest::Unit::TestCase` (#2). In this class, we define three methods. The first is `setup` (#3). The method name `setup` is magic to MiniTest; if defined, it's executed before every test method in the test class. Running the `setup` method before each test method contributes to keeping the test methods independent of each other, and that independence is an important part of the architecture of test suits.

Now come the two test methods, `test_deal_one` (#4) and `test_deal_many` (#6). These methods define the actual tests. In each case, we're dealing from the deck and then making an assertion abou the size of the deck subsequent to the dealing. Remember that `setup` is executed before each test method, which means `@deck` contains a full 52-card deck for each method.

The assertions are performed using the `assert_equal` method (#5). This method takes two arguments. If the two are equal (using `==` to do the comparison behind the scenes), the assertion succeeds. If not, it fails.

Execute cardtest.rb from the command line. Here's what you'll see (probably with a different seed and different time measurements):

```irb 
$ ruby cardtest.rb
Run options: --seed 59230

# Running:
..

Finished in 0.002925s, 683.8767 runs/s, 683.8767 assertions/s.
2 tests, 2 assertions, 0 failures, 0 errors, 0 skips 
```

The last line tells you that there were two methods whose names began with `test` (`2 tests`) and a total of two assertions (the two calls to `assert_equal`). It tells you further that both assertions passed (no failures) and that nothing went drastically wrong (no errors; an error is something unrecoverable like a reference to an unknown variable, whereas a failure is an incorrect assertion). It also reports that no tests were skipped (skipping a test is something you can do explicitly with a call to the `skip` method).

The most striking thing about running this test file is that at no point do you have to *instantiate* the `CardTest` or explicitly call the test methods or the `setup` method. Thanks to the loading of the `autorun` feature, MiniTest figures out that it's supposed to run all the methods whose names begin with `test`, running the setup method before each of them. This automatic execution-or at least a subset of it-is what we'll implement in our exercise.

### *Specifying and implementing MicroTest* ### 
Here's what we'll want from our `MicroTest` utility:

• Automatic execution of the `setup` method and test methods, based on class inheritance.

• A simple assertion method that either succeeds or fails.

The first specification will entail most of the work.

We need a class that, upon being inherited, observes the new subclass and executes the methods in that subclass as they're defined. For the sake of (relative!) simplicity, we'll execute them in definition order, which means `setup` should be defined first.

Here's a more detailed description of the steps needed to implement MicroTest:

  1. Define the class `MicroTest`.
  2. Define `MicroTest.inherited`.
  3. Inside `inherited`, the inheriting class should...
  4. Define its own `method_added` callback, which should...
  5. Instantiate the class and execute the new method if it starts with test, but first...
  6. Execute the `setup` method, if there is one. 
 
Here's a nonworking, commented mockup of `MicroTest` in Ruby:

```ruby 
class MicroTest
  def self.inherited(c)
    c.class_eval do
      def self.method_added(m)
        # If m starts with "test"
        #   Create an instance of c
        #   If there's a setup method
        #     Execute setup
        #   Execute the method m
      end
    end
  end
end
```
There's a kind of logic cascade here. Inside `MicroTest`, we define `self.inherited`, which receives the inheriting class (the new subclass) as its argument. We then enter into that class's definition scope using `class_eval`. Inside that scope, we implement `method_added`, which will be called every time a new method is defined in the class.

Writing the full code follows directly from the comments inside the code mockup. The following listing shows the full version of micro_test.rb. Put it in the same directory as callertools.rb

```ruby
require_relative 'callertools'
class MicroTest 
  def self.inherited(c)
    c.class_eval do 
      def self.method_added(m)
        if m =~ /^test/                               #<-----1.
          obj = self.new                              #<-----2.
          if self.instance_methods.include?(:setup)   #<-----3.
            obj.setup 
          end 
          obj.send(m)
        end 
      end 
    end 
  end 
  def assert(assertion)                                   #<------4.
    if assertion
      puts "Assertion passed"
      true
    else
      puts "Assertion failed:"
      stack = CallerTools::Stack.new
      failure = stack.find {|call| call.meth !~ /assert/ }     #<------5.
      puts failure
      false
    end
  end 
  def assert_equal(expected, actual)                          #<------6.
    result = assert(expected == actual)
    puts "(#{actual} is not #{expected})" unless result     #<------7.
  end
end
```
Inside the class definition (`class_eval`) scope of the new subclass, we define `method_added`, and that's where most of the action is. If the method being defined starts with `test` (#1), we create a new instance of the class (#2). If a `setup` method is defined (#3), we call it on that instance. Then (whether or not there was a `setup` method; that's optional), we call the newly added method using `send` because we don't know the methods name.

**Note** As odd as it may seem (in light of the traditional notion of pattern matching, which involves strings), the `m` in the pattern-matching operation `m =~ /^test/` is a symbol, not a string. The ability of symbol objects to match themselves against regular expressions is part of the general move we've already noted towards making symbols more easily interchangeable with strings. Keep in mind though, the important differences between the two, as explained in chapter 8.

---

The `assert` method tests the truth of its single argument (#4). If the argument is true (in the Boolean sense; it doesn't have to be the actual object `true`), a message is printed out, indicating success. If the assertion fails, the message printing gets a little more intricate. We create a `CallerTools::Stack` object and pinpoint the first `Call` object in that stack whose method name doesn't contain the string `assert` (#5). The purpose is to make sure we don't report the failure as having occurred in the `assert` method nor in the `assert_equal` method (described shortly). It's not robust; you might have a method with `assert` in it that you did want an error reported from. But it illustrates the kind of manipulation that the `find` method of `CallerTools::Stack` allows.

The second assertion method, `assert_equal`, tests for equality between its two arguments (#6). It does this by calling `assert` on a comparison. If the result isn't true, an error message showing the two compared objects is displayed (#7). Either way-success or failure-the result of the `assert` call is returned from `assert_equal`. 

To try out `MicroTest`, put the following code in a file called microcardtest.rb, and run it from the command line:

```ruby 
require_relative 'micro_test'
require_relative 'cards'
class CardTest < MicroTest 
  def setup 
    @deck = PlayingCards::Deck.new 
  end 
  def test_deal_one 
    @deck.deal 
    assert_equal(51, @deck.size)
  end 
  def test_deal_many 
    @deck.deal(5)
    assert_equal(47, @deck.size)
  end 
end 
```
As you can see, this code is almost identical to the MiniTest file we wrote before. The only differences are the names of the test library and parent test class. And when you run the code, you get these somewhat obscure by encouraging results:

```irb 
Assertion passed 
Assertion passed
```
If you want to see a failure, change `51` to `50` in `test_deal_one`:

```irb 
Assertion failed:
              microcardtest.rb    9  test_deal_one
(51 is not 50)
Assertion passed
```
MicroTest won't supplant MiniTest any time soon, but it does do a couple of the most magical things that MiniTest does. It's all made possibly by Ruby's introspection and callback facilities, techniques that put extraordinary power and flexibility in your hands.

## *Summary* ##

In this chapter, you've seen

• Intercepting methods with `method_missing` 

• Runtime hooks and callbacks for objects, classes, and modules 

• Querying objects about their methods, on various criteria 

• Trapping references to unknown constants

• Stack traces

• Writing the MicroTest framework

We've covered a lot of ground in this chapter, and practicing the techniques covered here will contribute greatly to your grounding as a Rubyist. We looked at intercepting unknown messages with `method_missing`, along with other runtime hooks and callbacks like `Module.included`, `Module.extended`, and `Class.inherited`. The chapter also took us into method querying in its various nuances: public, protected, private; class, instance, singleton. You've seen some examples of how this kind of querying can help you derive information about how Ruby does its own class, module, and method organization.

The last overall topic was the handling of stack traces, which we put to use in the `CallerTools` module. The chapter ended with the extended exercise consisting of implementing the `MicroTest` class, which pulled togethr a number of topics and threads from this chapter and elsewhere.

We've been going through the material methodically, and deliberately, as befits a grounding or preparation. But if you look at the results, particularly `MicroTest`, you can see how much power Ruby gives you in exchange for relatively little effort. That's why it pays to know about even what may seem to be the magic or "meta" parts of Ruby. They really aren't-it's all Ruby, and once you internalize the principles of class and object structure and relationships, everything else follows.

And that's that! Enjoy your groundedness as a Rubyist and the many structures you'll build on top of the foundation you've acquired through this book.
