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

#### SYNTAX (BLOCKS) AND OBJECTS (PROCS) ####

### *Block-proc conversions* ### 

#### CAPTURING A CODE BLOCK AS A PROC* ####

#### USING PROCS FOR BLOCKS ####

#### GENERALIZING TO_PROC ####

### *Using Symbol#to_proc for conciseness* ### 

#### IMPLEMENTING SYMBOL#TO_PROC #### 

### *Procs as closures* ###

### *Proc parameters and arguments* ### 

## *Creating functions with lambda and ->* ## 

**WARNING** 

#### THE "STABBY LAMBDA" CONSTRUCTOR, -> #### 

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
