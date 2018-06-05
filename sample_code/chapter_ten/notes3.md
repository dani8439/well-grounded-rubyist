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

## *Sorting enumerables* ##
If you have a class, and you want to be able to arrange multiple instances of it in order, you need to do the following:

  1. Define a comparison method for the class (`<=>`)
  2. Place the multiple instances in a container, probably an array.
  3. Sort the container.

The key point is that although the ability to sort is granted by `Enumerable`, your class doesn't have to mix in `Enumerable`. Rather, you put your objects into a container object that does mix in `Enumerable`. That container object, as an enumerable, has two sorting methods, `sort` and `sort_by`, which you can use to sort the collection.

In the vast majority of cases, the container into which you place objects you want sorted will be an array. Sometimes it will be a hash, in which case the result will be an array (an array of two-element key/value pair arrays, sorted by a key or some other criterion).

Normally, you don't have to create an array of items explicitly before you sort them. More often, you sort a collection that your program has already generated automatically. For instance, you may perform a `select` operation on a collection of objects and sort the ones you've selected. The manual stuffing of lists of objects into square brackets to create array examples in this section is therefore a bit contrived. But the goal is to focus directly on techniques for sorting, and that's what we'll do.

Here's a simple sorting example involving an array of integers:

```irb
>> [3,2,5,4,1].sort
=> [1, 2, 3, 4, 5]
```
Doing this is easy when you have numbers or even strings (where a sort gives you alphabetical order). The array you put them in has a sorting mechanism, and the integers or strings have some knowledge of what it means to be in order.

But what if you want to sort, say, an array of `Painting` objects?

`>> [pa1, pa2, pa3, pa4, pa5].sort`

For paintings to have enough knowledge to participate in a sort operation, you have to define the spaceship operator (see chapter 7): `Painting#<=>`. Each painting will then know what it means to be greater or less than another painting, and that will enable the array to sort its contents. Remember, it's the array you're sorting, not each painting; but to sort the array, its elements have to have a sense of how they compare to each other. (You don't have to mix in the `Comparable` module; you just need the spaceship method. We'll come back to `Comparable` shortly.)

Let's say you want paintings to sort in increasing order of price, and let's assume paintings have a `price` attribute. Somewhere in your `Painting` class you would do this:

```ruby
def <=>(other_painting)
  self.price <=> other_painting.price
end
```

Now an array of paintings you sort will come out in price-sorted order:

`price_sorted = [pa1, pa2, pa3, pa4, pa5].sort`

Ruby applies the `<=>` test to these elements, two at a time, building up enough information to perform the complete sort.

A more fleshed-out account of the steps involved might go like this:

  1. Teach your objects how to compare themselves with each other, using `<=>`
  2. Put those objects inside an enumerable object (probably an array).
  3. Ask that object to sort itself. It does this by asking the objects to compare themselves to each other with `<=>`

If you keep this division of labor in mind, you'll understand how sorting operates and how it relates to `Enumerable`. But what about `Comparable`?

### *Where the Comparable module fits into enumerable sorting (or doesn't)* ###
When we first encountered the spaceship operator, it was in the context of including `Comparable` and letting that module build its various methods (`>`, `<`, and so on) on top of `<=>`. But in prepping objects to be sortable inside enumerable containers, all we've done is define `<=>`; we haven't mixed in `Comparable`.

  • If you define `<=>` for a class, then instances of that class can be put inside an array or other enumerable for sorting.

  • If you don't define `<=>`, you can still sort objects if you put them inside an array and provide a code block telling the array how it should rank any two of the objects. (this is discussed in next section).

  • If you define `<=>` and also include `Comparable` in your class, then you get sortability inside an array *and* you can perform all the comparison operations between any two of your objects. (`>`, `<`, and so on), as per the discussion of `Comparable` in chapter 9.

In other words, the `<=>` method is useful both for classes whose instances you wish to sort and for classes whose instances you wish to compare with each other in a more fine-grained way using the full complement of comparison operators.

Back we got to enumerable sorting-and, in particular, to the variant of sorting where you provide a code block instead of a `<=>` method to specify how objects should be compared and ordered.

### *Defining sort-order logic with a block* ###
In cases where no `<=>` method is defined for these objects, you can supply a block on-the-fly to indicate how you want your objects sorted. If there's a `<=>` method, you can override it for the current sort operation by providing a block.

Let's say, for example, that you've defined `Painting#<=>` in such a way that it sorts by price, as earlier. But now you want to sort by year. You can force a year-based sort by using a block:

```ruby
year_sort = [pa1, pa2, pa3, pa4, pa5].sort do |a,b|
  a.year <=> b.year
end
```

The block takes two arguments, `a` and `b`. This enables Ruby to use the block as many times as needed to compare one painting with another. The code inside the block does a `<=>` comparison between the respective years of the two paintings. For this call to `sort`, the code in the block is used instead of the code in the `<=>` method of the `Painting` class.

You can use this code-block form of `sort` to handle cases where your objects don't have a `<=>` method and therefore don't know how to compare themselves to each other. It can also come in handy when the objects being sorted are of different classes and by default don't know how to compare themselves to each other. Integers and strings, for example, can't be compared directly: an expression like `"2" <=> 4` causes a fatal error. But if you do a conversion first, you can pull it off:

```irb
>> ["2",1,5,"3",4,"6"].sort {|a,b| a.to_i <=> b.to_i }
=> [1, "2", "3", 4, 5, "6"]
```
The elements in the sorted output array are the same as those in the input array: a mixture of strings and integers. But they're ordered as they would be if they were all integers. Inside the code block, both strings and integers are normalized to integer form with `to_i`. As far as the sort engine is concerned, it's performing a sort based on a series of integer comparisons. It then applies the order it comes up with to the original array.

`sort` with a block can thus help you where the existing comparison methods won't get the job done. And there's an even more concise way to sort a collection with a code block: the `sort_by` method.

### *Concise sorting with sort_by* ### 
Like `sort`, `sort_by` is an instance method of `Enumerable`. The main difference is that `sort_by` always takes a block, and it only requires that you show it how to treat one item in the collection. `sort_by` figures out that you want to do the same thing to both items every time it compares a pair of objects.

The previous array sorting example can be written like this, using `sort_by`:

```irb 
>> ["2",1,5,"3",4,"6"].sort_by {|a| a.to_i }        #<--- or sort_by(&:to_i)
=> [1, "2", "3", 4, 5, "6"]
```
All we have to do in the block is show (once) what action needs to be performed to prep each object for the sort operation. We don't have to call `to_i` on two objects; nor do we need to use the `<=>` method explicitly.

In addition to the `Enumerable` module, and still in the realm of enumerability, Ruby provides a class called `Enumerator`. Enumerators add a whole dimension of collection manipulation power to Ruby. We'll look at them in depth now. 



