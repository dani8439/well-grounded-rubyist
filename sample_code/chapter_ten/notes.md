# *Collections central: Enumerable and Enumerator* # 
All collection objects aren't created equal-but an awful lot of them have many characteristics in common. In Ruby, common characteristics among many objects tend to reside in modules. Collections are no exception: collection objects in Ruby typically include the `Enumerable` module.

Classes that use `Enumerable` enter into a kind of contract: the class has to define an instance method called `each`, and in return, `Enumerable` endows the objects of the class with all sorts of collection-related behaviors. The methods behind these behaviors are defined in terms of `each`. In some respects, you might say the whole concept of a "collection" in Ruby is pegged to the `Enumerable` module and the methods it defines on top of `each`. 

Keep in mind that although every major collection class partakes of the `Enumerable` module, each of them has its own methods too. The methods of an array aren't identical to those of a set; those of a range aren't identical to those of a hash. And sometimes, collection classes share method names but the methods don't do exactly the same thing. They *can't* always do the same thing; the whole point is to have multiple collection classes but to extract as much common behavior as possible into a common module.

You can mix `Enumerable` into your own classes:

```ruby 
class C 
  include Enumerable
end
```
By itself, that doesn't do much. To tap into the benefits of `Enumerable`, you must define an `each` instance method in your class: 

```ruby 
class C 
  include Enumerable 
  def each 
    # relevant code here
  end
end
```

At this point, objects of class `C` will have the ability to call any instance method defined in `Enumerable`. 

In addition to the `Enumerable` module, in this chapter we'll look at a closely related class called `Enumerator`. *Enumerators* are objects that encapsulate knowledge of how to iterate through a particular collection. By packaging iteration intelligence in an object that's separate from the collection itself, enumerators add a further and powerful dimension to Ruby's already considerable collection-manipulation facilities.

## *Gaining enumerability through each* ## 
Any class that aspires to be enumerable must have an `each` method whose job is to yield items to a supplied code block, one at a time. 

Exactly what `each` does will vary from one class to another. In the case of an array, `each` yields the first element, then the second, and so forth. In the case of a hash, it yields key/value pairs in the form of two-element arrays. In the case of a file handle, it yields one line of the file at a time. Ranges iterate by first deciding whether iterating is possible (which it isn't for example, if the start point is a float) and then pretending to be an array. And if you define an `each` class of your own, it can mean whatever you want it to mean-as long as it yields something. So `each` has different semantics for different classes. But however `each` is implemented, the methods in the `Enumerable` module depend on being able to call it. 

You can get a good sense of hoe `Enumerable` works by writing a small, proof-of-concept class that uses it. The following listing shows such a class: `Rainbow`. This class has an `each` method that yields one color at a time. Because the class mixes in `Enumerable`, its instances are automatically endowed with the instance methods defined in that module. 

```ruby 
class Rainbow
  include Enumerable
  def each
    yield "red"
    yield "orange"
    yield "yellow"
    yield "green"
    yield "blue"
    yield "indigo"
    yield "violet"
  end
end

r = Rainbow.new
r.each do |color|
  puts "Next color: #{color}"
end
```
The output of this simple iteration is as follows: 

```irb 
Next color: red
Next color: orange
Next color: yellow
Next color: green
Next color: blue
Next color: indigo
Next color: violet
```

But that's just hte beginning. Because `Rainbow` mixed in the `Enumerable` module, rainbows are automatically endowed with a whole slew of methods built on top of the `each` method. 

Here's an example: `find`, which returns the first element in an enumerable object for which the code block provided returns true. Let's say we want to find the first color that begins with the letter y. We can do it with `fine` like this: 

```ruby 
r = Rainbow.new
y_color = r.find {|color| color.start_with?('y')}
puts "First color starting with 'y' is #{y_color}"

# First color starting with 'y' is yellow
```
`find` works by calling `each`. `each` yields items, and `find` uses the code block we've given it to test those items one at a time for a match. When `each` gets around to yielding `yellow`, `find` runs it through the block and it passes the test. The variable `y_color` therefore receives the value `yellow`. Notice that there's no need to define `find`. It's part of `Enumerable` which we've mixed in. It knows what to do and how to use `each` to do it. 

Defining `each` together with mixing in `Enumerable` buys you a great deal of functionality for your objects. Much of the searching and querying functionality you see in Ruby arrays, hashes, and other collection objects comes directly from `Enumerable`. If you want to know which methods `Enumerable` provides, ask it:

```irb 
>> Enumerable.instance_methods(false).sort
=> [:all?, :any?, :chunk, :chunk_while, :collect, :collect_concat, :count, :cycle, :detect, :drop, :drop_while, :each_co
ns, :each_entry, :each_slice, :each_with_index, :each_with_object, :entries, :find, :find_all, :find_index, :first, :fla
t_map, :grep, :grep_v, :group_by, :include?, :inject, :lazy, :map, :max, :max_by, :member?, :min, :min_by, :minmax, :min
max_by, :none?, :one?, :partition, :reduce, :reject, :reverse_each, :select, :slice_after, :slice_before, :slice_when, :
sort, :sort_by, :take, :take_while, :to_a, :to_h, :zip]
```
Thanks to the `false` argument, the list includes only the methods defined in the `Enumerable` module itself. Each of these methods is built on top of `each`. 

Some of the methods in Ruby's enumerable classes are actually overwritten in those classes. For example, you'll find implementations of `map`, `select`, `sort`, and other `Enumerable` instance methods in the source-code file array.c; the Array class doesn't simply provide an `each` method and mix in `Enumerable` (though it does do that, and it gains behaviors that way). These ovewrites are done either because a given class requires special behavior in the face of a given `Enumerable` method, or for the sake of efficiency. We're not going to scrutinize all the overwrites. The main point here is to explore the ways in which all of the collection classes share behaviors and interface. 

In what follows, we'll look at several categories of methods from `Enumerable`. We'll start with some Boolean methods. 

## *Enumerable Boolean queries* ## 
A number of `Enumerable` methods return true or false depending on whether one or more element matches certain criteria. Given an array `states`, containing the names of all the states in the United States of America, here's how you might perform some of these Boolean queries: 

```irb 
states = ["Alaska", "Alabama", "Arkansas", "American Samoa", "Arizona", "California", "Colorado", "Connecticut", "District of
Columbia", "Delaware", "Florida", "Georgia", "Guam", "Hawaii", "Iowa", "Idaho", "Illinois", "Indiana", "Kansas", "Kentuc
ky", "Louisiana", "Massachusetts", "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", "Mississippi", "Montana", "
North Carolina", " North Dakota", "Nebraska", "New Hampshire", "New Jersey", "New Mexico", "Nevada", "New York", "Ohio",
 "Oklahoma", "Oregon", "Pennsylvania", "Puerto Rico", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Te
xas", "Utah", "Virginia", "Virgin Islands", "Vermont", "Washington", "Wisconsin", "West Virginia", "Wyoming"]

# Does the array include Louisiana? 
>> states.include?("Louisiana")
=> true
# Do all states include a space? 
>> states.all? {|state| state =~/ /}
=> false
# Does *any* state include a space? 
>> states.any? {|state| state =~/ /}
=> true
# Is there one, and only one, state with "West" in its name?
>> states.one? {|state| state =~ /West/}
=> true
# Are there no states with "East" in their names?
>> states.none? {|state| state =~ /East/ }
=> true
```
If `states` were, instead, a hash with state names as keys and abbreviations as values, you could run similar tests, although you'd need to adjust for the fact that `Hash#each` yields both a key and a value each time through. The `Hash#include?` method checks for key inclusion, as we saw in Chapter 9, but the other methods in the previous example handle key/value pairs: 

```irb 
# Does the hash include Louisiana? 
>> states.include?("Lousiana")            #<---include? consults hash's keys
=> true 
>> states.all? {|state, abbr| state =~ / / }     #<----Hash yields key/value pairs to the block
=> false
# Is there one, and only one, state with "West" in its name? 
>> states.one? {|state, abbr| state =~ /West/ }
=> true
```
In all of these cases, you could grab an array via `states.keys` and perform the tests on that array directly:

```irb 
# Do all states include a space? 
>> states.keys.all? {|state, abbr| state =~ / / }
=> false
```
Generating the entire `keys` array in advance, rather than walking through the hash that's already there, is slightly wasteful of memory. Still the new array contains the key objects that already exist, so it only "wastes" the memory devoted to wrapping the keys in an array. The memory taken up by the keys themselves doesn't increase. 

**Hashes iterate with two-element arrays** 
When you iterate through a hash with `each` or any other built-in iterator, the hash is yielded to your code block one key/value pair at a time-and the pairs are two-element arrays. You can, if you wish, provide just one block parameter and capture the whole little array:

`hash.each {|pair| ... }`

In such a case, you'll find the key at `pair[0]` and the value at `pair[1]`. Normally, it makes more sense to grab the key and value in separate block parameters. But all that's happening is that the two are wrapped up in a two-element array, and that array is yielded. If you want to operate on the data in that form, you may.

-----
What about sets and ranges? Set iteration works much like array iteration for Boolean query (and most other) purposes: if `states` were a set, you could run exactly the same queries as the ones in the example with the same results. With ranges, enumerability gets a little trickier.

It's more meaningful to view some ranges as enumerable-as collections of items that you can step through-than others. The `include?` method works for any range. But the other Boolean `enumerable` methods force the enumerability issue: if the range can be expressed as a list of discrete elements, then those methods work; but if it can't, as with a range of floats, then calling any of the methods triggers a fatal error: 

```irb 
>> r = Range.new(1, 10)
=> 1..10
>> r.one? {|n| n == 5 }        #<----1.
=> true
>> r.none? {|n| n % 2 == 0 }   #<----1.
=> false
>> r = Range.new(1.0, 10.0)    #<----2.
=> 1.0..10.0
>> r.one? {|n| n == 5 }
TypeError: can't iterate from Float      #<----3.
>> r = Range.new(1, 10.3)
=> 1..10.3                               #<----4.
>> r.any? {|n| n > 5 }
=> true
```
Given a range spanning two integers, you can run tests like `one?` and `none?` (#1) because the range can easily slip into behaving like a collection: in effect, the range `1..10` adopts the API of the corresponding array, `[1,2,3,4,5,6,7,8,9,10]`.

But a range between two floats (#2) can't behave like a finite collection of discrete values. It's meaningless to produce "each" float inside a range. The range has the `each` method, but the method is written in such a way as to refuse to iterate over floats (#3), (The fact that the error is `TypeError` rather than `NoMethodError` indicates that the `each` method exists but can't function on this range.) 

You can use a float as a range's end point and still get enumeration, as long as the starting point is an integer (#4). When you call `each` (or one of the methods built on top of `each`), the range behaves like a collection of integers starting at the start point and ending at the end point rounded down to the nearest integer. That integer is considered to be included in the range, whether the range is inclusive or exclusive (because, after all, the official end point is a float that's higher than the integer below it).

In addition to answering various true/false questions about their contents, enumerable objects excel at performing search and select operations. We'll turn to those now.

## *Enumerable searching and selecting* ## 
It's commong to want ot filter a collection of objects based on one or more selection criteria. For example, if you have a database of people registering for a conference, and you want to sent payment reminders to the people who haven't paid, you can filter a complete list based on payment status. Or you might need to narrow a list of numbers to only the even ones. And so forth; the use cases for selecting elements from enumerable objects are unlimited.

The `Enumerable` module provides several facilities for filtering collections and for searching collections to find one or more elements that match one or more criteria. We'll look at several filtering and searching methods here. All of them are iterators: they all expect you to provide a code block. The code block is the selection filter. You define your selection criteria (your tests for inclusion or exclusion) inside the block. The return value of the entire method may, depending on which method you're using and on what it finds, be one object, an array (possible empty) of objects matching your criteria, or `nil`, indicating that hte criteria weren't met.

We'll start with a one-object search using `find` and then work our way through several techniques for deriving a multiple-object result set from an enumerable query. 

### *Getting the first match with find* ###
`find` (also available as the synonymous `detect`) locates the first element in an arary for which the code bloack, when called with that element as an argument, returns true. For example, to find the first number greater than 5 in an array of integers, you can use `find` like this:

```irb 
>> [1,2,3,4,5,6,7,8,9,10].find {|n| n > 5 }
=> 6
```
`find` iterates through the array, yielding each element in turn to the block. If the block returns anything with the Boolean value of true, the element yielded "wins," and `find` stops iterating. If `find` fails to find an element that passes the code-block test, it returns `nil`. (Try changing `n > 5` to `n > 100` in the example, and you'll see.):

```irb
>> [1,2,3,4,5,6,7,8,9,10].find {|n| n > 100 }
=> nil
```

It's interesting to ponder the case where your array has `nil` as one of its elements, and your code block looks for a
element equal to `nil`.

```irb
>> [1,2,3,nil,4,5,6].find {|n| n.nil? }
=> nil
```
In these circumstances, `find` always returns `nil`-whether the search succeeds or fails! That means the test is useless; you can't tell whether it succeeded. You can work around this situation with other techniques, such as the `include?` method, with which you can find out whether an array has `nil` as an element. You can also provide a "nothing found" function-a `Proc` object-as an argument to `find`, in which case that function will be called if the `find` operation fails. We haven't looked at the `Proc` objects in depth yet, although you've seen some examples of them in connection with the handling of code blocks. For future reference, here's an example of how to supply `find` with a failure-handling function:

```irb
>> failure = lambda { 11 }              #<----1.
=> #<Proc:0x000000026333a8@(irb):3 (lambda)>
>> over_ten = [1,2,3,4,5,6].find(failure) {|n| n > 10 }
=> 11
```
In this example, the anonymous function (the `Proc` object) returns `11` (#1), so even if there's no number greater than 10 in the array, you get one anyway. (We'll see lambdas and `Proc` objects up close later on)

Although `find` always returns one object, `find_all`, also known as `select`, always returns an array, as does its negative equivalent `reject`.

**The dominance of the array**
Arrays serve generically as the containers for most of the results that come back from enumerable selecting and filtering operations, whether or not the object being selected from or filtered is an array. There are some exceptions to this quasi-rule, but it holds true widely.

The plainest way to see it is by creating an enumerable class of your own and watching what you get back from your select queries. Look again at the `Rainbow` class, Now look at what you get back when you perform some queries. 

```irb
>> r = Rainbow.new
=> #<Rainbow:0x000000011d4088>
>> r.select { |color| color.size == 6 }
=> ["orange", "yellow", "indigo", "violet"]
>> r.map {|color| color[0,3] }
=> ["red", "ora", "yel", "gre", "blu", "ind", "vio"]
>> r.drop_while {|color| color.size < 5 }
=> ["orange", "yellow", "green", "blue", "indigo", "violet"]
```
In every case, the result set comes back in an array.

The array is the most generic container and therefore the logical candidate for the role of universal result format. A few exceptions arise. A hash returns a hash from a `select` or `reject` operation. Sets return arrays from `map`, but you can call `map!` on a set to change the elements of the set in place. For the most part, though, enumerable selection and filtering operations come back to you inside arrays.

### *Getting all matches with find_all (a.k.a. select) and reject* ###
`find_all` (the same method as `select`) returns a new collection containing all the elements of the original collection that match the criteria in the code block, not just the first such element (as with `find`). If no matching elements are found, `find_all` returns an empty collection object.

In the general sense-for example, when you use `Enumerable` in your own classes-the "collection" returned by `select` will be an array. Ruby makes special arrangements for hashes and sets, though; if you `select` on a hash or set, you get back a hash or set. This is enhanced behavior that isn't strictly part of `Enumerable`.

We'll stick to array examples here:

```irb
>> a = [1,2,3,4,5,6,7,8,9,10]
=> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
>> a.find_all {|item| item > 5 }
=> [6, 7, 8, 9, 10]                 #<----------1.
>> a.select {|item| item > 100 }
=> []                               #<----------2.
```
The first `find_all` operation returns an array of all the elements that pass the test in the block: all elements that are greater than 5 (#1). The second operation also returns an array, this time of all the elements in the original array that are greater than 100. There aren't any, so an empty array is returned (#2).

(Arrays, hashes, and sets have a bang version, `select!`, that reduces the collection permanently to only those elements that passed the selection test. There's no `find_all!` synonym; you have to use `select!`.)

Just as you can select items, so you can reject items, meaning that you find out which elements of an array do not return a true value when yielded to the block. Using the `a` array from the previous example, you can do this to get the array minus any and all elements that are greater than 5:

```irb
>> a.reject {|item| item > 5 }
=> [1, 2, 3, 4, 5]
```
(Once again, there's a bang, in-place version, `reject!`, specifically for arrays, hashes and sets.)

If you've ever used the command-line utility `grep`, the next method will ring a bell. If you haven't, you'll get the hang of it anyway.

### *Selecting on threequal matches with grep* ###
The `Enumerable#grep` method lets you select from an enumerable object based on the case equality operator, `===`. The most common application of `grep` is the one that corresponds most closely to the common operation of the command-line utility of the same name, pattern matching for strings:

```irb
>> colors = %w{ red orange yellow green blue indigo violet }
=> ["red", "orange", "yellow", "green", "blue", "indigo", "violet"]
>> colors.grep(/o/)
=> ["orange", "yellow", "indigo", "violet"]
```
But the generality of `===` lets you do some fancy things with `grep`:

```irb
>> miscellany = [75, "hello", 10...20, "goodbye"]
=> [75, "hello", 10...20, "goodbye"]
>> miscellany.grep(String)              #<------1.
=> ["hello", "goodbye"]
>> miscellany.grep(50..100)             #<------2.
=> [75]
```

`String === object` is true for the two strings in the array, so an array of those two strings is what you get back from grepping for `String` (#1). Ranges implement `===` as an inclusion test. The range `50..100` includes 75; hence the result from grepping `miscellany` for that range (#2).

In general, the statement `enumerable.grep(expression)` is functionally equivalent to this:

`enumerable.select {|element| expression === element }`

In other words, it selects for a truth value based on calling `===`. In addition, `grep` can take a block, in which case it yields each element of its result set to the block before returning the results:

```irb
>> colors = %w{ red orange yellow green blue indigo violet }
=> ["red", "orange", "yellow", "green", "blue", "indigo", "violet"]
>> colors.grep(/o/) {|color| color.capitalize }
=> ["Orange", "Yellow", "Indigo", "Violet"]
```

The full `grep` syntax:

`enumerable.grep(expression) {|item| ... }`

thus operates in effect like this:

`enumerable.select {|item| expression === item}.map {|item| ... }`

Again, you'll mostly see (and probably mostly use) `grep` as a pattern-based string selector. But keep in mind that grepping is pegged to case equality (`===`) and can be used accordingly in a variety of situations.

Whether carried out as `select` or `grep` or some other operation, selection scenarios often call for grouping of results into clusters or categories. The `Enumerable#group_by` and `#partition` methods make convenient provisions for exactly this kind of grouping.

### *Organizing selection results with group_by and partition* ###
A `group_by` operation on an enumerable object takes a block and returns a hash. The block is executed for each object. For each unique block return value, the results hash gets a key; the value for that key is an array of all the elements of the enumerable for which the block returned that value.

An example should make the operation clear:

```irb
>> colors = %w{ red orange yellow green blue indigo violet }
=> ["red", "orange", "yellow", "green", "blue", "indigo", "violet"]
>> colors.group_by {|color| color.size }
=> {3=>["red"], 6=>["orange", "yellow", "indigo", "violet"], 5=>["green"], 4=>["blue"]}
```
The block `{|color| color.size}` returns an integer for each color. The hash returned by the entire `group_by` operation is keyed to the various sizes (3,4,5,6), and the values are arrays containing all the strings from the original array that are of the size represented by the respective keys.

The `partition` method is similar to `group_by`, but it splits the elements of the enumerable into two arrays based on whether the code block returns true for the element. There's no hash, just an array of two arrays. The two arrays are always returned in true/false order.

Consider a `Person` class, where every person has an age. The class also defines an instance method `teenager?`, which is true if the person's age is between 13 and 19, inclusive:

```ruby
class Person
  attr_accessor :age
  def initialize(options)
    self.age = options[:age]
  end
  def teenager?
    (13..19) === age
  end
end
```
