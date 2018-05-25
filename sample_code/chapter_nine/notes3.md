### *Combining hashes with other hashes* ###
The process of combining two hashes into one comes in two flavors: the destructive flavor, where the first hash has the key/value pairs from the second hash added to it directly; and the nondestructive flavor, where a new, third hash is created that combines the elements of the original two.

The destructive operation is performed with the `update` method. Entries in the first hash are overwritten permanently if the second hash has a corresponding key:

```ruby
h1 = {"Smith" => "John",
      "Jones" => "Jane" }
h2 = {"Smith" => "Jim"}
h3 = h1.update(h2)
puts h1["Smith"]

# Jim
```
In this example, `h1`'s `"Smith"` entry has been changed (updated) to the value it has in `h2`. You're asking for a refresh of your hash to reflect the contents of the second hash. That's the destructive version of combining hashes.

To perform nondestructive combining of two hashes, use the `merge` method, which gives you a third hash and leaves the original unchanged:

```ruby
h1 = {"Smith" => "John",
      "Jones" => "Jane" }
h2 = {"Smith" => "Jim"}
h3 = h1.merge(h2)
p h1["Smith"]

# "John"
```
Here `h1`'s `"Smith"/"John"` pair isn't overwritten by `h2`'s `"Smith"/"Jim"` pair. Instead, a new hash is created with pairs from both of the other two. That hash will look like this, if examined:

`{"Smith"=> "Jim", "Jones"=>"Jane"}`

Note that `h3` has a decision to make: which of the two `Smith` entries should it contain? The answer is that when the two hashes being merged share a key, the second hash (`h2` in this example) wins. `h3`'s value for the key `"Smith"` will be `"Jim"`.

Incidentally, `merge!`-the bang version of `merge`-is a synonym for `update`. You can use either name when you want to perform that operation.

In addition to being combined with other hashes, hashes can also be transformed in an umber of ways, as you'll see next.

### *Hash transformations* ###
You can perform several transformations on hashes. *Transformation*, in this context, means that the method is called on a hash, and the result of the operation (the method's return value) is a hash. In the next chapter, you'll see other filtering and selecting methods on hashes that return their result sets in arrays. Here we're looking at hash-to-hash operations.

#### SELECTING AND REJECTING ELEMENTS FROM A HASH ####
To derive a subhash from an existing hash, use the `select` method. Key/value pairs will be passed in succession to the code block you provide. Any pair for which the block returns a true value will be included in the result hash:

```irb
>> h = Hash[1,2,3,4,5,6]
=> {1=>2, 3=>4, 5=>6}
>> h.select {|k,v| k > 1 }
=> {3=>4, 5=>6}
```
Rejecting elements from a hash works in the opposite way-those key/value pairs for which the block returns true are excluded from the result hash:

```irb
>> h.reject {|k,v| k > 1}
=> {1=>2}
```
`select` and `reject` have in-place equivalents (versions that change the original hash permanently, rather than returning a new hash): `select!` and `reject!`. These two methods return `nil` if the hash doesn't change. To do an in-place operation that returns your original hash (even if it's unchanged), you can use `keep_if` and `delete_if`

#### INVERTING A HASH ####
`Hash#invert` flips the keys and the values. Values become keys, and keys become values:

```irb
>> h = { 1 => "one", 2 => "two" }
=> {1=>"one", 2=>"two"}
>> h.invert
=> {"one"=>1, "two"=>2}
```
Be careful when you invert hashes. Because hash keys are unique, but values aren't, when you turn duplicate values into keys, one of the pairs is discarded:

```irb
```
