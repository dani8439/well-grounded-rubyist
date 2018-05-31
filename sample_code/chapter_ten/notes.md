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
