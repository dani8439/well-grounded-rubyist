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
>> h = { 1 => "one", 2 => "more than 1", 3 => "more than 1" }
=> {1=>"one", 2=>"more than 1", 3=>"more than 1"}
>> h.invert
=> {"one"=>1, "more than 1"=>3}
```
Only one of the two `"more than 1"` values can survive as a key when the inversion is performed; the other is discarded. You should invert a hash only when you're certain the values as well as the keys are unique.

#### CLEARING A HASH ####
`Hash#clear` empties the hash:

```irb
>> {1 => "one", 2 => "two"}.clear
=> {}
```
This is an in-place operation: the empty hash is the same hash (the same object) as the one to which you send the `clear` message.

#### REPLACING THE CONTENTS OF A HASH ####
Like strings and arrays, hashes have a `replace` method:

```irb
>> { 1 => "one", 2 => "two" }.replace({ 10 => "ten", 20 => "twenty" })
=> {10=>"ten", 20=>"twenty"}
```
This is also an in-place operation, as the name `replace` implies.

Now we'll turn to hash query methods.

### *Hash querying* ###
Like arrays (and many other Ruby objects), hashes provide a number of methods with which you can query the state of the subject. The table below shows some common hash query methods:


##### Common hash query methods and their meanings #####
|     Method name/Sample call         |                     Meaning                         |
|-------------------------------------|-----------------------------------------------------|
| `h.has_key?(1)`                     | True if `h` has the key `1`                         |
| `h.include?(1)`                     | Synonym for `has_key?`                              |
| `h.key?(1)`                         | Synonym for `has_key?`                              |
| `h.member?(1)`                      | Synonym for `has_key?`                              |
| `h.has_value?("three")`             | True if any value in `h` is `three`                 |
| `h.value?("three")`                 | Synonym for `has_value?`                            |
| `h.empty?`                          | True if `h` has no key/value pairs                  |
| `h.size`                            | Number of key/value pairs in `h`                    |

None of the methods in the table above should offer any surprises at this point; they're similar in spirit, and in some cases in letter; to those you've seen for arrays. With the exception of `size`, they all return either true or false. The only surprise may be how many of them are synonyms. Four methods test for the presence of a particular key: `has_key?`, `include?`, `key?`, and `member?`. A case could be made that this is two or even three synonyms too many. `has_key?` seems to be the most popular of the four and is the most to-the-point with respect to what the method tests for.

The `has_value?` method has one synonym: `value?`. As with its key counterpart, `has_value?` seems to be more popular.

The other methods-`empty?` and `size`- tell you whether the hash is empty and what its size is. (`size` can also be called as `length`.) The size of a hash is the number of key/value pairs it contains.

Hashes get special dispensation in method argument lists, as you'll see next.

### *Hashes as final method arguments* ###
If you call a method in such a way that the *last* argument in the argument list is a hash, Ruby allows you to write the hash without curly braces. This perhaps trivial sounding special rule can, in practice, make argument lists look much nicer than they otherwise would.

Here's an example. The first argument to `add_to_city_database` is the name of the city; the second argument is a hash of data about the city, written without curly braces (and using the special `key: value` notation):

```ruby
add_to_city_database("New York City",
  state: "New York",
  population: 7000000,
  nickname: "Big Apple")
```
The method `add_to_city_database` has to do more work to gain access to the data being passed to it than it would if it were binding parameters to arguments in left-to-right order through a list:

```ruby
def add_to_city_database(name, info)
  c = City.new
  c.name = name
  c.state = info[:state]
  c.population = info[:population]
  #etc
end
```
**Hashes as first arguments**
In addition to learning about the special syntax available to you for using hashes as final method arguments without curly braces, it's worth noting a pitfall of using a hash as the first argument to a method. The rule in this case is that you must not only put curly braces around the hash but also put the entire argument list in parentheses. If you don't, Ruby will think your hash is a code block. In other words, when you do this:

`my_method { "NY" => "New York"}, 100, "another argument"`

Ruby interprets the expression in braces as a block. If you want to send a hash along as an argument in this position, you have to use parentheses around the entire argument list to make it clear that the curly braces are hash-related and not block-related.

----
Of course, the exact process involved in unwrapping the hash will vary from one case to another. (Perhaps `City` objects store their information as a hash; that would make the method's job a little easier.) But one way or another, the method has to handle the hash.

Keep in mind that although you get to leave the curly braces off the has literal when it's the last thing in an argument list, you can have as many hashes as you wish as method arguments, in any position. Just remember that it's only when a hash is in the final argument position that you're allowed to dispense with the braces.

Until Ruby 2 came along, hash arguments of this kind were the closest one could get to named or keyword arguments. That's all changed, though. Ruby now has real named arguments. Their syntax is very hashlike, which is why we're look at them here rather than in chapter 2.

### *A detour back to argument syntax: Named(keyword) arguments* ###
Using named arguments saves you the trouble of "unwrapping" hashes in your methods. Here's a barebones example that shows the most basic version of named arguments:

```irb
>> def m(a:, b:)
>> p a,b
>> end
=> :m
>> m(a: 1, b: 2)
1
2
=> [1, 2]
```
On the method end, there are two parameters ending with colons. On the calling end, there's something that looks a lot like a hash. Ruby matches everything up so that the values for `a` and `b` bind as expected. There's no need to probe into a hash.

In the preceding example, `a` and `b` indicate required keyword arguments. You can't call the method without them:

```irb
>> m
ArgumentError: missing keywords: a, b
        from (irb):1:in `m'
        from (irb):5
        from /usr/local/rvm/rubies/ruby-2.3.1/bin/irb:11:in `<main>'
>> m(a: 1)
ArgumentError: missing keyword: b
        from (irb):1:in `m'
        from (irb):6
        from /usr/local/rvm/rubies/ruby-2.3.1/bin/irb:11:in `<main>'
```
You can make keyword arguments optional by supplying default values for your named parameters-which makes the parameter list look even more hashlike:

```irb
>> def m(a: 1, b: 2)
>> p a, b
>> end
=> :m
>> m      #<-----1.
1
2
=> [1, 2]
>> m(a:10)   #<------2.
10
2
=> [10, 2]
```
When you call `m` with no arguments (#1), the defaults for `a` and `b` kick in. If you provide an `a` but no `b` (#2), you get the `a` you've provided and the default `b`.

What if you go in the other direction and call a method using keyword arguments that the method doesn't declare? If the method's parameter list includes a double starred name, the variable of that name will sponge up all unknown keyword arguments into a hash, as follows:

```irb
>> def m(a: 1, b: 2, **c)
>> p a,b,c
>> end
=> :m
>> m(x: 1, y: 2)
1
2
{:x=>1, :y=>2}
=> [1, 2, {:x=>1, :y=>2}]
```
If there's no keyword sponge parameter, a method call like `m(x:1, y:2)` is just passing along a hash, which may or may not fail, depending on what arguments the method is expecting.

And of course, you can combine keyword and nonkeyword arguments:

```irb
>> def m(x,y, *z, a: 1, b:, **c, &block)
>> p x,y,z,a,b,c
>> end
=> :m
>> m(1,2,3,4,5,b:10, p:20, q:30)
1
2
[3, 4, 5]
1
10
{:p=>20, :q=>30}
=> [1, 2, [3, 4, 5], 1, 10, {:p=>20, :q=>30}]
```
Here the method `m`:

• Takes two required positional arguments (`x` and `y` bound to `1` and `2`)

• Has a "sponge" parameter (`z`) that takes care of extra arguments following the positional ones (3,4,5).

• Has one optional and one required keyword argument (`a` and `b` respectively, bound to `1` and `10`).

• Has a keyword "sponge" (`c`) to absorb unknown named arguments (the `p` and `q` hash).

• Has a variable for binding to the code block, if any (`block`)

You'll rarely see method signatures of this complexity, so if you can keep track of the elements in this one, you're probably all set.

We'll look next at ranges-which aren't exactly collection objects, arguably, but which turn out to have a lot in common with collection objects. 
