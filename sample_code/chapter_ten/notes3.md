## *The map method* ##
The `map` method (also callable as `collect`) is one of the most powerful and important enumerable or collection operations available in Ruby. You've met it before (in chapter 6), but there's more to see, especially now that we're inside the overall topic of enumerability.

Whatever enumerable it starts with, `map` always returns an array. The returned array is always the same size as the original enumerable. Its elements consist of the accumulated result of calling the code block on each element in the original object in turn.

For example, here's how you map an array of names to their uppercase equivalent:

```irb
>> names = %w{ David Yukihiro Chad Amy }
=> ["David", "Yukihiro", "Chad", "Amy"]
>> names.map {|name| name.upcase }
=> ["DAVID", "YUKIHIRO", "CHAD", "AMY"]
```
The new array is the same size as the original array, and each of its elements corresponds to the element in the same position in the original array. But each element has been run through the block.

**Using a symbol argument as a block**
You can use a symbol such as `:upcase` with a `&` in front of it in method-argument position, and the result will be the same as if you used a code block that called the method with the same name as the symbol on each element. Thus you could rewrite the block in the last example, which calls `upcase` on each element, like this:

`names.map(&:upcase)`

You'll see a more in-depth explanation of this idiom later on when you read about callable objects.
-----

It may be obvious, but it's important to note that what matters about `map` is its return value.

### *The return value of map* ###
The return value of `map`, and the usefulness of that return value, is what distinguishes `map` from `each`. The return value of `each` doesn't matter. You'll almost never see this:

`result = array.each {|x| #code here... } `

Why? Because `each` returns its receiver. You might as well do this:

```irb
result = array
array.each {|x| ... }
```
On the other hand, `map` returns a new object: a mapping of the original object to a new object. So you'll often see-and do-things like this:

`result = array.map {|x| #code here... }`

The difference between `map` and `each` is a good reminder that `each` exists purely for the side effects from the execution of the block. The value returned by the block each time through is discarded. That's why `each` returns its receiver; it doesn't have anything else to return, because it hasn't saved anything, `map`, on the other hand, maintains an accumulator array of the results from the block.

This doesn't mean that `map` is better or more useful than `each`. It means they're different in some important ways. But the semantics of `map` do mean that you have to be careful about the side effects that make `each` useful.

#### BE CAREFUL WITH BLOCK EVALUATIONS ####
Have a look at this code, and see if you can predict what the array `result` will contain when the code is executed:

```irb
array = [1,2,3,4,5]
result = array.map {|n| puts n * 100 }
```
The answer is that the `result` will be this:

```irb
=> [nil, nil, nil, nil, nil]
```
Why? Because the return value of `puts` is always `nil`. That's all `map` cares about. Yes, the five values represented by `n * 100` will be printed to the screen, but that's because the code in the block gets executed. The result of the operation-the mapping itself-is all `nils` because every call to this particular block will return `nil`.

There's an in-place version of map for arrays and sets: `map!` (a.k.a. `collect!`).

### *In-place mapping with map!* ###
Consider again the `names` array:

`names = %w{ David Yukihiro Chad Amy }`

To changed the `names` array in place, run it through `map!`, the destructive version of `map`:

```irb
>> names.map!(&:upcase)   #<--- See tip, above!
=> ["DAVID", "YUKIHIRO", "CHAD", "AMY"]
```

The `map!` method `Array` is defined in `Array`, not in `Enumerable`. Because `map` operations generally return arrays, whatever the class of their receiver may be, doing an in-place mapping doesn't make sense unless the object is already an array. It would be difficult, for example, to imagine what an in-place mapping of a range would consist of. But the `Set#map!` method does an in-place mapping of a set back to itself-which makes sense, given that a set is in many respects similar to an array.

We're going to look next at a class that isn't enumerable: `String`. Strings are a bit like ranges in that they do and don't behave like collections. In the case of ranges, their collection-like properties are enough that the class warrants the mixing in of `Enumerable`. In the case of strings, `Enumerable` isn't in play; but the semantics of strings, when you treat them as iterable sequences of characters or bytes, is similar enough to enumerable semantics that we'll address it here.

## *Strings as quasi-enumerables* ##
You can iterate through the raw bytes or the characters of a string using convenient iterator methods that treat the string as a collection of bytes, characters, code points, or lines. Each of these four ways of iterating through a string has an `each`-style method associate with it. To iterate through bytes, use `each_byte`:

```irb
str = "abcde"
str.each_byte {|b| p b }
```
The output of this code is:

```irb
97
98
99
100
101
=> "abcde"
```

If you want each character, rather than its byte code, use `each_char`

```irb
>> str = "abcde"
 => "abcde"
>> str.each_char {|c| p c }
```
This time, the output is

```irb
"a"
"b"
"c"
"d"
"e"
 => "abcde"
```
Iterating by code point provides character codes (integers) at the rate of exactly one per character:

```irb
>> str = "100\u20ac"
=> "100€"
>> str.each_codepoint {|cp| p cp }
49
48
48
8364
=> "100€"
```
Compare this last example with what happens if you iterate over the same string byte by byte:

```irb
>> str.each_byte {|b| p b }
49
48
48
226
130
172
=> "100€"
```
Due to the encoding, the number of bytes is greater than the number of code points (or the number of characters, which is equal to the number of code points).

Finally, if you want to go line by line, use `each_line`

```irb
>> str = "this string\nhas three\nlines"
=> "this string\nhas three\nlines"
>> str.each_line {|l| puts "Next line: #{l}" }
Next line: this string
Next line: has three
Next line: lines
=> "this string\nhas three\nlines"
```

The string is split at the end of each line-or, more strictly speaking, at every occurrence of the current value of the global variable `$/`. If you change this variable, you're changing the delimiter for what Ruby considers the next line in a string:

```irb
>> str = "David!Alan!Black!"
=> "David!Alan!Black!"
>> $/ = "!"
=> "!"
>> str.each_line {|l| puts "Next line: #{l}" }
```
Now Ruby's concept of a "line" will be based on the `!` character:

```irb
Next line: David!
Next line: Alan!
Next line: Black!
=> "David!Alan!Black!"
```

Even though Ruby strings aren't enumerable in the technical sense (`String` doesn't include `Enumerable`), the language thus provides you with the necessary tools to traverse them as character, byte, code point, and/or line collections when you need to.

The four `each`-style methods described here operate by creating an enumerator. You'll learn more about enumerators later in the chapter. The important lesson for the moment is that you've got another set of options if you simply want an array of all bytes, characters, code points, or lines: drop the `each_` and pluralize the method name. For example, here's how you'd get an array of all the bytes in a string:

```irb
=> "Hello"
>> p string.bytes
```
The output is

```irb
[72, 101, 108, 108, 111]
=> [72, 101, 108, 108, 111]
```
You can do likewise with the methods `chars`, `codepoints`, and `lines`.

We've searched, transformed, filtered, and queried a variety of collection objects using an even bigger variety of methods. The one thing we haven't done is *sort* collections. We'll do that next. 
