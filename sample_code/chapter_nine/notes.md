# *Collection and container objects* #
In programming, you generally deal not only with individual objects but with *collections* of objects. You search through collections to find an object that matches criteria (like a magazine object containing a particular article); you sort collections for further processing or visual presentation; you filter collections to include or exclude particular items; and so forth. All of these operations, and similar ones, depend on objects being accessible in colltions. 

Ruby represents collections of objects by putting them inside *container* objects. In Ruby, two built-in classes dominate the container-object landscape: *arrays* and *hashes*. 

Ranges are a bit of a hybrid: they word partly as Boolean filters (in the sense that you can perform a true/false test as to whether a given value lies inside a given range), but also, in some contexts, as collections. Sets are collections through and through. The only reason the `Set` class requires special introduction is that it isn't a core Ruby class; it's a standard library class. 

Keep in mind that collections are, themselves, objects. You send them messages, assign them to variables, and so forth, in normal object fashion. They just have an extra dimension, beyond the scalar. 

## *Arrays and hashes in comparison* ##
An *array* is an ordered collection of objects-*ordered* in the sense that you can select objects from the colleciton based on a consistent, consecutive numerical index. You'll have noticed that we've already used arrays in some of the examples earlier in the book. It's hard *not* to use arrays in Ruby. An array's job is to store other objects. Any object can be stored in an array, including other arrays, hashes, file handles, classes, `true` and `false`...any object at all. The contents of an array always remain in the same order unless you explicitly move objects around (or add or remove them).

*Hashes* in recent versions of Ruby are also ordered collections-and that's a big change from previous versions, where hashes are unordered (in the sense that they have no idea of what their first, last or *n*th element is). Hashes store objects in pairs, each pair consisting of a *key* and a *value*. You retrieve a value by means of the key. Hashes remember the order in which their keys were inserted; that's the order in which the hash replays itself for you if you iterate through the pairs in it or print a string representation of it to the screen.

Any RUby object can serve as a hash key and/or value, but keys are unique per hash: you can have only one key/value pair for any given key. Hashes (or similar data storage types) are sometimes called *dictionaries* or *associative arrays* in other languages. They offer a tremendously-sometimes surprisingly-powerful way of storing and retrieving data. 

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

**TIP** The parentheses in the block paramenters `(key, value)` serve to split appart an array.
