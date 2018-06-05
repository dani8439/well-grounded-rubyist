## *Element-wise enumerable operations* ##
Collections are born to be traversed, but they also contain special-status individual objects: the first or last in the collection, and the greatest (largest) or least (smallest). `Enumerable` objects come with several tools for element handling along these lines.

### *The first method* ###
`Enumerable#first`, as the name suggests, returns the first item encountered when iterating over the enumerable:

```irb
>> [1,2,3,4].first
=> 1
>> (1..10).first
=> 1
>> {1=>2, "one"=>"two"}.first
=> [1, 2]
```

The object returned by `first` is the same as the first object you get when you iterate through the parent object. In other words, it's the first thing yielded by `each`. In keeping with the fact that hashes yield key/value pairs in two-element arrays, taking the first element of a hash gives you a two-element array containing the first pair that was inserted into the hash (or the first key inserted and its new value, if you've changed that value at any point):

```irb
>> hash = { 3 => "three", 1 => "one", 2 => "two" }
=> {3=>"three", 1=>"one", 2=>"two"}
>> hash.first                     #<-----first means first inserted
=> [3, "three"]
>> hash[3] = "trois"
=> "trois"
>> hash.first             #<----- New value doesn't change insertion order
=> [3, "trois"]
```
Perhaps the most noteworthy point about `Enumerable#first` is that there's no `Enumerable#last`. THat's because finding the end of the iteration isn't as straightforward as finding the beginning. Consider a case where the iteration goes on forever. Here's a little `Die` class (die as in the singular of dice). It iterates by rolling the die forever and yielding the result each time:

```ruby
class Die
  include Enumerable
  def each
    loop do
      yield rand(6) + 1
    end
  end
end
```
The loop uses the method `Kernel#rand`. Called with no argument, this method generates a random floating-point number *n* such that *0 <= n < i*. Thus `rand(6)` produces an integer in the range (0..5). Adding one to that number gives a number between 1 and 6, which corresponds to what you get when you roll a die.

But the main point is that `Die#each` goes on forever. If you're using the `Die` class, you have to make provisions to break out of the loop. Here's a little game where you win as soon as the die turns up 6:

```ruby
puts "Welcome to 'You Win if you roll a 6!'"
d = Die.new
d.each do |roll|
  puts "You rolled a #{roll}."
  if roll == 6
    puts "You win!"
    break
  end
end
```
A typical run might look like this:

```irb
Welcome to 'You Win if you roll a 6!'
You rolled a 4.
You rolled a 3.
You rolled a 3.
You rolled a 2.
You rolled a 2.
You rolled a 5.
You rolled a 1.
You rolled a 2.
You rolled a 2.
You rolled a 1.
You rolled a 5.
You rolled a 6.
You win!
```
The triviality of game aside, the point is that it would be meaningless to call `last` on your die object, because there's no last roll of the die. Unlike taking the first element, taking the last element of an enumerable has no generalizable meaning.

For the same reason-the unreachability of the end of the enumeration-an enumerable class with an infinite yielding `each` method can't do much with methods like `select` and `map`, which don't return their results until the underlying iteration is complete. Occasions for finite iteration are, in any event, few; but observing the behaviors and impact of an endless `each` can be instructive for what it reveals about the more common, finite case.

Keep in mind, though, that some enumerable classes do have a `last` method: notably `Array` and `Range`. Moreover, all enumerables have a `take` method, a kind of generalization of `first`, and a companion method called `drop`.

### *The take and drop methods* ###
Enumerables know how to "take" a certain number of elements from the beginning of themselves and conversely how to "drop" a certain number of elements. The `take` and `drop` operations basically do the same thing-they divide the collection at a specific point-but they differ in what they return:

```irb
>> states = %w{ NJ NY CT MA VT FL }
=> ["NJ", "NY", "CT", "MA", "VT", "FL"]
>> states.take(2)                 #<------ Grabs first two elements
=> ["NJ", "NY"]
>> states.drop(2)                 #<------ Grabs collection except first two elements
=> ["CT", "MA", "VT", "FL"]
```

When you take elements, you get those elements. When you drop elements, you get the original collection minus the elements you've dropped. You can constrain the `take` and `drop` operations by providing a block and using the variant forms `take_while` and `drop_while`, which determines the size of the "take" not by an integer argument but by the truth value of the block:

```irb
>> states.take_while {|s| /N/.match(s) }
=> ["NJ", "NY"]
>> states.drop_while {|s| /N/.match(s) }
=> ["CT", "MA", "VT", "FL"]
```
The `take` and `drop` operations are a kind of hybrid of `first` and `select`. They're anchored to the beginning of the iteration and terminate once they've satisfied the quantity requirement or encountered a block failure.

You can also determine the minimum and maximum values in an enumerable collection.

### *The min and max methods* ###
The `mind` and `max` methods do what they sound like they'll do:

```irb
>> [1,3,5,4,2].max
=> 5
>> %w{ Ruby C APL Perl Smalltalk }.min
=> "APL"
```
Minimum and maximum are determined by the `<=>` (spaceship comparison operator) logic, which for the array of strings puts `"APL"` first in ascending order. If you want to perform a minimum or maximum test based on nondefault criteria, you can provide a code block:

```irb
>> %w{ Ruby C APL Perl Smalltalk }.min {|a,b| a.size <=> b.size }
=> "C"
```
A more streamlined block-based approach, though, is to use `min_by` or `max_by`, which perform the comparison implicitly:

```irb
>> %w{ Ruby C APL Perl Smalltalk }.min_by {|lang| lang.size }  
=> "C                            #<--- No need to compare two parameters explicitly in code bock
```

There's also a `minmax` method (and the corresponding `minmax_by` method), which gives you a pair of values, one for the minimum and one for the maximum:

```irb
> %w{ Ruby C APL Perl Smalltalk }.minmax
=> ["APL", "Smalltalk"]
>> %w{ Ruby C APL Perl Smalltalk }.minmax_by {|lang| lang.size }
=> ["C", "Smalltalk"]
```

Keep in mind that the `min/max` family of enumerable methods is always available, even when using it isn't a good idea. You wouldn't want to do this, for example:

```ruby
die = Die.new
puts die.max
```
The infinite loop with which `Die#each` is implemented won't allow a maximum value ever to be determined. Your program will hang.

In the case of hashes, `min` and `max` use the keys to determine ordering. If you want to use values, the `*_by` members of the `min/max` family can help you:

```irb
>> state_hash = => { "New York" => "NY", "Maine" => "ME", "Alaska" => "AK", "Alabama" => "AL" }
=> {"New York"=>"NY", "Maine"=>"ME", "Alaska"=>"AK", "Alabama"=>"AL"}
>> state_hash.min                   #<--- Minimum pair, by key
=> ["Alabama", "AL"]
>> state_hash.min_by {|name, abbr| name }     #<--- Same as min
=> ["Alabama", "AL"]
>> state_hash.min_by {|name, abbr| abbr }       #<--- Minimum pair, by value
=> ["Alaska", "AK"]
```
And of course you can, if you wish, perform calculations inside the block that involve both the key and the value.

At this point, we've looked at examples of `each` methods and how they link up to a number of methods that are built on top of them. It's time now to look at some methods that are similar to `each` but a little more specialized. The most important of these is `map`. In fact, `map` is important enough that we'll look at it separately in its own section. First, let's discuss some other `each` relatives.

## *Relatives of each* ##
`Enumerable` makes several methods available to you that are similar to `each`, in that they go through the whole collection and yield elements from it, not stopping until they've gone all the way through (and in one case, not even then!). Each member of this family of methods has its own particular semantics and niche. The methods include `reverse_each`, `each_with_index`, `each_slice`, `each_cons`, `cycle`, and `inject`.

### *reverse_each* ###
The `reverse_each` method does what it sounds like it will do: it iterates backwards through an enumerable. For example, the code:

`[1,2,3].reverse_each { |e| puts e * 10 }`

produces this output:

```irb
30
20
10
 => [1, 2, 3]
```
You have to be careful with `reverse_each`: don't use it on an infinite iterator, since the concept of going in reverse depends on the concept of knowing what the last element is-which is a meaningless concept in the case of an infinite iterator. Try calling `reverse_each` on an instance of the `Die` class shown earlier-but be ready to hit Ctrl-c to get out of the infinite loop.

## *The each_with_index method (and each.with_index)* ##
`Enumerable#each_with_index` differs from `each` in that it yields an extra item each time through the collection: namely, an integer representing the ordinal position of the item. This index can be useful for labeling objects, among other purposes:

```irb
>> names = ["George Washington", "John Adams", "Thomas Jefferson", "James Madison"]
=> ["George Washington", "John Adams", "Thomas Jefferson", "James Madison"]
>> names.each_with_index do |pres, i|
>> puts "#{i + 1}. #{pres}"        #<--- Adds 1 to avoid 0th list entry
>> end
1. George Washington
2. John Adams
3. Thomas Jefferson
4. James Madison
=> ["George Washington", "John Adams", "Thomas Jefferson", "James Madison"]
```
An anomaly is involved in `each_with_index`: every enumerable object has it, but not every enumerable object has knowledge of what an index is. You can see this by asking enumerables to perform an `each_index` (as opposed to `each_with_index`) operation. The results vary from one enumerable to another:

```irb
>> %w{a b c }.each_index {|i| puts i }
0
1
2
=> ["a", "b", "c"]
```

Arrays, then, have a fundamental sense of an index. Hashes don't - although they do have a sense of `with` index:

```irb
=> ["a", "b", "c"]
>> letters = {"a" => "ay", "b" => "bee", "c" => "see" }
=> {"a"=>"ay", "b"=>"bee", "c"=>"see"}
>> letters.each_with_index {|(key, value), i| puts i }
0
1
2
=> {"a"=>"ay", "b"=>"bee", "c"=>"see"}
>> letters.each_index {|(key,value), i| puts i }
NoMethodError: undefined method `each_index' for {"a"=>"ay", "b"=>"bee", "c"=>"see"}:Hash
Did you mean?  each_with_index
```
We could posit that a hash's keys are its indexes and that the ordinal numbers generated by the `each_with_index` iteration are extra or meta-indexes. It's an interesting theoretical question; but in practice it doesn't end up mattering much, because it's extremely unusual to need to perform an `each_with_index` operation on a hash.

`Enumerable#each_with_index` works, but it's somewhat deprecated. Instead, consider using the `#with_index` method of the enumerator you get back from calling `each`. You've already seen this technique in chapter 9:

```irb
>> array = %w{red yellow blue }
=> ["red", "yellow", "blue"]
>> array.each.with_index do |color, i|
?> puts "Color number: #{i} is #{color}."
>> end
Color number: 0 is red.
Color number: 1 is yellow.
Color number: 2 is blue.
=> ["red", "yellow", "blue"]
```

It's as simple as changing an underscore to a period ... though there's a little to it under the hood, as you'll see when you learn more about enumerators a little later. Using `each_index` also buys you some functionality: you can provide an argument that will be used as the first index value, thus avoiding the need to add one to the index in a case like the previous list of presidents:

```irb
>> names.each.with_index(1) do |pres, i|
?> puts "#{i} #{pres}"
>> end
1 George Washington
2 John Adams
3 Thomas Jefferson
4 James Madison
=> ["George Washington", "John Adams", "Thomas Jefferson", "James Madison"]
```

Another subfamily of `each` relatives is the pair of methods `each_slice` and `each_cons`.

### *The each_slice and each_cons methods* ###
The `each_slice` and `each_cons` methods are specializations of `each` that walk through a collection a certain number of elements at a time, yielding an array of that many elements to the block on each iteration. The difference between them is that `each_slice` handles each element only once, whereas `each_cons` takes a new grouping at each element and thus produces overlapping yielded arrays.

Here's an illustration of the difference:

```irb
>> array = [1,2,3,4,5,6,7,8,9,10]
=> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
>> array.each_slice(3) {|slice| p slice }
[1, 2, 3]
[4, 5, 6]
[7, 8, 9]
[10]
=> nil
>> array.each_cons(3) {|cons| p cons }
[1, 2, 3]
[2, 3, 4]
[3, 4, 5]
[4, 5, 6]
[5, 6, 7]
[6, 7, 8]
[7, 8, 9]
[8, 9, 10]
=> nil
```
The `each_slice` operation yields the collection progressively in slices of size *n* (or less than *n*, if fewer than *n* elements remain). By contrast, `each_cons` moves through the collection one element at a time and at each point yields an array of *n* elements, stopping when the last element in the collection has been yielding once.

Yet another generic way to iterate through an enumerable is with the `cycle` method.

### *The cycle method* ###
`Enumerable#cycle` yields all the elements in the object again and again in a loop. If you provide an integer argument, the loop will be run that many times. If you don't, it will run infinitely.

You can use `cycle` to decide dynamically how many times you want to iterate through a collection-essentially, how many `each`-like runs you want to perform consecutively. Here's an example involving a deck of playing cards:

```ruby
class PlayingCard
  SUITS = %w{ clubs diamonds hearts spades }      #<---1.
  RANKS = %w{ 2 3 4 5 6 7 8 9 10 J Q K A }
  class Deck
    attr_reader :cards                  #<---2.    
    #3.
    def initialize(n=1)               
      @cards = []
      SUITS.cycle(n) do |s|            #<---4.
        RANKS.cycle(1) do |r|             #<---5.
          @cards << "#{r} of #{s}"            #<---6.
        end
      end
    end
  end
end
```
The class `PlayingCard` defines constants representing suits and ranks(#1), whereas the `PlayingCard::Deck` class models the deck. The cards are stored in an array in the deck's `@cards` instance variable, available also as a reader attribute(#2). Thanks to `cycle`, it's easy to arrange for the possibility of combining two or more decks. `Deck.new` takes an argument, defaulting to 1 (#3). If you override the default, the process by which the `@cards` array is populated is augmented.

For example, this command produces a double deck of cards containing two of each car for a total of 104:

`deck = PlayingCard::Deck.new(2)`

That's because the method cycles through the suits twice, cycling through the ranks once per suit iteration (#4). The ranks cycle is always done only once (#5); `cycle(1)` is, in effect, another way of saying `each`. For each permutation, a new card, represented by a descriptive string, is inserted into the deck (#6).

Last on the `each`-family method tour is `inject`, also known as reduce.

### *Enumerable reduction with inject* ###
The `inject` method, (a.k.a. `reduce` and similar to "fold" methods in functional languages) works by initializing an accumulator object and then iterating through a collection (an enumerable object), performing a calculation on each iteration and resetting the accumulator, for purposes of the next iteration, to the result of that calculation.

The class example of injecting is the summing up of numbers in an array. Here's how to do it:

```irb
>> [1,2,3,4].inject(0) {|acc,n| acc + n }
=> 10
```
And here's how it works:

  ```irb 
>> [1,2,3,4].inject do |acc,n|
>>  puts "adding #{acc} and #{n}...#{acc+n}"
>>  acc + n
>> end
adding 1 and 2...3
adding 3 and 3...6
adding 6 and 4...10
=> 10
```
The `puts` statement is a pure side effect (and, on its own, evaluates to `nil`), so you still have to end the block with `acc + n` to make sure the block evaluates to the correct value.

We've saved perhaps the most important relative of `each` for last: `Enumerable#map`.1. The accumulator is initialized to 0, courtesy of the 0 argument to `inject`.
  ```irb 
>> [1,2,3,4].inject do |acc,n|
>>  puts "adding #{acc} and #{n}...#{acc+n}"
>>  acc + n
>> end
adding 1 and 2...3
adding 3 and 3...6
adding 6 and 4...10
=> 10
```
The `puts` statement is a pure side effect (and, on its own, evaluates to `nil`), so you still have to end the block with `acc + n` to make sure the block evaluates to the correct value.

We've saved perhaps the most important relative of `each` for last: `Enumerable#map`.2. The first time through the iteration-the code block-`acc` is 0, and `n` is set to 1 (the first item in the array). The result of the calculation inside the block is 0 + 1, or 1.
  ```irb 
>> [1,2,3,4].inject do |acc,n|
>>  puts "adding #{acc} and #{n}...#{acc+n}"
>>  acc + n
>> end
adding 1 and 2...3
adding 3 and 3...6
adding 6 and 4...10
=> 10
```
The `puts` statement is a pure side effect (and, on its own, evaluates to `nil`), so you still have to end the block with `acc + n` to make sure the block evaluates to the correct value.

We've saved perhaps the most important relative of `each` for last: `Enumerable#map`.3. The second time through, `acc` is set to 1 (the block's result from the previous time through), and `n` is set to 2 (the second element in the array). The block therefore evaluates to 3.
  ```irb 
>> [1,2,3,4].inject do |acc,n|
>>  puts "adding #{acc} and #{n}...#{acc+n}"
>>  acc + n
>> end
adding 1 and 2...3
adding 3 and 3...6
adding 6 and 4...10
=> 10
```
The `puts` statement is a pure side effect (and, on its own, evaluates to `nil`), so you still have to end the block with `acc + n` to make sure the block evaluates to the correct value.

We've saved perhaps the most important relative of `each` for last: `Enumerable#map`.4. The third time through, `acc` and `n` are 3 (previous block result) and 3 (next value in the array.) The block evaluates to 6.
  ```irb 
>> [1,2,3,4].inject do |acc,n|
>>  puts "adding #{acc} and #{n}...#{acc+n}"
>>  acc + n
>> end
adding 1 and 2...3
adding 3 and 3...6
adding 6 and 4...10
=> 10
```
The `puts` statement is a pure side effect (and, on its own, evaluates to `nil`), so you still have to end the block with `acc + n` to make sure the block evaluates to the correct value.

We've saved perhaps the most important relative of `each` for last: `Enumerable#map`.5. The fourth time through, `acc` and `n` are 6 and 4. The block evaluates to 10. Because this is the last time through, the value from the block serves as the return value of the entire call to `inject`. Thus the entire call evaluates to 10, as shown by irb.

If you don't supply an argument to `inject`, it uses the first element in the enumerable object as the initial value for `acc`. In this example, that would produce the same result, because the first iteration added 0 to 1 and set `acc` to 1 anyway.

Here's a souped-up example, with some commentary printed out on each iteration so that you can see what's happening:
