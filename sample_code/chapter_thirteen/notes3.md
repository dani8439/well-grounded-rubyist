### *Per-object changes with extend* ###
`Object#extend` is a kind of homecoming in terms of topic flow. We've wandered to the outer reaches of modifying core classes-and `extend` brings us back to the central process at the heart of all such changes: changing the behavior of an individual object. It also brings us back to an earlier topic from this chapter: the mixing of a module into an object's singleton class. That's essentially what `extend` does. 

#### ADDING TO AN OBJECT'S FUNCTIONALITY WITH EXTEND ####
Have another look at the earlier section and inparticular the `Person` example where we mixed the `Secretive` module into the singleton classes of some `Person` object. As a reminder, the technique was this (where `ruby` is a `Person` instance):

```ruby
class << ruby 
  include Secretive
end
```
Here's how the `Person` example would look, using `extend` instead of explicitly opening up the singleton class of the `ruby` object. Let's also use `extend` for `david` (instead of the singleton method definition with `def`):

```ruby 
module Secretive
  def name
    "[not available]"
  end
end
class Person
  attr_accessor :name
end
david = Person.new
david.name = "David"
matz = Person.new
matz.name = "Matz"
ruby = Person.new
ruby.name = "Ruby"
david.extend(Secretive)     #<---1.
ruby.extend(Secretive)
puts "We've got one person named #{matz.name}, " + "one person named #{david.name}, " + "and one named #{ruby.name}."

# We've got one person named Matz, one person named [not available], and one named [not available].
```
Most of this program is the same as the first version, as is the output. The key difference is the use of `extend` (#1), which has the effect of adding the `Secretive` module to the lookup paths of the individual objects `david` and `ruby` by mixing into their respective singleton classes. That inclusion process happens when you extend a class object, too.

#### ADDING CLASS METHODS WITH EXTEND ####
If you write a singleton method on a class object, like so

```ruby 
class Car 
  def self.makes 
    %w{ Honda Ford Toyota Chevrolet Volvo}
  end
end
```
or like so

```ruby 
class Car 
  class << self 
    def makes 
      %w{ Honda Ford Toyota Chevrolet Volvo}
    end 
  end 
end
```

or write any of the other notational variants available, you're adding an instance method to the singleton class of the class object. It follows that you can achieve this, in addition to the other ways, by using `extend`: 

```ruby 
module Makers 
  def makes 
    %w{ Honda Ford Toyota Chevrolet Volvo }
  end 
end 
class Car
  extend Makers 
end
```
If it's more appropriate in a given situation, you can extend the class object after it already exists:

`Car.extend(Makes)`

Either way, the upshot is that the class object `Car` now has access to the `makes` method. 

As with non-class objects, extending a class object with a module means mixing the module into the class's singleton class. You can verify this with the `ancestors` method:

`p Car.singleton_class.ancestors`

The output from this snippet is

`[#<Class:Car>, Makers, #<Class:Object>, #<Class:BasicObject>, Class, Module, Object, Kernel, BasicObject]`

The odd-looking entries in the list are singleton classes. The singleton class of `Car` itself is included; so are the singleton class of `Object` (which is the superclass of the singleton class of `Car`) and the singleton class of `BasicObject` (which is the superclass of the singleton class of `Object`). The main point for our purpose is that `Makers` is included in the list.

Remember too that subclasses have access to their superclass's class methods. If you subclass `Car` and look at the ancestors of the new class's singleton class, you'll see `Makers` in the list.

Our original purpose in looking at `extend` was to explore a way to add to Ruby's core functionality. Let's turn now to that purpose.

#### MODIFYING CORE BEHAVIOR WITH EXTEND ####
You've probably put the pieces together by this point. Modules let you define self-contained reusable collections of methods. `Kernel#extend` lets you give individual objects access to modules, courtesy of the singleton class and the mix-in mechanism. Put it all together, and you have a compact, safe way of adding functionality to core objects.

Let's take another look at the `String#gsub!` conundrum-namely, that it returns `nil` when the string doesn't change. By defining a module and using `extend`, it's possible to change `gsub!`'s behavior in a limited way, making only the changes you need and no more. Here's how:

```ruby 
module GsubBangModifier
  def gsub!(*args, &block)
    super || self             #<----1.
  end
end
str = "Hello there!"
str.extend(GsubBangModifier)      #<----2.
str.gsub!(/zzz/, "abc").reverse!      #<----3.
puts str

# Output: !ereht olleH
```
On the module `GsubBangModifier`, we define `gsub!`. Instead of the alias-and-call technique, we call `super`, returning either the value returned by that call or `self`-the latter if the call to `super` returns `nil` (#1). (You'll recall that `super` triggers execution of the next version of the current method up the method-lookup path. Hold that thought....)

Next, we create a string `stri` and extend it with `GsubBangModifier` (#2). Calling `str.gsub!` (#3) executes the `gsub!` in `GsubBangModifier`, becauuse `str` encounters `GsubBangModifier` in its method-lookup path before it encounters the class `String`- which, of course, also contains a `gsub!` definition. The call to `super` inside `GsubBangModifier#gsub!` jumps up the path and executes the original method, `String#gsub!` passing it the original arguments and code block, if any. (That's the effect of calling `super` with no arguments and no empty argument list.) And the result of the call to `super` is either the string itself or `nil`, depending on whether any changes were made to the string.

Thus you can change the behavior of core objects-strings, arrays, hashes, and so forth-without reopening their classes and without introducing changes on a global level. Having calls to `extend` in your code helps show what's going on. CHanging a method like `gsub!` inside the `String` class itself has the disadvantage not only of being global but also of being likely to be stashes away in a library file somewhere, making bugs hard to track down for people who get bitten by the global change.

There's one more important piece of the puzzle of how to change core objects behaviors: a new feature called *refinements*. 

### *Using refinements to affect core behavior* ###
Refinements were added to Ruby 2.0, but were considered "experimental" until the 2.1 release. The idea of a refinement is to make a temporary, limited-scope change to a class (which can, though needn't, be a core class).

Here's an example, in which a `shout` method is introduced to the `String` class but withou only a limited basis:

```ruby 
module Shout
  refine String do        #<---1.
    def shout
      self.upcase + "!!!"
    end
  end
end

class Person
  attr_accessor :name

  using Shout           #<----2.

  def announce
    puts "Announcing #{name.shout}"
  end
end

david = Person.new
david.name = "David"
david.announce

#Output:  Announcing DAVID!!!
```
Two different methods appear here, and they work hand in hand: `refine` (#1) and `using` (#2). The `refine` method takes a class name and a code block. Inside the code block you define the behaviors you want the class you're refining to adopt. In our example, we're refining the `String` class, adding a `shout` method that returns an upcased version of the string followed by three exclamation points.

The `using` method flips the switch: once you "use" the module in which you've defined the refinement you want, the target class adopts the new behaviors. In the example, we use the `Shout` module inside the `Person` class. That means that for the duration of that class (from the `using` statement to the end of the class definition), strings will be "refined" so that they have the `shout` method.

The effect of "using" a refinement comes to an end with the end of the class (or module) definition in which you declare you're using the refinement. You can actually use `using` outside of a class or module definition, in which case the effect of the refinement persists to the end of the file in which the call to `using` occurs. 

Refinements can help you make temporary changes to core classes in a relatively safe way. Other program files and libraries your program uses at runtime will not be affected by your refinements.

We'll end this chapter with a look at a slightly oddball topic: the `BasicObject` class. `BasicObject` isn't exclusitvely an object-individuation topic (as you know from having read the introductory material about it in chapter 3). But it pertains to the ancestroy of all objects-including those whose behavior branches away from their original classes-and can play an important role in the kind of dynamism that Ruby makes possible. 

## *BasicObject as ancestor and class* ##
`BasicObject` sits at the top of Ruby's class tree. For any Ruby object *obj*, the following is true:

`obj.class.ancestors.last == BasicObject` 

In other words, the highest-up ancestor of every class is `BasicObject`. (Unless you mix a module into `BasicObject`-but that's a far-fetched scenario.)

As you'll recall from chapter 3, instances of `BasicObject` have few methods-just a survival kit, so to speak, so they can participate in object-related activities. You'll find it difficult to get a `BasicObject` instances tot ell you what it can do:

```irb 
>> BasicObject.new.methods.sort
NoMethodError: undefined method `methods' for #<BasicObject:0x00000001372908>
        from (irb):1
        from /usr/local/rvm/rubies/ruby-2.3.1/bin/irb:11:in `<main>'
```

But `BasicObject` is a class and behaves like one. You can get information directly from it, using familiar class-level methods:

```irb 
>> BasicObject.instance_methods(false).sort
=> [:!, :!=, :==, :__id__, :__send__, :equal?, :instance_eval, :instance_exec]
```
What's the point of `BasicObject`?

### *Using BasicObject* ###
`BasicObject` enables you to create objects that do nothing, which means you can teach them to do everything-without worrying about clashing with existing methods. Typically, this entails heavy use of `method_missing`. By defining `method_missing` for `BasicObject` or a class that you write that inherits from it, you can engineer objects whose behavior you're completely in charge of and that have little or no preconceived sense of how they're supposed to behave. 

The best-known example of the use of an object with almost no methods is the `Builder` library by Jim Weirich. Builder is an XML-writing tool that outputs XML tags corresponding to messages you send to an object that recognizes few messages. The magic happens courtesy of `method_missing`. 

Here's a simple example of Builder usage (and all Builder usage is simple; that's the point of the library). This example presupposes that you've installed the `builder` gem. 

```irb 
>> require 'builder'
=> true
>> xml = Builder::XmlMarkup.new(:target => STDOUT, :indent => 2)   #<---1.
<inspect/>
=> #<IO:0x00000000fb9b40>
>> xml.instruct!                                                #<---2.
<?xml version="1.0" encoding="UTF-8"?>
=> #<IO:<STDOUT>>
>> xml.friends do
>> xml.friend(:source => "college") do
>>  xml.name("Joe Smith")
>>  xml.address do
>>    xml.street("123 Main Street")
>>    xml.city("Anywhere, USA 00000")
>>    end
>>  end
>> end
```
`xml` is a `Builder::XmlMarkup` object (#1). The object is programmed to send its output to `-STDOUT` and to indent by two spaces. The `instruct!` command (#2) tells the XML builder to start with an XML declaration. All instance methods of `Builder::XmlMarkup` end with a bang (`!`). They don't have non-bang counterparts-which bang methods should have in most cases-but in this case, the bang serves to distinguish these methods from methods with similar names that you may want to use to generate XML tages via `method_missing`. The assumption is that you may want an XML element called `instruct`, but you won't need one called `instruct!`. The bang is thus serving a domain-specific purpose, and it makes sense to depart from the usual Ruby convention for its use.

The output from our `Builder` script is this:

```irb 
<?xml version="1.0" encoding="UTF-8"?>
<friends>
  <friend source="college">
    <name>Joe Smith</name>
    <address>
      <street>123 Main Street</street>
      <city>Anywhere, USA 00000</city>
    </address>
  </friend>
</friends>
=> #<IO:<STDOUT>>
```
The various XML tags take their names from the method calls. Every missing method results in a tag, and code blocks represent XML nesting. If you provide a string argument to a missing method, the string will be used as the text context of the element. Attributes are provided in hash arguments.

Builder uses `BasicObject` to do its work. Interestingly, Builder existed *before* `BasicObject` did. The original versions of Builder used a custom-made class called `BlankSlate` which probably served as an inspiration for `BasicObject`. 

How would you implement a simple `BasicObject`-based class? 

### *Implementing a subclass of BasicObject* ###
*Simple*, in the question just asked, means simpler than `Builder::XmlMarkup` (which makes XML writing simple but is itself fairly complex). Let's write a small library that operates on a similar principle and outputs an indented list of items. We'll avoid having to provide closing tags, which makes things a lot easier.

The `Lister` class, shown in the following listing, will inherit from `BasicObject`. It will define `method_missing` in such a way that every missing method is take as a heading for the list it's generating. Nested code blocks will govern indentation.

```ruby 
class Lister < BasicObject
  attr_reader :list
  def initialize                    #<----1.
    @list = ""
    @level = 0
  end
  def indent(string)                   #<----2.
    " " + @level + string.to_s
  end
  def method_missing(m, &block)           #<----3.
    @list << indent(m) + ":"                  #<----4.
    @list << "\n"
    @level += 2                                   #<----5.
    @list << indent(yield(self)) if block             #<----6.
    @level -= 2
    @list << "\n"
    return ""                                             #<----7.
  end
end
```
On initialization, two instance variables are set (#1): `@list` will serve as the string accumulator for the entire list, and `@level` will guide indentation. The `indent` method (#2) takes a string (or anything that can be converted to a string; it calls `to_s` on its argument) and returns that string indented to the right by `@level` spaces.

Most of the action is in `method_missing` (#3). The symbol `m` represents the missing method name-presumably corresponding to a header or item for the list. Accordingly the first step is to add `m` (indented, and followed by a colon) to `@list`, along with a newline character (#4). NExt we increase the indentation level (#5) and yield (#6). (This step happens only if `block` isn't `nil`. Normally, you can test for the presence of a block with `block_given?`, but `BasicObject` instances don't have that method!) Yielding may trigger more missing method calls, in which case they're processed and their results added to `@list` at the new indentation level. After getting the results of the yield, we decrement the indentation level and add another newline to `@list`. 

At the end, `method_missing` returns an empty string (#7). The goal here is to avoid concatenating `@list` to itself. If `method_missing` ended with an expression evaluation to `@list` (like `@list << "\n"`), then nested calls to `method_missing` inside yield instructions would return `@list` and append it to itself. The empty string breaks the cycle. 

Here's an example of `Lister` in use:

```ruby 
lister = Lister.new
lister.groceries do |item|
  item.name { "Apples" }
  item.quantity { 10 }
  item.name { "Sugar" }
  item.quantity { "1 lb" }
end
lister.freeze do |f|
  f.name { "Ice cream" }
end
lister.inspect do |i|
  i.item { "car" }
end
lister.sleep do |s|
  s.hours { 8 }
end
lister.print do |document|
  document.book { "Chapter 13" }
  document.letter { "to editor" }
end
puts lister.list 
```
The output from this run is as follows:

```irb 
groceries:
  name:
    Apples 
  quantity:
    10 
  name:
    Sugar
  quantity:
    1 lb
 freeze:
    name: 
      Ice Cream 
 inspect:
    item: 
      car 
 sleep:
    hours:
       8
print:
  book:
    Chapter 13
  letter:
    to editor 
```
Admittedly not as gratifying as `Builder`-but you can follow the yields and missing method calls and see how you benefit from a `BasicObject` instance. And if you look at the method names used in the sample code, you'll see some that are build-in methods of (nonbasic) objects. If you don't inherit from `BasicObject`, you'll get an error when you try to call `freeze` or `inspect`. It's also interesting to note that `sleep` and `print` which are private methods of `Kernel` and therefore not normally callable with an explicit receiver, trigger `method_missing` even though strictly speaking they're private rather than missing.

Our look at `BasicObject` brings us to the end of this survey of object individuation. We'll be moving next to a different topic that's also deeply involved in Ruby dynamics: callable and runnable objects.

## *Summary* ## 
In this chapter you've seen

• Singleton classes and how to add methods and constants to them

• Class methods 

• The `extend` method 

• Several approaches to changing Ruby's core behavior

• `BasicObject` and how to leverage it 

We've looked at the ways that Ruby objects live up to the philosophy of Ruby, which is that what happens at runtime is all about individual objects and what they can do at any given point. Ruby objects are born into a particular class, but their ability to store individual methods in a dedicated singleton class means that any object can do almost anything.

You've seen how to open singleton class definitions and manipulate the innards of individual objects, including class objects that make heavy use of singleton-method techniques in connection with class methods (which are, essentially, singleton methods on class objects). You've also seen some of the power, as well as the risks, of the ability Ruby gives you to pry open not only your own classes but also Ruby's core classes. This is something you should do sparingly, if at all-and it's also something you should be aware of other people doing, so that you can evaluate the risks of any third-party code you're using that changes core behaviors.

We ended with an examination of `BasicObject`, the ultimate ancestor of all classes and a class you can use in cases where even a vanilla Ruby object isn't vanilla enough.

The next chapter will take us into the area of callable and runnable objects: functions (`Proc` objects), threads, `eval` blocks, and more. The fact that you can create objects that embody runnable code and manipulate those objects as you would any object adds yet another major layer to the overall topic of Ruby dynamics.
