### *Combining arrays with other arrays* ###
Several methods allow you to combine multiple arrays in various ways-something that, it turns out, is common and useful when you begin manipulating lots of data in lists. Remember that in every case, even though you're dealing with two (or more) arrays, one array is always the receiver of the message. The other arrays involved in the operation are arguments to the method.

To add the contents of one array to another array, you can use `concat`.

```irb
>> [1,2,3].concat([4,5,6])
=> [1, 2, 3, 4, 5, 6]
```
Note that `concat` differs in an important way from `push`. Try replacing `concat` with `push` in the example and see what happens. (`[1, 2, 3, [4, 5, 6]]`)

`concat` permanently changes the contents of its receiver. If you want to combine two arrays into a third, new array, you can do so with the `+` method:

```irb
>> a = [1,2,3]
=> [1, 2, 3]
>> b = a + [4,5,6]
=> [1, 2, 3, 4, 5, 6]
>> a
=> [1, 2, 3]       #<-----1.
```
The receiver of the `+` message-in this case, the array `a`-remains unchanged by the operation (as irb tells you (#1)).

Another useful array-combining method, at least given a fairly liberal interpretation of the concept "combining", is `replace`. As the name implies, `replace` replaces the contents of one array with the contents of another:

```irb
>> a = [1,2,3]
=> [1, 2, 3]
>> a.replace([4,5,6])           #<-------1.
=> [4, 5, 6]
>> a
=> [4, 5, 6]
```
The original contents of `a` are gone, replaced (#1) by the contents of the argument array `[4,5,6]`. Remember that a `replace` operation is different from reassignment. If you do this:

```ruby
a = [1,2,3]
a = [4,5,6]
```
The second assignment causes the variable `a` to refer to a completely different array object than the first. That's not the same as replacing the elements of the *same* array object. This starts to matter, in particular, when you have another variable that refers to the original array, as in this code:

```irb
>> a = [1,2,3]
=> [1, 2, 3]
>> b = a                        #<-------1.
=> [1, 2, 3]
>> a.replace([4,5,6])
=> [4, 5, 6]
>> b                         #<-------2.
=> [4, 5, 6]
>> a = [7,8,9]
=> [7, 8, 9]             #<-------3.
>> b
=> [4, 5, 6]           #<-------4.
```
Once you've performed the assignment of `a` to `b` (#1), replacing the contents of `a` means you've replaced the contents of `b` (#2), because the two variables refer to the same array. But when you reassign to `a` (#3), you break the binding between `a` and the array; `a` and `b` now refer to different array objects: `b` to the same old array (#4), `a` to a new one.

In addition to combining multiple arrays, you can also transform individual arrays to different forms. We'll look next at techniques along these lines.

### *Array transformation* ###
A useful array transformation is `flatten`, which does an un-nesting of inner arrays. You can specify how many levels of flattening you want, with the default being the full un-nesting.

Here's a triple-nested array being flattened by various levels:

```irb
>> array = [1,2,[3,4,[5],[6,[7,8]]]]
=> [1, 2, [3, 4, [5], [6, [7, 8]]]]
>> array.flatten                            #<------Flattens completely
=> [1, 2, 3, 4, 5, 6, 7, 8]
>> array.flatten(1)                      #<------Flattens by one level
=> [1, 2, 3, 4, [5], [6, [7, 8]]]
>> array.flatten(2)                         #<------Flattens by two levels
=> [1, 2, 3, 4, 5, 6, [7, 8]]               
```
There's also an in-place `flatten!` method, which makes the changes permanently in teh array.

Another array-transformation method is `reverse`, which does exactly what it says:

```irb
>> [1,2,3,4].reverse
=> [4, 3, 2, 1]
```
Like its string counterpart, `Array#reverse` also has a bang (`!`) version, which permanently reverses the array that calls it.

Another important array-transformation method is `join`. The return value of `join` isn't an array but a string, consisting of the string representation of all the elements of the array strung together:

```irb
>> ["abc", "def", 123].join
=> "abcdef123"
```
`join` takes an optional argument; if given, the argument is placed between each pair of elements:

```irb
>> ["abc", "def", 123].join(", ")
=> "abc, def, 123"
```
Joining with commas (or comma-space, as in the last example) is a fairly common operation.

In a great example of Ruby's design style, there's another way to join an array; the `*` method. It looks like you're multiplying the array by a string, but you're actually performing a join operation:

```irb
>> a = %w{ one two three }
=> ["one", "two", "three"]
>> a * "-"
=> "one-two-three
```
You can also transform an array with `uniq`. `uniq` gives you a new array, consisting of the elements of the original array with all duplicate elements removed:

```irb
>> [1,2,3,1,4,3,5,1].uniq
=> [1, 2, 3, 4, 5]
```
Duplicate status is determined by testing pairs of elements with the `==` method. Any two elements for which the `==` test returns `true` are considered duplicates of each other. `uniq` also has a bang version, `uniq!`, which removes duplicates permanently from the original array.

Sometimes you have an array that includes one or more occurrences of `nil`, and you want to get rid of them. You might, for example, have an array of the ZIP codes of all the members of an organization. But maybe some of them don't have ZIP codes. If you want to do a histogram on the ZIP codes, you'd want to get rid of the `nil` ones first.

You can do this with the `compact` method. This method returns a new array identical to the original array, except that all occurrences of `nil` have been removed:

```irb
>> zip_codes = ["06511", "08902", "08902", nil, "10027", "08902", nil, "06511"]
=> ["06511", "08902", "08902", nil, "10027", "08902", nil, "06511"]
>> zip_codes.compact
=> ["06511", "08902", "08902", "10027", "08902", "06511"]
```
Once again, there's a bang version (`compact!`) available.

In addition to transforming arrays in various ways, you can query arrays on various criteria.

### *Array querying* ###
Several methods allow you to gather information about an array from the array. The table below summarizes some of them. Other query methods arise from `Array`'s inclusion of the `Enumerable` module and will therefore come into view in the next chapter.

##### Summary of common array query methods #####
|     Method name/Sample call       |                     Meaning                                   |
|-----------------------------------|---------------------------------------------------------------|
|`a.size`  (`synonym: length`)      | Number of elements in the array                               |
| `a.empty?`                        | True if `a` is an empty array; false if it has any elements   |
| `a.include?(item)`                | True if the array includes items; false otherwise             |
|  `a.count(item)`                  | Number of occurrences of `item` in array                      |
|  `a.first(n=1)`                   | First *n* elements of array                                   |
| `a.last(n=1)`                     | Last *n* elements of array                                    |
| `a.sample(n=1)`                   | *n* random elements from array                                |

In the cases of `first`, `last`, and `sample`, if you don't pass in an argument, you get just one element back. If you do pass in an argument *n*, you get an array of *n* elements back-even if *n* is 1.

Next up: hashes. They've crossed our path here and there along the way, and now we'll look at them in detail.


## *Hashes* ##
Like an array, a hash is a collection of objects. A hash consists of key/value pairs, where any key and any value can be any Ruby object. Hashes let you perform lookup operations based on keys. In addition to simple key-based value retrieval, you can also perform more complex filtering and selection operations.

A typical use of a hash is to store complete strings alone with their abbreviations. Here's a hash containing a selection of names and two-letter state abbreviations, along with some code that exercises it. The `=>` operator connects a key on the left iwth the value corresponding to it on the right (hash rocket):

```ruby
state_hash = { "Connecticut" => "CT",
               "Delaware" => "DE",
               "New Jersey" => "NJ",
               "Virginia" => "VA" }
print "Enter the name of a state: "
state = gets.chomp
abbr = state_hash[state]
puts "The abbreviation is #{abbr}."
```
When you run this snippet (assuming you enter one of the states defined in the hash), you see the abbreviation.

Hashes remember the insertion order of their keys. Insertion order isn't always terribly important; one of the merits of a hash is that it provides quick lookup in better-than-linear time. And in many cases, items get added to hashes in no particular order; ordering, if any, comes later, when you want to turn, say, a hash of names and birthdays that you've created over time into a chronologically or alphabetically sorted array. Still, however useful it may or may not be for them to do so, hashes remember their key-insertion order and observe that order when you iterate over them or examine them.

Like arrays, hashes can be created in several different ways.

### *Creating a new hash* ###
There are four ways to create a hash:

• With the literal constructor (curly braces)

• With the `Hash.new` method

• With the `Hash.[]` method (a square-bracket class method of `Hash`)

• With the top-level method whose name is `Hash`

These hash-creation techniques are listed here, as closely as possible, in descending order of commonness. In other words, we'll start with the most common technique and proceed from there.

#### CREATING A LITERAL HASH ####
When you type out a literal hash inside curly braces, you separate keys from values with the `=>` operator (unless you're using the special `{ key: value }` syntax for symbol keys). After each complete key/value pair you put a comma (except for the last pair, where it's optional).

The literal hash constructor is convenient when you have values you wish to hash that aren't going to change; you'll type them into the program file once and refer to them from the program. State abbreviations are a good example.

You can use the literal hash constructor to create an empty hash:

`h = {} `

You'd presumably want to add items to the empty hash at some point; techniques for doing so will be forthcoming.

The second way to create a hash is with the traditional `new` constructor.

#### THE HASH.NEW CONSTRUCTOR ###
`Hash.new` creates an empty hash. But if you provide an argument to `Hash.new`, it's treated as the default value for nonexistent hash keys. We'll return to the matter of default values, and some bells and whistles on `Hash.new` once we've looked at key/value insertion and retrieval.

#### THE HASH.[] CLASS METHOD ####
The third way to create a hash involves another class method of the `Hash` class: the method `[]` (square brackets). this method takes a comma-separated list of items and assuming there's an even number of arguments, treats them as alternating keys and values, which it uses to construct a hash. Thanks to Ruby's syntactic sugar, you can put the arguments to `[]` directly inside the brackets and dispense them with the method-calling dot:

```irb
>> Hash["Connecticut", "CT", "Delaware", "DE"]
=> {"Connecticut"=>"CT", "Delaware"=>"DE"}
```
If you provide an odd number of arguments, a fatal error is raised, because an odd number of arguments can't be mapped to a series of key/value pairs. However, you can pass in an array of arrays, where each subarray consists of two elements. `Hash.[]` will use the inner arrays as key/value pairs:

```irb
Hash [ [[1,2], [3,4], [5,6]]]
=> {1=>2, 3=>4, 5=>6}
```
You can also pass in anything that has a method called `to_hash`. The new hash will be the result of calling that method. Another hash-creation technique involves the top-level `Hash` method.

#### THE HASH METHOD ####
The `Hash` method has slightly idiosyncratic behavior. If called with an empty array ([]) or `nil`, it returns an empty hash. Otherwise, it calls `to_hash` on its single argument. If the argument doesn't have a `to_hash` method, a fatal error (`TypeError`) is raised.

You've now seen a number of ways to create hashes. Remember that they're in approximate descending order by commonness. You'll see a lot more literal hash constructors and calls to `Hash.new` than you will the rest of the techniques presented. Still, it's good to know what's available and how the various techniques work.

### *Inserting, retrieving, and removing hash pairs* ###
Hashes have a lot in common with arrays when it comes tot he get- and set-style operations-though there are some important differences and some techniques that are specific to each.

#### ADDING A KEY/VALUE PAIR TO A HASH ####
To add a key/value pair to a hash, you use essentially the same technique as for adding an item to an array: the `[]=` method plus syntactic sugar.

To add a state to `state_hash` to this:

`state_hash["New York"] = "NY"`

which is the sugared version of this:

`state_hash.[]= ("New York", "NY")`

You can also use the synonymous method `store` for this operation. `store` takes two arguments (a key and a value):

`state_hash.store("New York", "NY")`

When you're adding to a hash, keep in mind the important principle that keys are unique. You can have only one entry with a given key. Hash values don't have to be unique; you can assign the same value to two or more keys. But you can't have duplicate keys.

If you add a key/value pair to a hash that already has an entry for the key you're adding, the old entry is overwritten. Here's an example:

```ruby
h = Hash.new
h["a"] = 1
h["a"] = 2
puts h["a"]   #<---- Output 2
```
This code assigns two values to the `"a"` key of the hash `h`. The second assignment clobbers the first, as the `puts` statement shows by outputting `2`.

If you reassign to a given hash key, that key still maintains its place in the insertion order of the hash. The change in the value paired with the key isn't considered a new insertion into the hash.

#### RETRIEVING VALUES FROM A HASH ####
The workhorse technique for retrieving hash values is the `[]` method. For example, to retrieve `"CT"` from `state_hash` and assign it to a variable, do this:

`conn_abbrev = state_hash["Connecticut"]`

Using a hash key is much like indexing an array-except that the index (the key) can be anything, whereas in an array it's always an integer.

Hashes also have a `fetch` method, which gives you an alternative way of retrieving values by key:

`conn_abbrev = state_hash.fetch("Connecticut")`

`fetch` differs from `[]` in the way it behaves when you ask it to look up a nonexistent key: `fetch` raises an exception, whereas `[]` gives you either `nil` or a default you've specified (as discussed in the next section). If you provide a second argument to hash, that argument will be returned, instead of an exception being raised if the key isn't found. For example, this code

`state_hash.fetch("Nebraska", "Unknown state")`

evaluates to the string `"Unknown state"`.

You can also retrieve values for multiple keys in one operation, with `values_at`:

`two_states = state_hash.values_at("New Jersey", "Delaware")`

This code returns an array consisting of `["NJ", "DE"]` and assigns it to the variable `two_states`.

Now that you have a sense of the mechanics of getting information into and out of a hash, let's circle back and look at the matter of supplying a default value (or default code block) when you create a hash.

### *Specifying default hash values and behaviors* ###
