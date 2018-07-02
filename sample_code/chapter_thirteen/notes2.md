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
The problem with making changes to the Ruby core classes is that those changes are global: as long as your program is running, the changes you've made will be in effect. If you change how a method works and that method is used somewhere else (inside Ruby itself or in a library you load), you've destabilized the whole interpreter by changing the rules of the game in midstream.

It's tempting, nonetheless, to customize Ruby to your liking by changing core methods globally. After all, you can. But this is the least safe and least advisable approach to customizing core-object behaviors. We're only looking at it so you can get a sense of the nature of the problem.

One commonly cited candidate for the ad hoc change is the `Regexp` class. 

#### CHANGING REGEXP#MATCH (AND WHY NOT TO) ####
As you'll recall from chapter 11, when a match operation using the `match` method fails, you get back `nil`; when it succeeds, you get back a `MatchData` object. This result is irritating because you can't do the same things witl `nil` that you can with a `MatchData` object.

This code, for example, succeeds if a first capture is created by the match:

`some_regexp.match(some_string)[1]`  <-- NoMethodError: undefined method[] for nil:NilClass

It may be tempting to do something like this to avoid the error:

```ruby
class Regexp
   alias __old_match__ match          #<--- 1.
   def match(string)
       __old_match__(string) || []
   end 
end
```
This code first sets up an alias for `match`, courtesy of the `alias` keyword (#1). Then the code redefines `match`. The new `match` hooks intot he original version of `match` (through the alias) and then returns either the result of calling the original version or (if that call returns `nil`) an empty array.

**NOTE** An *alias* is a synonym for a method name. Calling a method by an alias doesn't involve any change of behavior or any alteration of the method-lookup process. The choice of alias name in the previous example is based on a fairly conventional formula: the addition of the word *old* plust the leading and trailing underscores. (A case could be made that the formula is too conventional and that you should create names that are less likely to be chosen by other overriders who also know the convention!)

-- 

You can now do this:

`/abc/.match("X")[1]`

Even though the match fails, the program won't blow up, because the failed match now returns an empty array rather than `nil`. The worst you can do with the new `match` is try to index an empty array, which is legal. (The result of the index operation will be `nil`, but at least you're not trying to index `nil`.)

The problem is that the person using your code may depend on the match operation to return `nil` on failure:

```ruby 
if regexp.match(string)
  do something 
else 
  do something else 
end
```
Because an array (even an empty one) is true, whereas `nil` is false, returning an array for a failed match operaiton means that the true/false test (as embodied in an `if/else` statement) always returns true. 

Maybe changing `Regexp#match` so as not to return `nil` on failure is something your instincts would tell you not to do anyway. And no one advocates doing it; it's more that some new Ruby users don't connect the dots and therefore don't see that changing a core method in one place it changes it everywhere. 

Another common example, and one that's a little more subtle (both as to what it does and as to why it's not a good idea) involves the `String#gsub!` method.

#### THE RETURN VALUE OF STRING#GSUB! AND WHY IT SHOULD STAY THAT WAY ####
As you'll recall, `String#gsub!` does a global replace operation on its receiver, saving the changes in the original object:

```irb 
>> string = "Hello there!"
=> "Hello there!"
>> string.gsub!(/e/, "E")
=> "HEllo thErE!"             #<---1.
>> string
=> "HEllo thErE!"                #<---2.
```
As you can see, the return value of the call to `gsub!` is the string object with the changes made (#1). (And examining the object again via the variable `string` confirms that the changes are indeed permanent (#2).)

Interestingly, though, something different happens when the `gsub!` operation doesn't result in any changes to the string:

```irb
>> string = "Hello there!"
=> "Hello there!"
>> string.gsub!(/zzz/, "xxx")
=> nil
>> string
=> "Hello there!"
```
There's no match on /zzz/, so the string isn't changed-and the return value of the call to `gsub!` is `nil`. 

Like the `nil` return from a match operation, the `nil` return from `gsub!` has the potential to make things blow up when you'd rather they didn't. Specifically, it means you can't use `gsub!` reliably in a chain of methods:

```irb 
>> string = "Hello there!"
=> "Hello there!"
>> string.gsub!(/e/, "E").reverse!           #<---1.
=> "!ErEht ollEH"                                 #<---2.
>> string = "Hello there!"
=> "Hello there!"
>> string.gsub!(/zzz/, "xxx").reverse!
NoMethodError: undefined method `reverse!' for nil:NilClass       #<---3.
        from (irb):10
        from /usr/local/rvm/rubies/ruby-2.3.1/bin/irb:11:in `<main>'
```
This example does something similar (but not quite the same) twice. The first time through, the chained calls to `gsub!` and `reverse!` (#1) return the newly `gsub!`'d and reversed string (#2). But the second time, the chain of calls results in a fatal error (#3): the `gsub!` call didn't change the string, so it returned `nil`-which means we called `reverse!` on `nil` rather than on a string.

**The tap method**
The `tap` method (callable on any object) performs the somewhat odd but potentially useful task of executing a code block, yielding the receiver to the block, and returning the receiver. It's easier to show this than to describe it:

```irb 
>> "Hello".tap {|string| puts string.upcase }.reverse
HELLO
=> "olleH"
```
Called on the receiver `"Hello"`, the `tap` method yields that string back to its code block, as confirmed by the printing out of the uppercased version of the string. Then `tap` returns the entire string-so the reverse operation is performed on the string. If you call `gsub!` on a string inside a `tap` block, it doesn't matter whether it returns `nil`, because `tap` returns the string. Be careful though. Using `tap` to circumvent the `nil` return of `gsub!` (or of other similarly behaving bang methods) can introduce complexities of its own, especially if you do multiple chaining where some methods perform in-place operations and others return object copies.

--
One possible way of handling the inconvenience of having to work around the `nil` return from `gsub!` is to take the view that it's not usually appropriate to chain method calls together too much anyway. And you can always avoid chain-related problems if you don't chain:

```irb 
>> string = "Hello there!"
=> "Hello there!"
>> string.gsub!(/zzz/, "xxx")
=> nil
>> string.reverse!
=> "!ereht olleH"
```
Still, a number of Ruby users have been bitten by the `nil` return value, either because they expected `gsub!` to behave like `gsub` (the non-bang version, which always returns its receiver, whether there's been a change or not) or because they didn't anticipate a case where the string wouldn't change. So `gsub!` and its `nil` return value becomes a popular candidate for change.

The change can be accomplished like this:

```ruby 
class String
  alias __old_gsub_bang__ gsub!
  def gsub!(*args, &block)
    __old_gsub_bang__(*args, &block)
    self
  end
end
```
First the original `gsub` gets an alias; that will enable us to call the original version from inside the new version. The new `gsub!` takes any number of arguments (the arguments themselves don't matter; we'll pass them along to the old `gsub!`) and a code block, which will be captures in the variable `block`. If no block is supplied-and `gsub!` can be called with or without a block-`block` is `nil`.

Now we call the old version of `gsub!`, passing it the arguments and reusing the code block. Finally, the new `gsub!` does the thing it's been written to do: it returns `self` (the string), regardless of whether the call to `__old_gsub_bang__` returned the string or `nil`.

And now, the reasons not to do this.

Changing `gsub!` this way is probably less likely, as a matter of statistics, to get you in trouble than changing `Regexp#match` is. Still, it's possible that someone might write code that depends on teh documented behavior of `gsub!`, in particular on the returning of `nil` when the string doesn't change. Here's an example-and although it's contrived (as most examples of this scenario are bound to be), it's valid Ruby and dependent on the documented behavior of `gsub!`:

```irb 
>> states = { "NY" => "New York", "NJ" => "New Jersey", "ME" => "Maine" }
=> {"NY"=>"New York", "NJ"=>"New Jersey", "ME"=>"Maine"}      #<--- 1.
>> string = "Eastern states include NY, NJ, and ME."              #<--- 2.
=> "Eastern states include NY, NJ, and ME."
>> if string.gsub!(/\b([A-Z]{2})\b/) { states[$1] }                    #<--- 3.
>> puts "Substitution occurred"
>>   else
>> puts "String unchanged"
>>   end
Substitution occurred                                                 #<--- 4.
=> nil
```
We start with a hash of state abbreviations and full names (#1). Then comes a string that uses state abbreviations (#2). The goal is to replace the abbreviations with the full names, using a `gsub!` operation that captures any two consecutive uppercase letters surrounding by word boundaries (`\b`) and replaces them with the value from the hash corresponding to the two-letter substring (#3). Along the way, we take note of whether any such replacements are made. If any are, `gsub!` retruns the new version of `string`. If no sustitutions are made, `gsub!` returns `nil`. The result of the process is printed out at the end (#4).

The damage here is relatively light, but the lesson is clear: don't change the documented behavior of core Ruby methods. Here's another version of the state-hash example, using `sub!` rather than `gsub!`. In this version, failure to return `nil` when the string doesn't change triggers an infinite loop. Assuming we have the states hash and the original version of `strin`, we can do a one-at-a-time substitution where each substitution is reported:

```irb 
>> string = "Eastern states include NJ, NJ, and ME."
=> "Eastern states include NJ, NJ, and ME."
>> while string.sub!(/\b([A-Z]{2})\b/) { states[$1] }
>>   puts "Replacing #{$1} with #{states[$1]}..."
>> end
Replacing NJ with New Jersey...
Replacing NJ with New Jersey...
Replacing ME with Maine...
=> nil
```
If `string.sub!` always returns a non-`nil` value (a string), then the `while` condition will never fail, and the loop will execute forever.

What you should *not* do, then, is rewrite core methods so that they don't do what others expect them to do. There's no exception to this. It's something you should never do, even though you can.

That leaves us with the question of how to change Ruby core functionality safely. We'll look at four techniques that you can consider. The first are additive change, hook, or pass-through change, and per-object change. Only one of them is truly safe, although all three are safe enough to use in many circumstances. The fourth technique is *refinements*, which are module-scoped changes to classes and which can help you pinpoint your core Ruby changes so that they don't overflow into surrounding code and into Ruby itself.

Along the way, we'll look at custom-made examples as well as some examples from the Active Support library, which is typically used as part of the Rails web application development framework. Active Support provides good examples of the first two kinds of core change: additive and pass-through. We'll start with additive.

### *Additive changes* ### 
The most common category of changes to built-in Ruby classes is the *additive change*: adding a method that doesn't exist. The benefit of additive change is that it doesn't clobber existing Ruby methods. The danger inherent in it is that if two programmers write added methods with the same name, and both get included into the interpreter during execution of a particular library or program, one of the two will clobber the other. There's no way to reduce that risk to zero.

Added methods often serve the purpose of providing functionality that a large number of people want. In other words, they're not all written for specialized use in one program. There's safety in numbers: if people have been discussing a given method for years, and if a de facto implementation of the method is floating around the Ruby world, the chances are good that if you write the method or use an existing implementation, you won't collide with anything that someone else may have written.

The Active Support library, and specifically its core extension sublibrary, adds lots of methods to core Ruby classes. The addition to the `String` class provide some good examples. Active Support comes with a set of "inflections" on `String`, with methods like `pluralize` and `titleize`. Here are some examples (you'll need to run `gem install activesupport` to run them, if you don't have the gem installed already):

```irb 
>> require 'active_support'
=> true
>> require 'active_support/core_ext'
=> true
>> "person".pluralize
=> "people"
>> "little_dorrit".titleize
=> "Little Dorrit"
```
Any time you add new methods to Ruby core classes, you run the risk that someone else will add a method with the same name that behaves somewhat differently. A library like Active Support depends on the good faith of its users and on its own reputation: if you're using Active Support, you presumably know that you're entering into a kind of unwritten contract not to override its methods or load other libraries that do so. In that sense, Active Support is protected by its own reputation and breadth of usage. You can certainly use Active Support if it gives you something you want or need, but don't take it as a signal that it's generally okay to add methods to core classes. You need to be quite circumspect about doing so.

Another way to add functionality to existing Ruby classes and modules is with a passive hook or pass-through technique.

### *Pass-through overrides* ### 
A *pass-through* method change involves overriding an existing method in such a way that the original version of the method ends up getting called along with the new version. The new version does whatever it needs to do and then passes its arguments along to the original version of the method. It relies on the original method to provide a return value. (As you know from the `match` and `gsub!` override examples, calling the original version of a method isn't enough if you're going to change the basic interface of the method by changing its return value.)

You can use pass-through overrides for a number of purposes, including logging and debugging:

```ruby
class String
  alias __old_reverse__ reverse
  def reverse
    $stderr.puts "Reversing a string!"
    __old_reverse__
  end
end
puts "David".reverse 
```
The output of this snippet is as follows:

```irb 
Reversing a string!
divaD
```
The first line is printed to `STDERR`, and the second line is printed to `STDOUT`. The example depends on creating an alias for the original `reverse` and then calling that alias at the end of the new `reverse`. 

**Aliasing and its aliases** 
In addition to the `alias` keyword, Ruby has a method called `alias_method`, which is a private instance method of `Module`. The upshot is that you can create an alias for a method either like this:

```ruby
class String 
  alias __old_reverse__ reverse
end
```
Or like this:

```ruby 
class String 
  alias_method :__old_reverse__, :reverse 
end
```
Because it's a method and not a keyword, `alias_method` needs objects rather than bare method names as its arguments. It can take symbols or strings. Note also that the arguments to `alias` don't have a comma between them. Keywords get to do things like that, but methods don't.

--
It's possible to write methods that combine the additive and pass-through philosophies. Some examples from Active Support demonstrate how to do this.

#### ADDITIVE/PASS-THROUGH HYBRIDS #### 
An *additive/pass-through hybrid* is a method that has the same name as an existing core method, calls the old version of the method (so it's not an out-and-out replacement), and adds something to the method's interface. In other words, it's an override that offers a superset of the functionality of the original method.

Active Support features a number of additive/pass-through hybrid methods. A good example is the `to_s` method of the `Time` class. Unchanged, `Time#to_s` provides a nice humna-readable string representing the time:

```irb 
>> Time.now.to_s
=> "2018-07-02 17:29:59 +0000"
```
Active Support adds to the method so that it can take an argument indicating a specific kind of formatting. For example (assuming have you required `active_support`) you can format a `Time` object in a manner suitable for database insertion like this:

```irb 
>> Time.now.to_s(:db)
=> "2018-07-02 17:31:10"
```
If you want the date represented as a number, as for the `:number` format:

```irb 
>> Time.now.to_s(:number)
=> "20180702173158"
```
The `:rfc822` argument nets a time formatted in RFC822 style, the standard date format for dates in email headers. It's similar to the `Time#rfc822` method:

```irb 
>> Time.now.to_s(:rfc822)
=> "Mon, 02 Jul 2018 17:33:07 +0000"
```
The various formats add to `Time#to_s` work by using `strftime`, which wraps the system call of the same name and lets you format times in a large number of ways. So there's nothing in the modified `Time#to_s` that you couldn't do yourself. The optional argument is added for your convenience (and of course the database-friendly `:db` format is of interest mainly if you're using Active Support in conjunction with an object-relational library, such as `ActiveRecord`). The result is a superset of `Time#to_s`. You can ignore the add-ons, and the method will work like it always did.

As with pure method addition (such as `String#pluralize`), the kind of supersetdriven override of core methods represented by these examples entails some risk: specifically, the risk of collision. It is likely that you'll end up loading two libraries that both add an optional `:db` argument to `Time#to_s`? No, it's unlikely-but it's possible. Once again, a library like Active Support is protected by its high profile: if you load it, you're probably familiar with what it does and will know not to override the overrides. Still, it's remotely possible that another library you load might class with `Active Support`. As always, it's difficult or impossible to reduce the risk of collision to zero. You need to protect yourself by familiarizing yourself with what every library does and by testing your code sufficiently.

The last major approach to overriding core Ruby behavior we'll look at-and the safest way to do it-is the addition of functionality on a strictly per-object basis, using `Object#extend`.
