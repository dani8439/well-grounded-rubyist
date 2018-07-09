# *Callable and runnable objects* #
Be warned: runnable objects have been at the forefront of difficult and changeable topics in recent versions of Ruby. There's no getting around the fact that there's a lot of disagreement about how they should work, and there's a lot of complexity involved in how they do work. Callable and runnable objects differ from each other, in both syntax and purpose, and grouping them together in one chapter is a bit of an expedient. But it's also an instructive way to view these objects. 

## *Basic anonymous functions: The Proc class* ## 
At its most straightforward, the notion of a *callable object* is embodied in Ruby through objects to which you can send the message `call`, with the expectation that some code associated with the objects will be executed. The main callable objects in Ruby are `Proc` objects, lambdas, and method objects. `Proc` objects are self-contained code sequences that you can create, store, pass around as method arguments, and, when you wish, execute with the `call` method. Lambdas are similar to `Proc` objects. Truth be told, a lambda *is* a `Proc` object, but one with slightly special internal engineering. The differences will emerge as we examine each in turn. Method objects represent methods, extracted into objects that you can, similarly, store, pass around, and execute. 

We'll start our exploration of callable objects with `Proc` objects.

**NOTE** For the same of conciseness, the term *proc* (in regular font) will serve in the text to mean `Proc` object, much as *string* refers to an instance of the class `String`. *Lambda* will mean an instance of the lambda style of `Proc` object. (Don't worry; you'll see what that means soon!) The term *function* is a generic term for standalone units of code that take input and return a value. There's no `Function` class in Ruby. Here, however, you'll sometimes see *function* used to refer to procs and lambdas. It's just another, slightly more abstract way of identifying those objects. 

### *Proc objects* ###
Understanding `Proc` objects thoroughly means being familiar with several things: the basics of creating and using procs; the way procs handle arguments and variable bindings; the role of procs as *closures*; the relationship between procs and code blocks; and the difference between creating procs with `Proc.new`, the `proc` method, the `lambda` method, and the literal lambda constructor `->`. There's a lot going on here, but it all fits together if you take it one layer at a time.

Let's start with the basic callable object: an instance of `Proc`, created with `Proc.new`. You create a `Proc` object by instantiating the `Proc` class, including a code block:

```ruby 
pr = Proc.new { puts "Inside a Proc's block" }
```
The code block becomes the body of the proc; when you call the proc, the bloc you provided is exectued. Thus if you call `pr`

```ruby 
pr.call 
```
it reports as follos:

```irb 
Inside a Proc's block
``` 
That's the basic scenario: a code block supplied to a call to `Proc.new` becomes the body of the `Proc` object and gets executed when you `call` that object. Everything else that happens, or that can happen, involves additions to and variations on this theme.

Remember that procs are objects. That means you can assign them to variables put them inside arrays, send them around as method arguments, and generally treat them as you would any other object. They have knowledge of a chunk of code (the code block they're created with) and the ability to execute that code when asked to. But they're still objects. 

**The proc method** 
The `proc` method takes a block and returns a `Proc` object. Thus you can say `proc { puts "Hi!" }` instead of `Proc.new { puts "Hi!" }` and get the same result. `Proc.new` and `proc` used to be slightly different from each other, with `proc` serving as a synonym for `lambda` (see further in chapter) and the `proc/lambda` methods producing specialized `Proc` objects that weren't quite the same as what `Proc.new` produced. Yes, it was confusing. But now, although there are still two variants of the `Proc` object, `Proc.new` and `proc` do the same thing, whereas `lambda` produces the other variant. At least the naming lines up more predictably.

--
Perhaps the most important aspect of procs to get a handle on is the relation between procs and code blocks. That relation is intimate and turns out to be an important key to further understanding.

### *Procs and blocks and how they differ* ### 
When you create a `Proc` object, you always supply a code block. But not every code block serves as the basis of a proc. The snippet

```ruby 
[1,2,3].each {|x| puts x * 10 }
```
involves a code block but does not create a proc. Yet the plot is a little thicker than that. A method can capture a block, objectified into a proc, using the special parameter syntax that you saw briefly in chapter 9:

```ruby 
def call_a_proc(&block)
  block.call
end 
call_a_proc { puts "I'm the block...or Proc...or something." }
```
The output isn't surprising:

```irb 
I'm the block...or Proc...or something.
```
But it's also possible for a proc to serve in place of the code block in a method call, using a similar special syntax:

```ruby
p = Proc.new { |x| puts x.upcase }
%w{ David Black }.each(&p)
```
Here's the output from that call to each:

```irb 
DAVID
BLACK
```
But the question remains: exactly what's going on with regard to procs and blocks? Why and how does the presence of (`&p`) convince `each` that it doesn't need an actual code block?

To a large extent, the relation between blocks and procs comes down to a matter of syntax versus objects.

#### SYNTAX (BLOCKS) AND OBJECTS (PROCS) ####
An important and often misunderstood fact is that a Ruby code block is not an object. This familiar trivial example has a receiver, a dot operator, a method name, and a code block:

```ruby
[1,2,3].each {|x| puts x * 10 }
```
The receiver is an object, but the code block isn't. Rather, the code block is part of the syntax of the method call.

You can put code blocks in context by thinking of the analogy with argument lists. In a method call with arguments

`puts c2f(100)`

the arguments are objects but the argument list itself-the whole `(100)` thing-isn't an object. There's no `ArgumentList` class, and there's no `CodeBlock` class.

Things get a little more complext in the case of bock syntax than in the case of argument lists, though, because of the way blocks and procs interpolate. An instance of `Proc` is an object. A code block contains everything that's needed to create a proc. That's why `Proc.new` takes a code block: that's how it finds out what the proc is supposed to do when it gets called.

One important implication of the fact that the code block is a syntactic construct and not an object is that code blocks aren't method arguments. The matter of providing arguments to a method is independent of whether a code block is present, just as the presence of a block is independent of the presence or absence of an argument list. When you provide a code block, you're not sending the block to the method as an argument; you're providing a code block, and that's a thing unto itself. Let's take another, closer look now at the conversion mechanisms that allow code blocks to be captures as procs, and procs to be pressed into service in place of code blocks. 

### *Block-proc conversions* ### 
Conversion between blocks and procs is easy-which isn't too surprising, because the purpose of a code block is to be executed, and a proc is an object whose job is to provide execution access to a previously defined code block. We'll look first at block-to-proc conversions and then at the use of procs in place of blocks.

#### CAPTURING A CODE BLOCK AS A PROC* ####
Let's start with another simple method that captures its code block as a `Proc` object and subsequently calls that object:

```ruby 
def capture_block(&block)
  block.call 
end
```
What happens is a kind of implicit call to `Proc.new`, using the same block. The proc thus created is bound to the parameter `block`. 

Figure below provides an artist's rendering of how a code block becomes a proc. The first event (at the bottom of the figure) is the calling of the method `capture_block` with a code block. Along the way, a new `Proc` object is created (step 2) using the same block. It's this `Proc` object to which the variable `block` is bound, inside the method body (step 3).

The syntactic element (the code block) thus serves as the basis for the creation of an object. The "phantom" step of creating the proc from the block also explains the need for the special `&`-based syntax. A method call can include both an argument list and a code block. WIthout a special flag like `&`, Ruby has no way of knoiwng that you want to stop binding parameters to regular arguments and instead perform a block-to-proc conversion and save the results.

The `&` also makes an appearance when you want to do the conversion the other way: using `Proc` object instead of a code block.

   def capture_block(&block)
     puts "Got block as proc"    (#3) <---------
     block.call                                 |
   end                                          |
                              Proc.new { puts "Inside the block" }  (#2)
                                                ↑
                                                |
                                                |
                                capture_block { puts "Inside the block" } (#1)

#### USING PROCS FOR BLOCKS ####
Here's how you might call `capture_block` using a proc instead of a code block:

```ruby 
p = Proc.new { puts "This proc argument will serve as a code block." }
capture_block(&p)
```
The output is

`This proc argument will serve as a code block.`

The key to using a proc as a block is that you actually use it instead of a block: you send the proc as an argument to the method you're calling. Just as you tag the parameter in the method definition with the `&` character to indicate that it should convert the block to a proc, so too you use the `&` on the method-calling side to indicate that the proc hsould do the job of a code block.

Keep in mind that because the proc tagged with `&` is serving as the code block, you can't send a code block in the same method call. If you do, you'll get an error. The call

```ruby
capture_block(&p) { puts "This is the explicit block" }
```
results in error "both block arg and actual block given." Ruby can't decide which entity-the proc or the block-is serving as the block, so you can use only one.

An interesting subplot is going on here. Like many Ruby operators, the `&` in `&p` is a wrapper around a method: namely, the method `to_proc`. Calling `to_proc` on a `Proc` object returns the `Proc` object itself, rather like calling `to_s` on a string or `to_i` on an integer.

But note that you sitll need the `&`. If you do this

```ruby 
capture_block(p)
    #OR THIS
capture_block(p.to_proc)
```
the proc serves as a regular argument to the method. You aren't triggering the special behavior whereby a proc argument does the job of a code block.

Thus the `&` in `capture_block(&p)` does two things: it triggers a call to `p`'s `to_proc` method, and it tells Ruby that the resulting `Proc` object is serving as a code block stand in. And because `to_proc` is a method; it's possible to use it in a more general way. 

#### GENERALIZING TO_PROC ####
In theory, you can define `to_proc` in any class or for any object, and the `&` technique will then work for the affected objects. You probably won't need to do this a lot; the two classes where `to_proc` is most useful are `Proc` (discussed earlier) and `Symbol` (discussed in the next section), and `to_proc` behavior is already built into those classes. But looking at how to roll `to_proc` into your own classes can give you a sense of the dynamic power that lies below the surface of the language.

Here is a rather odd but instructive piece of code:

```ruby 
class Person
  attr_accessor :name                   #<----1.
  def self.to_proc                              #<----2.
    Proc.new {|person| person.name }
  end
end
d = Person.new                                        #<----3.
d.name = "David"
m = Person.new
m.name = "Matz"
puts [d,m].map(&Person)                                       #<----4.
```
The best starting point, if you want to follow the trail of breadcrumbs through this code, is the last line(#4). Here, we have an array of two `Person` objects. We're doing a `map` operation on the array. As you know, `Array#map` takes a code block. In this case, we're using a `Proc` object instead. That proc is designated in the argument list as `&Person`. Of course, `Person` isn't a proc; it's a class. To make sense of what it sees, Ruby asks `Person` to represent itself as a proc, which means an implicit call to `Person`'s `to_proc` method (#2).

That method, in turn, produces a simple `Proc` object that takes one argument and calls the `name` method on that argument. `Person` objects have `name` attributes (#1). And the `Person` objects created for purposes of trying out hte code, sure enough, have names (#3). All of this means that the mapping of the array of `Person` objects (`[d,m]`) will collect the `name` attributes of the objects, and the entire resulting array will be printed out (thanks to `puts`).

It's a long way around. And the design is a bit loose; after all, any method that takes a block could use `&Person`, which might get weird if it involved non-person objects that didn't have a `name` method. But the example shows you that `to_proc` can serve as a powerful conversion hook. And that's what it does in the `Symbol` class, as you'll see next.

### *Using Symbol#to_proc for conciseness* ### 
The built-in-method `Symbol#to_proc` comes into play in situations like this:

`%w{ david black}.map(&:capitalize)`

The result is 

`["David", "Black"]`

The symbol `:capitalize` is interpreted as a message to be sent to each element of the array in turn. The previous code is thus equivalent to

`%w{ david black }.map {|str| str.capitalize }`

but, as you can see, more concise.

If you saw `&:capitalize` or a similar construct in code, you might think it was cryptic. But knowing how it parses-knowing that `:capitalize` is a symbol and `&` is a `to_proc` trigger-allows you to interpret it correctly and appreciate its expressiveness.

The `Symbol#to_proc` situation lends itself nicely to the elimination of parentheses:

`%w{ david black }.map &:capitalize`

By taking off the parentheses, you can make the proc-ified symbol look like it's in code-block position. There's no necessity for this, of course, and you should kep in mind that when you use the `to_proc &` indicator, you're sending the proc as an argument flagged with `&` and not providing a literal code block.

`Symbol#to_proc` is, among other things, a great example of something that Ruby does for you that you could, if you had to, do easily yourself. Here's how.

#### IMPLEMENTING SYMBOL#TO_PROC #### 
Here's the `to_proc` case study again:

`%w{ david black}.map(&:capitalize)`

We know it's equivalent to this:

`%w{ david black }.map {|str| str.capitalize }`

And the same thing could also be written like this:

`%w{ david black }.map {|str| str.send(:capitalize) }`

Normally, you wouldn't write it that way, because there's no need to go to the trouble of doing a `send` if you're able to call the method using regular dot syntax. But the `send`-based version points the way to an implementation of `Symbol#to_proc`. The job of the block in this example is to send the symbol `:capitalize` to each element of the array. That means the `Proc` produced by `:capitalize#to_proc` has to send `:capitalize` to its argument. Generalizing from this, we can come up with this simple (almost anticlimactic, one might say) implementation of `Symbol#to_proc`:

```ruby 
class Symbol
  def to_proc
    Proc.new {|obj| obj.send(self) }
  end
end
```
This method returns a `Proc` object that takes one argument and sends `self` (which will be whatever symbol we're using) to that object.

You can try the new implementation in irb. Let's throw in a greeting from the method so it's clear that the version being used is the one we've just defined:

```ruby
class Symbol
  def to_proc
    puts "In the new Symbol#to_proc!"
    Proc.new {|obj| obj.send(self) }
  end
end
```
Save this code to a file called sym2proc.rb, and from the directory to which you've saved it, pull it into irb by using the `-I` (include path in load path) flag and the `-r` (require) flag:

`irb --simple-prompt -I. -r sym2proc` 

Now you'll see the new `to_proc` in action when you use the `&`:*symbol* technique:

```irb 
>> %w{ david black }.map(&:capitalize)
In the new Symbol#to_proc!
=> ["David", "Black"]
```
You're under no obligation to use the `Symbol#to_proc` shortcut (let alone implement it), but it's useful to know how it works so you can decide when it's appropriate to use.

One of the most important aspects of `Proc` objects is their service as *closures*: anonymous functions that preserve the local variable bindings that are in effect when the procs are created. We'll look next at how procs operate as closures.

### *Procs as closures* ###
You've already seen that the local variables you use inside a method body aren't the same as the local variables you use in the scope of the method call:

```ruby 
def talk
  a = "Hello"
  puts a
end
a = "Goodbye"
talk      #<---Output: Hello
puts a      #<----Output: Goodbye
```
The identifier `a` has been assigned twice, but the two assignments (the two `a` variables) are unrelated to each other.

You've also seen that code blocks preserve the variables that were in existence at the time they were created. All code blocks do this:

```irb 
>> m = 10
=> 10
>> [1,2,3].each {|x| puts x * m }
10
20
30
=> [1, 2, 3]
```
This behavior becomes significant when the code block serves as the body of a callable object:

```ruby 
def multiply_by(m)
  Proc.new {|x| puts x * m }
end 
mult = multiply_by(10)
mult.call(12)    #<----Output: 120
```
In this example, the method `multiply_by` returns a proc that can be called with any argument but that always multiplies by the number sent as an argument to `multiply_by`. The variable `m`, whatever its value, is preserved inside the code block passed to `Proc.new` and therefore serves as the multiplier every time the `Proc` object returned from `multiply_by` is called.

`Proc` objects put a slightly different spin on scope. When you construct the code block for a call to `Proc.new`, the local variables you've created are still in scope (as with any code block). And those variables remain in scope inside the proc, no matter where or when you call it.

Look at the following listing and keep your eye on the two variables called `a`. 

```ruby
def call_some_proc(pr)
  a = "irrelevant 'a' in method scope"            #<----1.
  puts a
  pr.call                                     #<----2.
end
a = "'a' to be used in Proc block"                #<----3.
pr = Proc.new { puts a }
pr.call
call_some_proc(pr)
```
As in the previous example, there's an `a` in the method definition (#1) and an `a` in the outer (calling) scope (#3). Inside the method is a call to a proc. The code for that proc, we happen to know, consists of `puts a`. Notice that when the proc is called from inside the method (#2), the `a` that's printed out isn't the `a` defined in the method; it's the `a` from the scope where the proc was originally created:

```irb 
'a' to be used in Proc block
irrelevant 'a' in method scope
'a' to be used in Proc block
```
The `Proc` object carries its context around with it. Part of that context is a variable called `a` to which a particular string is assigned. That variable lives on inside the `Proc`. 

A piece of code that carries its creation context around with it like this is called a *closure*. Creating a closure is like packing a suitcase: wherever you open the suitcase, it contains what you put in when you packed it. When you open a closure (by calling it(, it contains what you put into it when it was created. Closures are important because they preserve the partial running state of a program. A variable that goes out of scope when a method returns may have something interesting to say later on-and with a closure, you can preserve that variable so it can continue to provide information or calculation results.

The classic closure example is a counter. Here's a method that returns a closure (a proc with the local variable bindings preserved). The proc serves as a counter; it increments its variable every time it's called:

```ruby 
def make_counter
  n = 0
  return Proc.new { n += 1 }                #<----1.
end
c = make_counter                         #<----2.
puts c.call
puts c.call
d = make_counter                     #<----3.
puts d.call
puts c.call                       #<----4.
```
The output is 

```irb
1
2
1
3
```
The logic in the proc involves adding 1 to `n` (#1); so the first time the proc is called, it evaluates to 1; the second time to 2; and so forth. Calling `make_counter` and then calling the proc it returns confirms this: first 1 is printed, and then 2 (#2). But a new counter starts again from 1; the second call to `make_counter` (#3) generates a new, local `n`, which gets preserved in a different proc. The different between the two counters is made clear by the third call to the first counter, which prints 3 (#4). It picks up where it left off, using the `n` variable that was preserved inside it at the time of its creation.

Like any code block, the block you provide when you create a `Proc` object can take arguments. Let's look in detail at how block arguments and parameters work int eh course of `Proc` creation.

### *Proc parameters and arguments* ### 
Here's an instantiation of `Proc` with a block that takes one argument:

```ruby 
pr = Proc.new {|x| puts "Called with argument #{x}" }
pr.call(100)
```
The output is

```irb
Called with argument 100
```
Procs differ from methods, with respect to argument handling, in that they don't care whether they get the right number of arguments. A one-argument proc, like this

```irb 
>> pr = Proc.new {|x| p x }
=> #<Proc:0x00000001da37b0@(irb):1>
```
can be called with any number of arguments, including none. If it's called with no arguments, its single parameter gets set to `nil`.

```irb 
>> pr.call
nil
=> nil
```
If it's called with more than one argument, the single parameter is bound to the first argument, and the remaining arguments are discarded:

```irb 
>> pr.call(1,2,3)
1
=> 1
```
(Remember that the single value printed out is the value of the variable `x`)

You can, of course, also use "sponge" arguments and all the rest of the parameterlist paraphernalia you've already learned about. But keep in mind the point that procs are a little less fussy than methods about their argument count-their *arity*. Still, Ruby provides a way to create fussier functions: the `lambda` method.g
