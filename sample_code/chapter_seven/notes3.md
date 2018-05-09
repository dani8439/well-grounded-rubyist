## *Comparing two objects* ##
Ruby objects are created with the capacity to compare themselves to other objects for equality and/or order, using any of several methods. Tests for equality are the most common comparison tests.

### *Equality tests* ###
Inside the `Object` class, all equality-test methods do the same thing; they tell you whether two objects are exactly the same object. Here they are in action:

```irb
>> a = Object.new
=> #<Object:0x00000000db6e88>
>> b = Object.new
=> #<Object:0x00000000db4868>
>> a == a
=> true
>> a == b
=> false
>> a != b
=> true
>> a.eql?(b)
=> false
>> a.equal?(a)
=> true
>> a.equal?(b)
=> false
```
All three of the positive equality-test methods (`==`, `eql?`, and `equal?`) give the same results in these examples: when you test `a` against `a`, the result is true, and when you test `a` against `b`, the result is false. (The not-equal or negative equality test method `!=` is the inverse of the `==` method; in fact, if you define `==`, your objects will automatically have the `!=` method.) We have plenty of ways to establish that `a` is `a` but not `b`.

But there isn't much point in having three tests that do the same thing. Further down the road, in classes other than `Object`, `==` and/or `eql?` are typically redefined to do meaningful work for different objects. The `equal?` method is usually left alone so that you can always use it to check whether two objects are exactly the same object.

Here's an example involving strings. Note that they are `==` and `eql?`, but not `equal?`:

```irb
>> string1 = "text"
=> "text"
>> string2 = "text"
=> "text"
>> string1 == string2
=> true
>> string1.eql?(string2)
=> true
>> string1.equal?(string2)
=> false
```
Furthermore, Ruby gives you a suite of tools for object comparisons, and not always just comparison for equality. We'll look next at how equality tests and their redefinitions fit into the overall comparison picture.

### *Comparisons and the Comparable module* ###
The most commonly redefined equality-test method, and the one you'll see used most often, is `==`. It's part of the larger family of equality-test methods, and it's also part of a family of comparison methods that includes `==`, `!=`, `>`, `<`, `>=`, and `<=`.
