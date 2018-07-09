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

### *Capturing Method objects* ### 

### *The rationale for methods as objects* ### 

**Alternative techniques for calling callable objects** 

## *The eval family of methods* ## 

### *Executing arbitrary strings as code with eval* ### 

**The Binding class and eval-ing code with a binding** 

### *The dangers of eval* ### 

### *The instance_eval method* ### 

**The instance_exec method** 

### *Using class_eval(a.k.a. module_eval)* ### 

## *Parallel execution with threads* ## 

### *Killing, stopping, and starting threads* ### 

**Fibers: A twist on threads** 

### *A threaded date server* ### 

### *Writing a chat server using sockets and threads* ### 

### *Threads and variables* ### 

### *Manipulating thread keys* ### 

#### A BASIC ROCK/PAPER/SCISSORS LOGIC IMPLEMENTATION #### 

#### USING THE RPS CLASS IN A THREADED GAME #### 

## *Issuing commands from inside Ruby programs* ## 

### *The system method and backticks* ### 

#### EXECUTING SYSTEM PROGRAMS WITH THE SYSTEM METHOD #### 

#### CALLING SYSTEM PROGRAMS WITH BACKTICKS #### 

**Some system command bells and whistles** 

### *Communicating with programs via open and popen 3* ### 

#### TALKING TO EXTERNAL PROGRAMS WITH OPEN #### 

#### TWO-WAY COMMUNICATION WITH OPEN3.POPEN3 #### 
