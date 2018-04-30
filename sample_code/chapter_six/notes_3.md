### *The importance of being each* ###
The idea of `each` is simple: you run the `each` method on a collection object, and `each` yields each item in the collection to your code block, one at a time. Ruby has several collection classes, and even more classes that are sufficiently collection-like to support an `each` method. You'll see two chapters devoted to Ruby collections. Here we'll recruit the humble array for our examples.

Here's a simple `each` operation:

```ruby
array = [1,2,3,4,5]
array.each {|e| puts "The block just got handed #{e}." }
```
The ouput of the `each` call looks like this in an irb session:
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
We've successfully implemented at least a simple version of `each`. The nice thing about `each` is that it's so vanilla: all it does is toss values at the code block, one at a time, until it runs out. One important implication of this is that it's possible to build any number of more complext, semantically rich iterators *on top of* `each`. We'll finish this reimplementation exercise with one such method: `map`, which we saw briefly in an earlier section. Learning a bit about `map` will also take us into some further nuances of code block writing and usage. 
