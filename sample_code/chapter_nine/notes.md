# *Collection and container objects* #
In programming, you generally deal not only with individual objects but with *collections* of objects. You search through collections to find an object that matches criteria (like a magazine object containing a particular article); you sort collections for further processing or visual presentation; you filter collections to include or exclude particular items; and so forth. All of these operations, and similar ones, depend on objects being accessible in collections.

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
hash.each.with_index {|(key,value), i|
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

**TIP** The parentheses in the block parameters `(key, value)` serve to split appat an array. Each key/value pair comes at the block as an array of two elements. If the parameters were `key, value, i`, then the parameter `key` would end up bound to the entire `[key, value]` array; `value` would be bound to the index; and `i` would be `nil`. That's obviously not what you want. The parenthetical grouping of `(key, value)` is a signal that you want the array to be distributed across those two parameters, element by element.

Conversions of various kinds between arrays and hashes are common. Some such conversions are automatic: if you perform certain operations of selection or extraction of pairs from a hash, you'll get back an array. Other conversions require explicit instructions, such as turning a flat array (`[1,2,3,4]`) into a hash (`{1 => 2, 3 => 4}`). You'll see a good amount of back and forth between these two collection classes, both here in this chapter and in lots of Ruby code.

## *Collection handling with array* ##
Arrays are the bread-and-butter way to handle collections of objects. We'll put arrays through their paces in this section: we'll look at the varied techniques available for creating arrays; how to insert, retrieve, and remove array elements; combining arrays wih each other; transforming arrays (for example, flattening a nested array into a one-dimensional array); and querying arrays as to their properties and state.

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
In this example, the new array has a size of `3`. Each of the three elements is set to the return value of the code block. The code block inside the block (#1), executed three times, produces the values `10`, `20`, and `30`-and those are the initial values in the array (#2).

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
The third way to create an array is with a *method* (even though it looks like a class name!) called `Array`. As you know from having seen the `Integer` and `Float` methods, it's legal to define methods whose names begin with capital letters. Those names look exactly like constants, and in core Ruby itself, capitalized methods tend to have the same names as classes to which they're related.

**Some more built-in methods that start with uppercase letters**
In addition to the `Array` method and the two uppercase-style conversion methods you've already seen (`Integer` and `Float`, the "fussy" versions of `to_i` and `to_f`), Ruby provides a few other top-level methods whose names look like class names: `Complex`, `Rational`, and `String`. In each case, the method returns an object of the class that its name looks like.

The `String` method is a wrapper around `to_s`, meaning `String(obj)` is equivalent to `obj.to_s`. `Complex` and `Rational` correspond to the `to_c` and `to_r` methods available for numerics and strings except `Complex` and `Rational`, like `Integer` and `Float` are fussy: they don't take kindly to non-numeric strings. `"abc".to_c` gives you (`0+0i`), but `Complex("abc")` raises `ArgumentError`, and `Rational` and `to_r` behave similarly.

We're not covering rational and complex numbers here, but now you know how to generate them, in case they're of interest.
___________________
The `Array` method creates an array from its single argument. If the argument object has a `to_ary` method defined, then `Array` calls that method on the object to generate an array. (Remember that `to_ary` is the quasi-typcasting array conversion method.) If there's no `to_ary` method, it tries to call `to_a`. If `to_a` isn't defined either, `Array` wraps the object in an array and returns that:

```irb
>> string = "A string"
=> "A string"
>> string.respond_to?(:to_ary)
=> false
>> string.respond_to?(:to_a)
=> false
>> Array(string)                      #<-----1.
=> ["A string"]
>> def string.to_a                       #<-----2.
>>    split(//)
>> end
=> nil
>> Array(string)
=> ["A", " ", "s", "t", "r", "i", "n", "g"]
```
In this example, the first attempt to run `Array` on the string (#1) results in a one-element array, where the one element is the string. That's because strings have neither a `to_ary` nor a `to_a` method. But after `to_a` is defined for the string (#2), the result of calling `Array` is different: it now runs the `to_a` method and uses that as its return value. (The `to_a` method splits the string into individual characters.)

Among the various array constructors, the literal `[]` is the most common, followed by `Array.new` and the `Array` method, in that order. But each has its place. The literal constructor is the most succinct; when you learn what it means, it clearly announces "array" when you see it. The `Array` method is constrained by the need for there to be a `to_ary` or `to_a` method available.

#### THE %w AND %W ARRAY CONSTRUCTORS ####
As a special dispensation to help you create arrays of strings, Ruby provides a `%w` operator, much in the same family as the `%q`-style operators you've seen already, that automatically generates an array of strings from the space-separated strings you put inside it. You can see how it works by using it in irb and looking at the result:

```irb
>> %w{ David A. Black }
=> ["David", "A.", "Black"]
```
If any string in the list contains a whitespace character, you need to escape that character with a backslash:

```irb
>> %w{ David\ A.\ Black is a Rubyist. }
=> ["David A. Black", "is", "a", "Rubyist."]
```
The strings in the list are parsed as single-quotes strings. But if you need double quotes strings, you can use `%W` instead of `%w`:

```irb
>> %W{ David is #{2014 - 1959} years old. }
=> ["David", "is", "55", "years", "old."]
```

#### THE %i AND %I ARRAY CONSTRUCTORS ####
Just as you can create arrays of strings using `%w` and `%W`, you can also create arrays of symbols using `%i` and `%I`. The `i/I` distinction, like the `w/W` distinction, pertains to single- versus double-qyoted string interpretation:

```irb
>> %i{ a b c }
=> [:a, :b, :c]
>> d = "David"
=> "David"
>> %I{"#{d}"}
=> [:"\"David\""]
```
Let's proceed now to the matter of handling array elements.

**The `try_convert` family of methods**
Each of several built-in classes in Ruby has a class method called `try_convert`, which always takes one argument. `try_convert` looks for a conversion method on the argument object. If the method exists, it gets called; if not, `try_convert` returns `nil`. If the conversion method returns an object of a class other than the class to which conversion is being attempted, it's a fatal error (`TypeError`).

The classes implementing `try_convert` (and the names of the required conversion methods) are `Array` (`to_ary`), `Hash` (`to_hash`), `IO` (`to_io`), `Regexp` (`to_regexp`), and `String` (`to_str`). Here's an example of an object putting `Array.try_convert` through its paces. (The other `try_convert` methods work similarly.)

```irb
>> obj = Object.new
=> #<Object:0x00000001028033a8>
>> Array.try_convert(obj)
=> nil
>> def obj.to_ary
>>    [1,2,3]
>> end
=> :to_ary
>> Array.try_convert(obj)
=> [1, 2, 3]
>> def obj.to_ary
>>    "Not an array!"
>> end
=> :to_ary
>> Array.try_convert(obj)
TypeError: can't convert Object to Array (Object#to_ary gives String
```

### *Inserting, retrieving, and removing array elements* ###
An array is a numerically ordered collection. Any object you add to the array goes at the beginning, at the end, or somewhere in the middle. The most general technique for inserting one or more items into an array is the setter method `[]=` (square brackets and equal sign). This looks odd as a method name in the middle of a paragraph like this, but thanks to its syntactic sugar equivalent, `[]=` works smoothly in practice.

To use `[]=`, you need to know that each item (or element) in an array occupies a numbered position. Te first element is at position *zero* (not position *one*). The second element is at position one, and so forth.

To insert an element with the `[]=` method-using the syntactic sugar that allows you to avoid the usual method-calling dot-do this:

```ruby
a = []
a[0] = "first"
```
The second like is syntactic sugar for `a.[]=(0, "first")`. In this example, you end up with a one-element array whose first (and only) element is the string `"first"`.

When you have objects in an array, you can retrieve those objects by using the `[]` method, which is the getter equivalent of the `[]=` setter method:

```ruby
a = [1,2,3,4,5]
p a[2]
```
In this case, the second line is syntactic sugar for `a.[](2)`. You're asking for the third element (based on the zero-origin indexing), which is the integer 3.

You can also perform these get and set methods on more than one element at a time.

#### SETTING OR GETTING MORE THAN ONE ARRAY ELEMENT AT A TIME ####
If you give either `Array#[]` or `Array#[]=` (the get or set method) a second argument, it's treated as a length-a number of elements to set or retrieve. In the case of retrieval, the results are returned inside a new array.

Here's some irb dialogue, illustrating the multi-element operations of the `[]` and `[]=` methods:

```irb
>> a = ["red", "orange", "yellow", "purple", "gray", "indigo", "violet"]
=> ["red", "orange", "yellow", "purple", "gray", "indigo", "violet"]
>> a[3,2]                    #<---------1.
=> ["purple", "gray"]
>> a[3,2] = "green", "blue"   #<----------2. Syntactic sugar for a.[]=(3,2["green", "blue"])
=> ["green", "blue"]
>> a
=> ["red", "orange", "yellow", "green", "blue", "indigo", "violet"]      #<------3.
```
After initializing the array `a`, we grab two elements (#1), starting at index 3 (the fourth element) of `a`. The two elements are returned in an array. Next we set the fourth and fifth elements, using the `[3,2]` notation (#2), to new values; these new values are then present in the whole array (#3) when we ask irb to display it at the end.

There's a synonym for the `[]` method: `slice`. Like `[]`, `slice` takes two arguments: a starting index and an optional length. In addition, a method called `slice!` removes the sliced items permanently from the array.

Another technique for extracting multiple array elements is the `values_at` method. `values_at` takes one or more arguments representing indexes and returns an array consisting of the values stored at those indexes in the receiver array:

```ruby
array = ["the", "dog", "ate", "the", "cat"]
articles = array.values_at(0, 3)
p articles

# ["the", "the"]
```
You can perform set and get operations on elements anywhere in an array. But operations specifically affecting the beginnings and ends of arrays crop up most often. Accordingly, a number of methods exist for the special purpose of adding items to or removing them from the beginning or end of an array, as you'll now see.

#### SPECIAL METHODS FOR MANIPULATING THE BEGINNINGS AND ENDS OF ARRAYS ####
To add an object to the beginning of an array, you can use `unshift`. After this operation

```ruby
a = [1,2,3,4]
a.unshift(0)
```
The array `a` now looks like this: `[0,1,2,3,4]`.

To add an object to the end of an array, you use `push`. Doing this:

```ruby
a = [1,2,3,4]
a.push(5)
```
Results in the array `a` having a fifth element: `[1,2,3,4,5]`.

You can also use a method called `<<` (two less-than signs), which places an object on the end of the array. Like many methods whose names resemble operators, `<<` offers the syntactic sugar of usage as an infix operator. The following code adds `5` as the fifth element of `a`, just like the `push` operation in the last example:

```ruby
a = [1,2,3,4]
a << 5
```
The methods `<<` and `push` differ in that `push` can take more than one argument. The code:

```ruby
a = [1,2,3,4,5]
a.push(6,7,8)
```
adds three elements to `a`, resulting in `[1,2,3,4,5,6,7,8]`.

Corresponding to `unshift` and `push` but with opposite effect are `shift` and `pop`. `shift` removes one object from the beginning of the array (thereby "shifting" the remaining objects to the left by one position), and `pop` removes an object from the end of the array. `shift` and `pop` both return the array element they have removed, as this example shows:

```ruby
a = [1,2,3,4,5]
print "The original array: "
p a
popped = a.pop
print "The popped item: "
puts popped
print "The new state of the array: "
p a
shifted = a.shift
print "The shifted item: "
puts shifted
print "The new state of the array: "
p a
```
The output is:

```irb  
The original array: [1, 2, 3, 4, 5]
The popped item: 5
The new state of the array: [1, 2, 3, 4]
The shifted item: 1
The new state of the array: [2, 3, 4]
```
As you can see from the running commentary in the output, the return value of `pop` and `shift` is the item that was removed from the array. The array is permanently changed by these operations; the elements are removed, not just referred to or captures.

`shift` and `pop` can remove more than one element at a time. Just provide an integer argument, and that number of elements will be removed. The removed items will be returned as an array (even if the number you provide is 1):

```irb
>> a = %w{ one two three four five }
=> ["one", "two", "three", "four", "five"]
>> a.pop(2)
=> ["four", "five"]
>> a
=> ["one", "two", "three"]
>> a.shift(2)
=> ["one", "two"]
>> a
=> ["three"]
```
We'll turn next from manipulating one array to looking ways to combne two or more arrays.
