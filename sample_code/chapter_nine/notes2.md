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
