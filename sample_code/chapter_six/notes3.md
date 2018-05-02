### *The importance of being each* ###
The idea of `each` is simple: you run the `each` method on a collection object, and `each` yields each item in the collection to your code block, one at a time. Ruby has several collection classes, and even more classes that are sufficiently collection-like to support an `each` method. You'll see two chapters devoted to Ruby collections. Here we'll recruit the humble array for our examples.

Here's a simple `each` operation:

```ruby
array = [1,2,3,4,5]
array.each {|e| puts "The block just got handed #{e}." }
```
The output of the `each` call looks like this in an irb session:
```irb
>> array.each {|e| puts "The block just got handed #{e}." }
The block just got handed 1.
The block just got handed 2.
The block just got handed 3.
The block just got handed 4.
The block just got handed 5.
=> [1, 2, 3, 4, 5]
```
The last line isn't method output; it's the return value of `each`, echoed back by irb. The return value of `each`, when it's given a block, is its receiver, the original array. (When it isn't given a block, it returns an enumerator; you'll learn about those in chapter 10.) Like `times`, `each` doesn't have an exciting return value. All the interest lies in the fact that it yields values to the block.

To implement `my_each`, we'll take another step along the lines of iteration refinement. With `my_loop`, we iterated forever. With `my_times`, we iterated *n* times. With `my_each`, the number of iterations-the number of times the method yields-depends upon the size of the array.

We need a counter to keep track of where we are in the array and to keep yielding until we're finished. Conveniently, arrays have a `size` method, which makes it easy to determine how many iterations (how many "rotations in the air") need to be performed. As a return value for the method, we'll use the original array object:

```ruby
class Array
  def my_each
    c = 0
    until c == size
      yield(self[c])      #<--- Uses [] to get current array element
      c += 1
    end
    self
  end
end
```
A trial run of `my_each` produces the result we're aiming for:

```irb
>> array = [1,2,3,4,5]
>> array.my_each {|e| puts "The block just got handed #{e}." }
The block just got handed 1.
The block just got handed 2.
The block just got handed 3.
The block just got handed 4.
The block just got handed 4.
=> [1, 2 ,3 , 4, 5]
```
We've successfully implemented at least a simple version of `each`. The nice thing about `each` is that it's so vanilla: all it does is toss values at the code block, one at a time, until it runs out. One important implication of this is that it's possible to build any number of more complex, semantically rich iterators *on top of* `each`. We'll finish this reimplementation exercise with one such method: `map`, which we saw briefly in an earlier section. Learning a bit about `map` will also take us into some further nuances of code block writing and usage.

## Extra Credit: Define `my_each` in terms of `my_times` ##
An interesting exercise is to define `my_each` using the existing definition of `my_times`. You can use the `size` method to determine how many iterations you need and then perform them courtesy of `my_times` like so:

```ruby
class Array
  def my_each
    size.my_times do |i|
      yield self[i]
    end
    self
  end
end
```
Using `my_times` saves you the trouble of writing loop-counter code in `my_each`. But it's a bit backward: many of Ruby's iterators are built on top of `each`, not the other way around. Given the definition of `my_each`, how would you use it in an implementation of `my_times`?

### *From each to map* ###
Like `each`, `map` walks through an array one element at a time and yields each element to the code block. The difference between `each` and `map` lies in the return value: `each` returns its receiver, but `map` returns a new array. The new array is always the same size as the original array, but instead of the original elements, the new array contains the accumulated return values of the code block from the iterations.

Here's a `map` example. Notice that the return value contains new elements; it's not just the array we started with:

```irb
2.3.1 :001 > names = ["David", "Alan", "Black"]
 => ["David", "Alan", "Black"]
2.3.1 :002 > names.map {|name| name.upcase }
 => ["DAVID", "ALAN", "BLACK"]
2.3.1 :003 >
```
The mapping results in a new array, each of whose elements corresponds to the element in the same position in the original array but processed through the code block. The piece of the puzzle that `map` adds to our analysis of iteration is the idea of the code block returning a value *to* the method that yielded to it. And indeed it does: just as the method can yield a value, so too can the block return a value. The return value comes back as the value of the call to `yield`.

To implement `my_map` then, we have to arrange for an accumulator array, into which we'll drop the return values of the successive calls to the code block. We'll then return the accumulator array as the result of the entire call to `my_map`.

Let's start with a preliminary but not final implementation, in which we don't build on `my_each`

```ruby
class Array
  def my_map
    c = 0
    acc = []    #<--- Initializes accumulator array
    until c == size
      acc << yield(self[c])   #<--- Captures return value from block in accumulator array
      c += 1
    end
    acc #<--- returns the accumulator array
  end
end
```
We now get the same results from `my_map` that we did from `map`:

```irb
>> name.my_map {|name| name.upcase}
=> ["DAVID", "ALAN", "BLACK"]
```
Like `my_each`, `my_map` yields each element of the array in turn. Unlike `my_each`, `my_map` stores the value that comes back from the block. That's how it accumulates the mapping of the old values to the new values: the new values are based on the old values, processed through the block.

But our implementation of `my_map` fails to deliver on the promise of `my_each`-the promise being that `each` serves as the vanilla iterator on top of which the more complex iterators can be built. Let's reimplement `map`. This time, we'll write `my_map` in terms of `my_each`

### BUILDING MAP ON TOP OF EACH ###
Building `map` on top of `each` is almost startlingly simple:

```ruby
class Array
  # put the definition of my_each here
  def my_each
    c = 0
    until c == size
      yield(self[c])      #<--- Uses [] to get current array element
      c += 1
    end
    self
  end

  def my_map
    acc = []
    my_each {|e| acc << yield(e)}
    acc
  end
end
```
We piggyback on the vanilla iterator, allowing `my_each` to do the walk-through of the array. There's no need to maintain an explicit counter or to write an `until` loop. We've already got that logic; it's embodied in `my_each`. In writing `my_map`, if makes sense to take advantage of it.

There's much, much more to say about iterators, and in particular, the ways Ruby builds on `each` to provide an extremely rich toolkit of collection-processing methods. We'll go down that avenue later on. Here, meanwhile, let's delve a bit more deeply into some of the nuts and bolts of iterators-starting with the assignment and scoping rules that govern their use of parameters and variables.

### *Block parameters and variable scope* ###
You've seen that block parameters are surrounded by pipes, rather than parentheses as method parameters are. But you can use what you've learned about method arguments to create block parameter lists. Remember the  `args_unleashed` method from chapter 2?

```ruby
def args_unleashed(a,b=1,*c,d,e)
  puts "Arguments: "
  p a,b,c,d,e
end
```
Here's a block-based version of the method:

```ruby
def block_args_unleashed
  yield(1,2,3,4,5)
end

block_args_unleashed do |a,b=1,*c,d,e|
  puts "Arguments: "
  p a,b,c,d,e
end
```
The parameter bindings and program output are the same as they were with the original version:

```irb
Arguments:
1
2
[3]
4
5
```
What about scope? A method definition, as you know, starts a new local scope. Blocks are a little more complicated.

Let's start with a simple case: inside a block, you refer to a variable (not a block parameter; just a variable) called `x`, and you've already got a variable called `x` in scope before you write the block:

```ruby
def block_scope_demo
  x = 100
  1.times do     #<--- Single iteration serves to create code block context
    puts x
  end
end
```
When you run the method (which includes a handy `puts` statement), you'll see that the `x` inside the block is the same as the `x` that existed already:

`block_scope_demo` <--- **Output: 100**

Now, what about assigning to the variable inside a block? Again, it turns out that the variable inside the block is the same as the one that existed prior to the block, as you can see by changing it inside the block and then printing it out after the block is finished:

```ruby
def block_scope_demo_2
  x = 100
  1.times do
    x = 200
  end
  puts x
end
block_scope_demo_2   #<--Output: 200
```
Blocks, in other words, have direct access to variables that already exist (such as `x` in the example). However, block parameters (the variable names between the pipes) behave differently non-parameter variables. If you have a variable of a given name in scope and also use that name as one of your block parameters, then the two variables-the one that exists already and the one in the parameter list-are *not* the same as each other.

**NOTE** Although it's important in its own right, the fact that blocks share local scope with the code that precedes them will take on further significance when we look at `Proc` objects and *closures* later on. You'll learn that blocks can serve as the bodies of anonymous function objects, and those objects preserve the local variables that are in scope at the time of their creation-even if the function objects get handed around other local scopes.

Look at the variables named `x` in this example:

```ruby
def block_local_parameter
  x = 100    #<--- Outer x (before block)
  [1,2,3].each do |x|     #<--- Block parameter x
    puts "Parameter x is #{x}"
    x = x + 10   #<--- Assignment to x inside block
    puts "Reassigned to x in block; it's now #{x}"
  end
  puts "Outer x is still #{x}"
end
```
The output from a call to this method is

```irb
Parameter x is 1
Reassigned to x in block; it's now 11
Parameter x is 2
Reassigned to x in block; it's now 12
Parameter x is 3
Reassigned to x in block; it's now 13
Outer x is still 100
```
The `x` inside the block isn't the same as the `x` outside the block, because `x` is used as a block parameter. Even reassigning to `x` inside the block doesn't overwrite the "outer" `x`. This behavior enables you to use any variable name you want for your block parameters without having to worry about whether a variable of the same name is already in scope.

Sometimes you may want to use a temporary variable inside a block, even if it isn't one of the parameters being assigned to when the block is called. And when you do this, it's nice not to have to worry that you're accidentally reusing a variable from outside the block. Ruby provides a special notation indicating that you want one or more variables to be local to the block, even if variables with the same name already exist: a semicolon in the black parameter list.

Here's an example, & note the semicolon in the parameter list:

```ruby
```
