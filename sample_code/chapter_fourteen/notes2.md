## *Creating functions with lambda and ->* ## 
Like `Proc.new`, the `lambda` method returns a `Proc` object, using the provided code block as the function body:

```irb 
>> lam = lambda { puts "A lambda!" }
=> #<Proc:0x00000001d965d8@(irb):4 (lambda)>
>> lam.call
A lambda!
=> nil
```
As the inspect string suggests, the object returned from `lambda` is of class `Proc`. But note the (`lambda`) notation. There's no `Lambda` class, but there is a distinct lambda flavor of the `Proc class. And lambda-flavored procs are a little different from their vanilla cousins, in three ways.

First, lambdas require explicit creation. Wherever Ruby creates `Proc` objects implicitly, they're regular procs and not lambdas. That means chiefly that when you grab a code block in a method, like this

`def m(&block)`

the `Proc` object you've grabbed is a regular proc, not a lambda.

Second, lambdas differ from procs in how they treat the `return` keyword. `return` inside a lambda triggers an exit from the body of the lambda to the code context immediately containing the lambda. `return` inside a proc triggers a return from the method in which the proc is being executed. Here's an illustration of the difference:

```ruby 
def return_test 
  l = lambda { return }
  l.call                              #<----1.
  puts "Still here!"
  p = Proc.new { return }
  p.call                                   #<----2.
  puts "You won't see this message!"            #<----3.
end
return_test
```
The output from this snippet is `"Still here!"` You'll never see the second message (#3) printed out because the call to the `Proc` object (#2) triggers a return from the `return_test` method. But the call to the lambda (#1) triggers a return (an exit) from the body of the lambda, and execution of the method continues where it left off.

**WARNING** Because `return` from inside a (non-lambda-flavored) proc triggers a return from the enclosing method, calling a proc that contains `return` when you're not inside any method produces a fatal error. To see a demo of this error, try it from the command line: `ruby -e 'Proc.new { return }.call`. 

--

Finally, and most important, lambda-flavored procs don't like being called iwth the wrong number of arguments. They're fussy:

```irb 
>> lam = lambda { |x| p x }
=> #<Proc:0x00000001df7658@(irb):1 (lambda)>
>> lam.call(1)
1
=> 1
>> lam.call
ArgumentError: wrong number of arguments (given 0, expected 1)
>> lam.call(1,2,3)
ArgumentError: wrong number of arguments (given 3, expected 1)
```
In addition to the lambda method, there's a lambda literal constructor.

#### THE "STABBY LAMBDA" CONSTRUCTOR, -> #### 
The lambda constructor (nicknamed the "stabby lambda") works like this:

```irb 
>> lam = -> { puts "hi" }
=> #<Proc:0x00000001de6290@(irb):5 (lambda)>
>> lam.call
hi
=> nil
```
If you want your lambda to take arguments, you need to put your parameters in parentheses after the `->`, *not* in vertical pipes inside the code block:

```irb 
>> mult = ->(x,y) { x * y }
=> #<Proc:0x00000001d826a0@(irb):7 (lambda)>
>> mult.call(3,4)
```
A bit of history: the stabby lambda exists in the first place because older versions of Ruby had trouble parsing method-style argument syntax inside the vertical pipes. For example, in Ruby 1.8 you couldn't use default-argument syntax like this:

```irb 
lambda {|a,b=1| "Doesn't work in Ruby 1.8 -- syntax error!" }
```
The problem was that Ruby didn't know whether the second pipe was a second delimiter or a bitwise OR operator. The stabby lambda was introduced to make it possible to use full-blown method-style arguments with lambdas:

```irb
->(a, b=1) { "Works in Ruby 1.8!" }
```
Eventually, the parser limitation was overcome; you can now use method-argument syntax, in all its glory, between the vertical pipes ina  code block. Strictly speaking, therefore, the stabby lambda is no longer necessary. But it attracted a bit of a following, and you'll see it used fairly widely.

In practice, the things you call most often in Ruby aren't procs or lambdas but methods. So far, we've viewed the calling of methods as something we do at one level of remove: we send messages to objects, and the objects execute the appropriately named method. But it's possible to handle methods as objects, as you'll see next.

## *Methods as objects* ## 
Methods don't present themselves as objects until you tell them to. Treating methods as objects involves *objectifying* them.

### *Capturing Method objects* ### 
You can get hold of a `Method` object by using the `method` method with the name of the method as an argument (in string or symbol form):

```ruby
class C
  def talk
    puts "Method-grabbing test! self is #{self}."
  end
end
c = C.new
meth = c.method(:talk)
```
At this point, you have a `Method` object-specifically, a *bound* `Method` object: it isn't the method `talk` in the abstract, but rather the method `talk` specifically bound to the object `c`. If you send a `call` message to `meth`, it knows to call itself with `c` in the role of `self`:

`meth.call` 

Here's the output: 

`Method-grabbing test! self is #<C:0x000000010e3ef8>.`

You can also unbind the method from its object and then bind it to another object, as long as that other object is of the same class as the original object (or a subclass):

```ruby 
class D < C 
end 
d = D.new 
unbound = meth.unbind 
unbound.bind(d).call
```
Here, the output tells you that the method was, indeed, bound to a `D` object (d) at the time it was executed:

`Method-grabbing test! self is #<D:0x00000002487590>.`

To get hold of an unbound method object directly without having to call `unbind` on a bound method, you can get it from the class rather than from a specific instance of the class using the `instance_method` method. This single line is equivalent to a `method` call plus and `unbind` call:

```ruby 
unbound = C.instance_method(:talk)
```
After you have the unbound method in captivity, so to speak, you can use `bind` to bind it to any instance of either `C` or a `C` subclass like `D`. 

But why would you?

### *The rationale for methods as objects* ### 
There's no doubt that unbinding and binding methods is a specialized technique, and you're not likely to need more than a reading knowledge of it. But aside from the principle that at least a reading knowledge of anything in Ruby can't be a bad idea, on some occasions the best answer to a "how to" question is, "With unbound methods."

Here's an example. The following question comes up periodically in Ruby forums:

*Suppose I've got a class hierarcy where a method gets redefined:* 

```ruby 
class A 
  def a_method 
    puts "Definition in class A"
  end 
end
class B < A 
  def a_method 
    puts "Definition in class B (subclass of A)"
  end 
end 
class C < B
end 
```
*And I've got an instance of the subclass:* 

```ruby 
c = C.new 
```
*Is there any way to get that instance of the lowest class to respond to the message (`a_method`) by executing the version of the method in the class two classes up the chain?* 

By default, of course, the instance doesn't do that; it executes the first matching method it finds as it traverses the method search path:

`c.a_method` 

The output is:

`Definition in class B (subclass of A)`

But you can force the issue through an unbind and bind operation:

`A.instance_method(:a_method).bind(c).call`

Here the output is

`Definition in class A`

You can even stash this behavior inside a method in class `C`:

```ruby 
class C
  def call_original
    A.instance_method(:a_method).bind(self).call
  end
end
```
and then call `call_original` directly on `c`.

This is an example of a Ruby technique with a paradoxical status: it's within the realm of things you should understand, as someone gaining mastery of RUby's dynamics, but it's outisde the realm of anything you should probably do. If you find yourself coercing Ruby objects to respond to methods you've already redefined, you should review the design of your program and find a way to get objects to do what you want as a result of and not in spite of the class/module hierarcy you've created.

Still, methods are callable objects, and they can be detached (unbound) from their instances. As a Ruby dynamics inductee, you should at least have recognition-level knowledge of this kind of operation. 

We'll linger in the dynamic stratosphere for a while, looking next at the `eval` family of methods: a small handful of methods with special powers to let you run strings as code and manipulate scope and self in some interesting, use-case-drive ways. 

**Alternative techniques for calling callable objects** 
So car we've exclusively used the `call` method to call callable objects. You do, however, have a couple of other options.

One is the square-brackets method/operator, which is a synonym for `call`. You place nay arguments inside the brackets:

```ruby 
mult = lambda {|x,y| x * y } 
twelve = mult[3,4]
```
If there are no arguments, leave the brackets empty.

You can also call callable objects using the `()` method:

`twelve = mult.(3,4)`

Note the dot before the opening parenthesis. The `()` method has to be called using a dog; you can't just append the parentheses to a `Proc` or `Method` object the way you would with a method name. If there are no arguments, leave the parentheses empty. 

## *The eval family of methods* ## 
Like many languages, Ruby has a facility for executing code stored in the form of strings at runtime. In fact, Ruby has a cluster of techniques to do this, each of which serves a particular purpose but all of which operate on a similar principle: that of saying in the middle of a program, "Whatever code strings you might have read from the program file before starting to execute this program, execute *this* code string right now."

The most straightforward method for evaluating a string as code, and also the most dangerous, is the method `eval`. Other `eval-`family methods are a little softer, not because they don't also evaluate strings as code but because that's not all they do. `instance_eval` brings about a temporary shift in the value of self, and `class_eval` (also known by the synonym `module_eval`) takes you on an ad hoc side trip into the context of a class-definition block. These `eval`-family methods can operate on strings, but they can also be called with a code block; thus they don't always operate as bluntly as `eval`, which executes strings.

Let's unpack this description with a closer look at `eval` and the other `eval` methods.

### *Executing arbitrary strings as code with eval* ### 
`eval` executes the string you give it:

```irb 
>> eval("2+2")
=> 4
```
`eval` is the answer, or at least one answer, to a number of frequently asked questions, such as, "Hoe do I write a method and give it a name someone types in?" you can do so like this:

```ruby
print "Method name: "
m = gets.chomp
eval("def #{m}; puts 'Hi!'; end")
eval(m)
```
This code outputs:

```irb 
Hi!
```
A new method is being written. Let's say you run the code and type in `abc`. The string you subsequently use `eval` on is

```ruby 
def abc; puts 'Hi!'; end
```
After you apply `eval` to that string, a method called `abc` exists. The second `eval` executes the string `abc`-which, given the creation of the method is the previous line, constitutes a call to `abc`. When `abc` is called, "Inside new method!" is printed out.

**The Binding class and eval-ing code with a binding** 
Ruby has a class called `Binding` whose instances encapsulate the local variable bindings in effect at a given point in execution. And a top-level method called `binding` returns whatever the current binding is.

The most common use of `Binding` objects is in the position of second argument to `eval`. If you provide a binding in that position, the string being `eval`-ed is executed in the context of the given binding. Any local variables used inside the `eval` string are interpreted in the context of that binding.

Here's an example, the method `use_a_binding` takes a `Binding` object as an argument and uses it as the second argument to a call to `eval`. The `eval` operation, therefore, uses the local variable bindings represented by the `Binding` object:

```ruby 
def use_a_binding(b)
  eval("puts str", b)
end
str = "I'm a string in top-level binding!"
use_a_binding(binding)

# Output: I'm a string in top-level binding!
```
The output of this snippet is `"I'm a string in top-level binding!"`. That string is buond to the top-level variable `str`. Although `str` isn't in scope inside the `use_a_binding` method, it's visible to `eval` thanks to the fact that `eval` gets a binding argument of the top-level binding, in which `str` is defined and bound.

Thus the string `"puts str"`, which otherwise would raise an error (because `str` isn't defined), can be `eval`-ed successfully in the context of the given binding.

---
`eval` gives you a lot of power, but it also harbors dangers-in some people's opinion, enough danger to rule it out as a usable technique. 

### *The dangers of eval* ### 
Executing arbitrary strings carries significant danger-especially (though not exclusively) strings that come from users interacting with your program. For example, it would be easy to inject a destructive command, perahps a system call to `rm-rf /*`, into the previous example. 

`eval` can be seductive. It'sabout as dynamic as a dynamic programming technique can get: you're evaluating strings of code that probably didn't even exist when you wrote the program. Anywhere that Ruby puts up a kind of barrier to absolute, easy manipulation of the state of things during the run of a program, `eval` seems to offer a way to cut through the red tape and do whatever you want. 

But as you can see, `eval` isn't a panacea. If you're running `eval` on a string you've written, it's generally no less secure than running a program file you've written. But any time an uncertain, dynamically generated string is involved, the dangers mushroom.

In particular, it's difficult to clean up user input (including input from web forms and files) to the point that you can feel safe about running `eval` on it. Ruby maintains a global variable called `$SAFE`, which you can set to a higher number (on a scale of 0 to 4) to gain protection from dangers like rogue file-writing requests. `$SAFE` makes life with `eval` a lot safer. Still, the best habit to get into is the habit of not using `eval`.

It isn't hard to find experienced and expert Ruby programmers (as well as programmers in other languages) who never use `eval` and never will. You have to decide how you feel abou tit, based on your knowledge of the pitfalls.

Let's move now to the wider `eval` family of methods. These methods can do the same kind of brute-force string evaluation that `eval` does, but they also have kinder, gentler behaviors that make then usable and useful. 

### *The instance_eval method* ### 
`instance_eval` is a specialized cousin of `eval`. It evaluates the string or code block you give it, changing `self` to be the receiver of the call to `instance_eval`:

```ruby
p self
a = []
a.instance_eval { p self }
```
This snippet outputs two different selfs:

```irb
main
[]
```
`instance_eval` is mostly useful for breaking into what would normally be another object's private date-particularly instance variables. Here's how to see the value of an instance variable belonging to any old object (in this case, the instance variable of `@x` of a `C` object:

```ruby
class C
  def initialize
    @x = 1
  end
end
c = C.new
c.instance_eval { puts @x }

# 1
```
This kind of prying into another object's state is generally considered impolite; if an object wants you to know something about its state, it provides methods through which you can inquire. Nevertheless, because Ruby dynamics are based on the changing identity of self, it's not a bad idea for the language to give us a technique for manipulating self directly.

**The instance_exec method** 
`instance_eval` has a close cousin called `instance_exec`. The difference between the two is that `instance_exec` can take arguments. Any argument you pass it will be passed, in turn, to the code block.

This enables you to do things like this:

```ruby
string = "A sample string"
string.instance_exec("s") {|delim| self.split(delim) }
# Output: ["A ", "ample ", "tring"]
```
(Note that you'd need to, if you already know the delimiter, but that's the basic technique.)

Unfortunately, which method is which-which of the two takes arguments and which doesn't-just has to be memorized. There's nothing in the terms `eval` or `exec` to help you out. Still, it's useful to have both on hand.

--
Perhaps the most common use of `instance_eval` is in the service of allowing simplified assignment code like this:

```ruby
david = Person.new do
  name = "David"
  age 55
end
```
This looks a bit like we're using accessors, except there's no explicit receiver and no equal signs. How would you make this code work?

Here's what the `Person` class might look like:

```ruby
class Person 
  def initialize(&block)
    instance_eval(&block)           #<----1.
  end 

  def name(name=nil)                     #<----2.
    @name ||= name                             #<----3.
  end 

  def age(age=nil)
    @age ||=age 
  end 
end
```
The key here is the call to `instance_eval` (#1), which reuses the code block that has already been passed in to `new`. Because the code block is being `instance_eval`'d on the new person object (the implicit `self` in the definition of `initialize`), the calls to `name` and `age` are resolved within the `Person` class. Those methods, in turn, act as hybrid setter/getters (#2): they take an optional argument, defaulting to `nil`, and set the relevant instance variables, conditionally, to the value of that argument. If you call them without an argument, they just return the current value of their instance variables (#3).

The result is that you can say `name "David"` instead of `person.name = "David"`. Lots of Rubyists find this kind of miniature DSL (domain-specific-language) quite pleasingly compact and elegant.

`instance_eval` (and `instance_exec`) will also happily take string and evaluate it in the switched `self` context. However, this technique has the same pitfalls as evaluating strings with `eval`, and should be used judiciously if at all.

The last member of the `eval` family of methods is `class_eval` (synonym: `module_eval`). 

### *Using class_eval(a.k.a. module_eval)* ### 
In essence, `class_eval` puts you inside a class-definition body:

```ruby 
c = Class.new
c.class_eval do
  def some_method
    puts "Created in class_eval"
  end
end
c_instance = c.new
c_instance.some_method

#Output: Created in class_eval
```
But you can do some things with `class_eval` that you can't do with the regular `class` keyword:

• Evaluate a string in a class-definition context.

• Open the class definition of an anonymous class.

• Use existing local variables inside a class-definition body.

The third item on this list is particularly noteworthy.

When you open a class with the `class` keyword, you start a new local-variable scope. But the block you use with the `class_eval` can see the variables created in the scope surrounding it. Look at the difference between the treatment of `var`, an outer-scope local variable, in a regular class-definition body and a block give to `class_eval`:

```irb
>> var = "initialized variable"
=> "initialized variable"
>> class C
>> puts var
>> end
NameError: undefined local variable or method `var' for C:Class
        from (irb):2
>> C.class_eval { puts var }
initialized variable
=> nil
```
The variable `var` is out of scope inside the standard class-definition block but still in scope in the code block passed to `class_eval`.

The plot thickens when you define an instance method inside the `class_eval` block:

```irb 
>> C.class_eval { def talk; puts var; end }
=> :talk
>> C.new.talk
NameError: undefined local variable or method `var' for #<C:0x00000001225370>
```
Like any `def`, the `def` inside the block starts a new scope-so the variable `var` is no longer visible.

If you wan to shoehorn an outer-scope variable into an instance method, you have to use a different technique for creating the method: the method `define_method`. You hand `define_method` the name of the method you want to create (as a symbol or a string) and provide a code block; the code block servves as the body of the method.

To get the outer variable `var` into an instance method of class `C`, you do this:

```irb 
>> C.class_eval { define_method("talk") { puts var } }
=> :talk
```
The return value of `define_method` is a symbol representing the name of the newly defined method.

At this point, the `talk` instance method of `C` will have access to the outer-scope variable `var`:

```irb 
>> C.new.talk
initialized variable
=> nil
```
You won't see techniques like this used as frequently as the standard class- and method-definition techniques. But when you see them, you'll know that they imply a flattened scope for local variables rather than the new scope triggered by the more common `class` and `def` keywords.

`define_method` is an instance method of the class `Module`, so you can call it on any instance of `Module` or `Class`. You can thus use it inside a regular class-definition body (where the default receiver `self` is the class object) if you want to sneak a variable local to the body into an instance method. That's not a frequently encountered scenario, but it's not unheard of.

Ruby lets you do lightweight concurrent programming using threads. We'll look at threads next.
