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
