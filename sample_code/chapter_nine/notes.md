# *Collection and container objects* #
In programming, you generally deal not only with individual objects but with *collections* of objects. You search through collections to find an object that matches criteria (like a magazine object containing a particular article); you sort collections for further processing or visual presentation; you filter collections to include or exclude particular items; and so forth. All of these operations, and similar ones, depend on objects being accessible in colltions. 

Ruby represents collections of objects by putting them inside *container* objects. In Ruby, two built-in classes dominate the container-object landscape: *arrays* and *hashes*. 

Ranges are a bit of a hybrid: they word partly as Boolean filters (in the sense that you can perform a true/false test as to whether a given value lies inside a given range), but also, in some contexts, as collections. Sets are collections through and through. The only reason the `Set` class requires special introduction is that it isn't a core Ruby class; it's a standard library class. 

Keep in mind that collections are, themselves, objects. You send them messages, assign them to variables, and so forth, in normal object fashion. They just have an extra dimension, beyond the scalar. 

## *Arrays and hashes in comparison* ##
An *array* is an ordered collection of objects-*ordered* in the sense that you can select objects from the colleciton based on a consistent, consecutive numerical index. You'll have noticed that we've already used arrays in some of the examples earlier in the book. It's hard *not* to use arrays in Ruby. An array's job is to store other objects. Any object can be stored in an array, including other arrays, hashes, file handles, classes, `true` and `false`...any object at all. The contents of an array always remain in the same order unless you explicitly move objects around (or add or remove them).

*Hashes* in recent versions of Ruby are also ordered collections-and that's a big change from previous versions, where hashes are unordered (in the sense that they have no idea of what their first, last or *n*th element is). Hashes store objects in pairs, each pair consisting of a *key* and a *value*. You retrieve a value by means of the key. Hashes remember the order in which their keys were inserted; that's the order in which the hash replays itself for you if you iterate through the pairs in it or print a string representation of it to the screen.

Any Ruby object can serve as a hash key and/or value, but keys are unique per hash: you can have only one key/value pair for any given key. Hashes (or similar data storage types) are sometimes called *dictionaries* or *associative arrays* in other languages. They offer a tremendously-sometimes surprisingly-powerful way of storing and retrieving data. 

Arrays and hashes are closely connected. An array is, in a sense, a hash, where the keys happen to be consecutive integers. Hashes are, in a sense, arrays, where the indexes are allowed to be anything, not just integers. If you do use consecutive integers as hash keys, arrays and hashes start behaving similarly when you do lookups:

```irb 
array = ["ruby", "diamond", "emerald"]
hash = { 0 => "ruby", 1 => "diamond", 2 => "emerald" }
puts array[0] #ruby 
puts hash[0] #ruby 
```
Even if you don't use integers, hashes exhibit a kind of "meta-index" property, based on the fact that they have a certain number of key/value pairs and that those pairs can be counted off consecutively. You can see this property in action by stepping through a hash with the `with_index` method, which yields a counter value to the block along with the key and value:

```irb 
hash = { "red" => "ruby", "white" => "diamond", "green" => "emerald" }
hash.each.with_index {|(key,value), i|}
  puts "Pair #{i} is: #{key}/#{value} "
}
```
The output from this code snippet is:

```irb 
Pair 0 is: red/ruby 
Pair 1 is: white/diamond 
Pair 2 is: green/emerald
```
The *index* is an integer counter, maintained as the pairs go by. The pairs are the actual content of the hash.

**TIP** The parentheses in the block paramenters `(key, value)` serve to split appat an array. Each key/value pair comes at the block as an array of two elements. If the parameters were `key, value, i`, then the parameter `key` would end up bound to the entire `[key, value]` array; `value` would be bound to the index; and `i` would be `nil`. That's obviously not what you want. The parenthetical grouping of `(key, value)` is a signal that you want the array to be distributed across those two parameters, element by element. 

Conversions of various kinds between arrays and hashes are common. Some such conversions are automatic: if you perform certain operations of selection or extraction of pairs from a hash, you'll get back an array. Other conversions require explicit instructions, such as turning a flat array (`[1,2,3,4]`) into a hash (`{1 => 2, 3 => 4}`). You'll see a good amount of back and forth between these two collection classes, both here in this chapter and in lots of Ruby code. 

## *Collection handling with array* ##
Arrays are the bread-and-butter way to handle collections of objects. We'll put arrays through their paces in this section: we'll look at the varied techniques available for creating arrays; how to insert, retrieve, and remove array elements; combining arrays wtih each other; transforming arrays (for example, flattening a nested array into a one-dimensional array); and querying arrays as to their properties and state. 

### *Creating a new array* ###
You can create an array in one of four ways:

• With the `Array.new` method.

• With the literal array constructor (square brackets)

• With a top-level method called `Array`.

• With the special `%w{...}` and `%i{...}` notations.

You'll see all of these techniques in heavy rotation in Ruby code, so they're all worth knowing. We'll look at each in turn. 

#### ARRAY.NEW #### 
The `new` method on the array class works in the usual way:

`a = Array.new`

You can then add objects to the array using techniques we'll look at later.

`Array.new` lets you specify the size of the array and, if you wish, initialize it's contents. Here's an irb exchange that illustrates both possibilities: 

```irb 
>> Array.new(3)               #<-----1.
=> [nil, nil, nil]
>> Array.new(3, "abc")          #<-----2.
=> ["abc", "abc", "abc"]
```
If you give one argument to `Array.new` (#1), you can get an array of the size you asked for, with all elements set to `nil`. If you give two arguments (#2), you get an array of the size you asked for, with each element initialized to contain the second argument.

You can even supply a code block to `Array.new`. In that case, the elements of the array are initialized by repeated calls to the block:

```irb 
>> n = 0
=> 0
>> Array.new(3) { n += 1; n * 10}     #<-------1.
=> [10, 20, 30]                           #<-------2.
```
In this example, the new array has a size of `3`. Each of the three lements is set to the return value of the code block. The code block inside the block (#1), executed three times, produces the values `10`, `20`, and `30`-and those are the initial values in the array (#2).

**WARNING** When you initialize multiple elements of an array using a second argument to `Array.new`-as in `Array.new(3, "abc")`-all the elements of the array are initialized to the same object. If you do `a = Array.new(3, "abc"); a[0] << "def"; puts a[1]`, you'll find that the second element of the array is now `"abcdef"`, even though you appended `"def"` to the first element. That's because the first and second positions in the array contain the same string object, not two different strings that happen to both consist of `"abc"`. To create an array that inserts a different `"abc"` string into each slot, you should use `Array.new(3) { "abc" }`. This code block runs three times, each time generating a new string (same characters, different object). 

Preinitializing arrays isn't always necessary; because your arrays grow as you add elements to them. But if and when you need this functionality-and/or if you see it in use and want to understand it-it's there. 

#### THE LITERAL ARRAY CONSTRUCTOR: [] ####
The second way to create an array is by using the *literal array constructor* [] (square brackets):

`a = []`

When you create an array with the literal constructor, you can put objects into the array at the same time:

`a = [1, 2, "three", 4, []]` 

Notice that the last element in this array is another array. That's perfectly legitimate; you can nest arrays to as many levels as you wish. 

Square brackets can mean a lot of different things in Ruby: array construction, array indexing (as well as string and hash indexing), character classes in regular expressions, delimiters in `%q[]`-style string notation, even the calling of an anonymous function. You can make an initial division of the various uses of square brackets by distinguishing cases where they're a semantic construct from cases where they're the name of a method. It's worth practicing on a few examples like this to get a feel for the way the square brackets play out in different contexts: 

`[1,2,3][1]`  <---- Index 1 on array [1,2,3]

Now back to array creation.

#### THE ARRAY METHOD ####
