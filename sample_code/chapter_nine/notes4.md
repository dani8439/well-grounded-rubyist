# *Ranges* #
A *range* is an object with a start point and an end point. The semantics of range operations involve two major concepts:

• *Inclusion*-Does a given value fall inside the range?

• *Enumeration*-The range is treated as a traversable collection of individual items.

The logic of inclusion applies to all ranges; you can always test for inclusion. The logic of enumeration kicks in only with certain ranges-namely, those that include a finite number of discrete, identifiable values. You can't iterate over a range that lies between two floating-point numbers, because the range encompasses an infinite number of values. But you can iterate over a range between two integers.

### *Creating a range* ###
You can create range objects with `Range.new`. If you do so in irb, you're rewarded with a view of the syntax for literal range construction:

```irb
>> r = Range.new(1,100)
=> 1..100
```

The literal syntax can, of course, also be used directly to create a range:

```irb
>> r = 1..100
=> 1..100
```
When you see a range with two dots between the start-point and end-point values, as in the previous example, you're seeing an *inclusive* range. A range with three dots in the middle is an *exclusive* range:

```irb
>> r = 1...100
=> 1...100
```
The difference lies in whether the end point is considered to lie inside the range. Coming full circle, you can also specify inclusion or exclusive behavior when you create a range with `Range.new`: the default is an inclusive range, but you can force an exclusive range by passing a third argument of `true` to the constructor:

```irb
>> Range.new(1,100)
=> 1..100
>> Range.new(1,100,true)
=> 1...100
```
Unfortunately, there's no way to remember which behavior is the default and which is triggered by the `true` argument, except to memorize it.

Also notoriously hard to remember is which number of dots goes with which type of range.

#### REMEMBERING .. VS ... ####
If you follow Ruby discussion forums, you'll periodically see messages and posts from people who find it difficult to remember which is which: two versus three dots, inclusive verses exclusive range.

One way to remember is think of a range as always reaching to the point represented by whatever follows the second dot. In an inclusive range, the point after the second dot is the end value of the range. In this example, the value `100` included in the range:

`1..100`

But in this exclusive range, the value `100` lies beyond the effective end of the range:

`1...100`

In other words, you can think of `100` as having been "pushed" to the right in such a way that it now sits outside the range.

We'll turn now to range-inclusion logic-a section that closely corresponds to the "query" sections from the discussions of strings, arrays, and hashes, because most of what you do with ranges involves querying them on criteria of inclusion.

### *Range-inclusion logic* ###
Ranges have `begin` and `end` methods, which report back their starting and ending points:

```irb
>> r = 1..10
=> 1..10
>> r.begin
=> 1
>> r.end
=> 10
```

A range also knows whether it's an exclusive (three-dot) range:

```irb
>> r.exclude_end?
=> false
```
With the goal posts in place, you can start to test for inclusion.

Two methods are available for testing inclusion of a value in a range: `cover?` and `include?` (which is also aliased as `member?`)
