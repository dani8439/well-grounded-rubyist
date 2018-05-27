# *Ranges* #
A *range* is an object with a start point and an end point. The semantics of range operations involve two major concepts:

• *Inclusion*-Does a given value fall inside the range?

• *Enumeration*-The range is treated as a traversable collection of individual items.

The logic of inclusion applies to all ranges; you can always test for inclusion. The logic of enumeration kicks in only with certain ranges-namely, those that include a finite number of discrete, identifiable values. You can't iterate over a range that lies between two floating-point numbers, because the range encompasses an infinite number of values. But you can iterate over a range between two integers.

### *Creating a range* ###
You can create range objects with `Range.new`. If you do so in irb, you're rewarded with a view of the syntax for literal range construction:

```irb
>> r = Range.new(1,100)
=> 1..100
```

The literal syntax can, of course, also be used directly to create a range:

```irb
>> r = 1..100
=> 1..100
```
When you see a range with two dots between the start-point and end-point values, as in the previous example, you're seeing an *inclusive* range. A range with three dots in the middle is an *exclusive* range:

```irb
>> r = 1...100
=> 1...100
```
The difference lies in whether the end point is considered to lie inside the range. Coming full circle, you can also specify inclusion or exclusive behavior when you create a range with `Range.new`: the default is an inclusive range, but you can force an exclusive range by passing a third argument of `true` to the constructor:

```irb
>> Range.new(1,100)
=> 1..100
>> Range.new(1,100,true)
=> 1...100
```
Unfortunately, there's no way to remember which behavior is the default and which is triggered by the `true` argument, except to memorize it.

Also notoriously hard to remember is which number of dots goes with which type of range.

#### REMEMBERING .. VS ... ####
If you follow Ruby discussion forums, you'll periodically see messages and posts from people who find it difficult to remember which is which: two versus three dots, inclusive verses exclusive range.

One way to remember is think of a range as always reaching to the point represented by whatever follows the second dot. In an inclusive range, the point after the second dot is the end value of the range. In this example, the value `100` included in the range:

`1..100`

But in this exclusive range, the value `100` lies beyond the effective end of the range:

`1...100`

In other words, you can think of `100` as having been "pushed" to the right in such a way that it now sits outside the range.

We'll turn now to range-inclusion logic-a section that closely corresponds to the "query" sections from the discussions of strings, arrays, and hashes, because most of what you do with ranges involves querying them on criteria of inclusion.

### *Range-inclusion logic* ###
Ranges have `begin` and `end` methods, which report back their starting and ending points:

```irb
>> r = 1..10
=> 1..10
>> r.begin
=> 1
>> r.end
=> 10
```

A range also knows whether it's an exclusive (three-dot) range:

```irb
>> r.exclude_end?
=> false
```
With the goal posts in place, you can start to test for inclusion.

Two methods are available for testing inclusion of a value in a range: `cover?` and `include?` (which is also aliased as `member?`)

#### TESTING RANGE INCLUSION WITH COVER? ####
The `cover?` method performs a simple test: if the argument to the method is greater than the range's start point and less than its end point (or equal to it, for an inclusive range), then the range is said to *cover* the object. The tests are performed using Boolean comparison tests, with a false result in cases where the comparison makes no sense.

All of the following comparisons make sense; one of them fails because the item isn't in the range:

```irb
>> r = "a".."z"
=> "a".."z"
>> r.cover?("a")      #<--- true: "a" >= "a" & "a" <= "z"
=> true
>> r.cover?("abc")    #<--- true: "abc" >= "a" & "abc" <= "z"
=> true
>> r.cover?("A")      #<--- false: "A" < "a"
=> false
```
But this next test fails because the item being tested for inclusion isn't comparable with the range's start and end points:

```irb
>> r.cover?([])
=> false
```
It's meaningless to ask whether an array is greater than the string `"a"`. If you try such a comparison on its own, you'll get a fatal error. Fortunately, ranges take a more conservative approach and tell you that the item isn't covered by the range.

Whereas `cover?` performs start- and end-point comparisons, the other inclusion test `include?` (or `member?`), takes a more collection-based approach.

#### TESTING RANGE INCLUSION WITH INCLUDE? ####
The `include?` test treats the range as a kind of crypto-array-that is, a collection of values. The `"a..z"` range, for example, is considered to include (as measured by `include?`) only the 26 values that lie inclusively between `"a"` and `"z"`.

Therefore, `include?` produces results that differ from those of `cover?`:

```irb
>> r. include?("a")
=> true
>> r.include?("abc")
=> false
```
In cases where the range can't be interpreted as a finite collection, such as a range of floats, the `include?` method falls back on numerical order and comparison:

```irb
>> r = 1.0..2.0
=> 1.0..2.0
>> r.include?(1.5)
=> true
```

#### **Are there backward ranges?** ####
The anticlimactic answer to the question of backward ranges is this: yes and no. You can create a backward range, but it won't do what you probably want it to:

```irb
>> r = 100...1
=> 100...1
>> r.include?(50)
=> false
```
The range happily performs its usual inclusion test for you. The test calculates whether the candidate for inclusion is greater than the start point of the range and less than the end point. Because 50 is neither greater than 100 nor less than 1, the test fails. And it fails silently; this is a logic error, not a fatal syntax or runtime error.

Backward ranges do show up in one particular set of use cases: as index arguments to strings and arrays. They typically take the form of a positive start point and a negative end point, with the negatic end point counting in from the right:

```irb
>> "This is a sample string"[10..-5]
=> "sample st"
>> ['a', 'b', 'c', 'd'][0..-2]
=> ["a", "b", "c"]
```
You can even use an exclusive backward range:

```irb
>> ['a', 'b', 'c', 'd'][0...-2]
=> ["a", "b"]
```
In these cases, what doesn't work (at least, in the way you might have expected) in a range on its own does work when applied to a string or an array.

Last basic collection class to examine, the `Set` class, as we'll see more about ranges as quasi-collections in the next chapter.

# *Sets* #
`Set` is the one class under discussion in this chapter that isn't, strictly speaking, a RUby core class. It's a standard library class, which means that to use it, you have to do this: 

`require 'set'`

The general rule in this book is that we're looking at the core language rather than the standard library, but the `Set` class makes a worthy exception because it fits in so nicely with the other container and collection classes we've looked at.

A `set` is a unique collection of objects. The objects can be anything-strings, integers, arrays, other sets-but no object can occur more than once in the set. Uniqueness is also also enforced at the commonsense content level: if the set contains the string `"New York"`, you can't add the string `"New York"` to it, even though the two strings may technically be different objects. The same is true of arrays with equivalent content. 

**NOTE** Internally, sets use a hash to enforce the uniqueness of their contents. When an element is added to a set, the internal hash for that set gets a new key. Therefore, any two objects that would count as duplicates if used as hash keys can't occur together in a set. 

### *Set creation* ### 
To create a set, you use the `Set.new` constructor. You can create an empty set, or you can pass in a collection object (defined as an object that responds to `each` or `each_entry`). In the latter case, all the elements of the collection are placed individually in the set: 

```irb 
>> new_england = ["Connecticut", "Maine", "Massachusetts", "New Hampshire", "Rhode Island", "Vermont"]
 => ["Connecticut", "Maine", "Massachusetts", "New Hampshire", "Rhode Island", "Vermont"]
>> state_set = Set.new(new_england)
 => #<Set: {"Connecticut", "Maine", "Massachusetts", "New Hampshire", "Rhode Island", "Vermont"}>
```
Here we've created an array, `new_england`, and used it as the constructor argument for the creation of the `state_set` set. Note that there's no literal set constructor (no equivalent to `[]` for arrayys or `{}` for hashes). There can't be: sets are part of the standard library, not the core, and the core syntax of the language is already in place before the set library gets loaded. 

You can also provide a code block to the constructor, in which case every item in the collection object you supply is passed through the block (yielded to it) with the resulting value being inserted intot he set. For example, here's a way to initialize a set to a list of uppercased strings:

```irb 
>> names = ["David", "Yukihiro", "Chad", "Amy"]
=> ["David", "Yukihiro", "Chad", "Amy"]
>> name_set = Set.new(names){|name| name.upcase}
=> #<Set: {"DAVID", "YUKIHIRO", "CHAD", "AMY"}>
```
Rather than using the array of names as its initial values, the set constructor yields each name to the block and inserts what it gets back (an uppercase version of the string) into the set. 

Now that we've got a set, we can manipulate it. 

### *Manipulating set elements* ### 
Like arrays, sets have two modes of adding elements: either inserting a new element into the set or drawing on another collection object as a source for multiple new elements. In the array world, this is the difference between `<<` and `concat`. For sets, the distinction is reflected in a variety of methods, which we'll look at here. 
