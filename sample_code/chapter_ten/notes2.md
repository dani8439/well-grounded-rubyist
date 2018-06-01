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
