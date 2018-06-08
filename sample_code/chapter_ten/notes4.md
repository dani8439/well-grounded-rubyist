# *Enumerators and the next dimension of enumerability* #
Enumerators are closely related to iterators, but they aren't the same thing. An iterator is a method that yields one or more values to a code block. An enumerator is an *object*, not a method.

At heart, an enumerator is a simple enumerable object. It has an `each` method, and it employs the `Enumerable` module to define all the usual methods-`select`, `inject`, `map`, and friends-directly on top of `each`.

The twist in the plot, though, is how the enumerator's `each` method is engineered.

An enumerator isn't a container object. It has no "natural" basis for an `each` operation, the way an array does (start at element 0; yield it; go to element 1; yield it; and so on). The `each` iteration logic of every enumerator has to be explicitly specified. After you've told it how to do `each`, the enumerator takes over from there and figures out how to do `map`, `find`, `take`, `drop`, and all the rest.

An enumerator is like a brain in a science-fiction movie, sitting on a table with no connection to a body but still able to think. It just needs an "each" algorithm, so that it can set into motion the things it already knows how to do. And this it can learn in one of two ways: either you call `Enumerator.new` with a code block, so that the code block contains the `each` logic you want the enumerator to follow; or you create an enumerator based on an existing enumerable object (an array, a hash, and so forth) in such a way that the enumerator's `each` method draws its elements, for iteration, from a specific method of that enumerable object.

We'll start by looking at the code block approach to creating enumerators. But most of the rest of the discussion of enumerators will focus on the second approach, where you "hook up" an enumerator to an iterator on another object. Which techniques you use and how you combine them will ultimately depend on your exact needs in a given situation.

### *Creating enumerators with a code block* ###
Here's a simple example of the instantiation of an enumerator with a code block:

```ruby
e = Enumerator.new do |y|
  y << 1
  y << 2
  y << 3
end
```
Now, first things first: what is `y`?

`y` is a *yielder*, an instance of `Enumerator::Yielder`, automatically passed to your block. Yielders encapsulate the yielding scenario that you want your enumerator to follow. In this example, what we're saying is *when you (the enumerator) get an `each` call, please take that to mean that you should yield 1, and then 2, and then 3.* The `<<` method (in infix operator position, as usual) serves to instruct the yielder as to what it should yield. (You can also write `y.yield(1)` and so forth, although the similarity of the `yield` method to the `yield` keyword might be more confusing than it's worth.) Upon being asked to iterate, the enumerator consults the yielder and makes the next move-the next yield-based on the instructions that the yielder has stored.

What happens when you use `e` the enumerator? Here's an irb session where it's put through its paces (given that the code in the example has already been executed):

```irb
>> e.to_a                   #<-- Array representation of yielded elements
=> [1, 2, 3]
>> e.map {|x| x * 10 }      #<-- Mapping, based on each
=> [10, 20, 30]
>> e.select {|x| x > 1 }    #<-- Selection, based on each
=> [2, 3]
>> e.take(2)                #<-- Take first two elements yielded
=> [1, 2]
```
The enumerator `e` is an enumerating machine. It doesn't contain objects; it has code associated with it-the original code block-that tells it what to do when it's addressed in terms that it recognizes as coming from the `Enumerable` module.

The enumerator iterates once for every time that `<<` (or the `yield` method) is called on the yielder. If you put calls to `<<` inside a loop or other iterator inside the code block, you can introduce just about any iteration logic you want. Here's a rewrite of the previous example, using an iterator inside the block:

```ruby
e = Enumerator.new do |y|
  (1..3).each {|i| y << i }
end
```
The behavior of `e` will be the same, given this definition, as it is in the previous examples. We've arranged for `<<` to be called three times; that means `e.each` will do three iterations. Again, the behavior of the enumerator can be traced ultimately to the calls to `<<` inside the code block with which it was initialized.

Note in particular that you don't yield from the block: that is, you *don't* do this:

```ruby
e = Enumerator.new do       #<---WRONG!
  yield 1               #| This is what you don't do!
  yield 2               #| This is what you don't do!
  yield 3               #| This is what you don't do!
end
```
Rather, you populate your yielder (`y`, in the first examples) with specifications for how you want the iteration to proceed at such time as you call an iterative method on the enumerator.

Every time you call an iterator method on the enumerator, the code block gets executed once. Any variables you initialize in the block are initialized once at the start of each such method call. You can trace the execution sequence by adding some verbosity and calling multiple methods:

```ruby
e = Enumerator.new do |y|
  puts "Starting up the block!"
  (1..3).each {|i| y << i }
  puts "Exiting the block!"
end
p e.to_a
p e.select {|x| x > 2 }
```
The output from this code is:

```irb
Starting up the block!      #<---- Call to to_a
Exiting the block!
[1, 2, 3]
=> [1, 2, 3]
Starting up the block!          #<--- call to select
Exiting the block!
[3]
=> [3]
```
You can see that the block is executed once for each iterator called on `e`.

It's also possible to involve other objects in the code block for an enumerator. Here's a somewhat abstract example in which the enumerator performs a calculation involving the elements of an array while removing those elements from the array permanently:

```ruby
a = [1,2,3,4,5]
e = Enumerator.new do |y|
  total = 0
  until a.empty?
    total += a.pop
    y << total
  end
end
```
Now let's look at the fate of poor `a` in irb:

```irb
>> e.take(2)
=> [5, 9]
>> a
=> [1, 2, 3]
>> e.to_a
=> [3, 5, 6]
>> a
=> []
```
The `take` operation produces a result array of two elements (the value of `total` for two successive iterations) and leaves `a` with three elements. Calling `to_a` on `e`, at this point, causes the original code block to be executed again, because the `to_a` call isn't part of the same iteration as the call to `take`. Therefore, `total` starts again at 0, and the `until` loop is executed with the result that three values are yielded and `a` is left empty.

It's not fair to ambush a separate object by removing its elements as a side effect of calling an enumerator. But the example shows you the mechanism-and it also provides a reasonable segue into the other half of the topic of creating enumerators: creating enumerators whose `each` methods are tired to specific methods on existing enumerable objects.

### *Attaching enumerators to other objects* ###
The other way to endow an enumerator with `each` logic is to hook the enumerator up to another object-specifically, to an iterator (often `each`, but potentially any method that yields one or more values) on another object. This gives the enumerator a basis for its own iteration: when it needs to yield something, it gets the necessary value by triggering the next yield from the object to which it is attached, via the designated method. The enumerator thus acts as part proxy, part parasite, defining its own `each` in terms of another object's iteration.

You create an enumerator with this approach by calling `enum_for` (a.k.a. `to_enum`) on the object from which you want the enumerator to draw its iterations. You provide as the first argument the name of the method onto which the enumerator will attach its `each` method. The argument defaults to `:each`, although it's common to attach the enumerator to a different method, as in this example:

```irb
>> names = %w{ David Black Yukihiro Matsumoto }
=> ["David", "Black", "Yukihiro", "Matsumoto"]
>> e = names.enum_for(:select)
=> #<Enumerator: ["David", "Black", "Yukihiro", "Matsumoto"]:select>
```
Specifying `:select` as the argument means that we want to bind this enumerator to the `select` method of the `names` array. That means the enumerator's `each` will serve as a kind of front end to array's `select`:

`e.each {|n| n.include?('a')}`   <---- Output: ["David", "Black", "Matsumoto"]

You can also provide further arguments to `enum_for`. Any such arguments are passed through to the method to which the enumerator is being attached. For example, here's how to create an enumerator for `inject` so that when `inject` is called on to feed values to the enumerator's `each`, it's called with a starting value of `"Names: "`:

```irb
>> e = names.enum_for(:inject, "Names: ")
=> #<Enumerator: ["David", "Black", "Yukihiro", "Matsumoto"]:inject("Names: ")>
>> e.each {|string, name| string << "#{name}..." }
=> "Names: David...Black...Yukihiro...Matsumoto..."
```
But be careful! That starting string `"Names: "` has had some names added to it, but it's still alive inside the enumerator. That means if you run the same inject operation again, it adds to the same string (the line in the output in the following code is broken across two lines to make it fit):

```irb 
>> e.each {|string, name| string << "#{name}..." }
=> "Names: David...Black...Yukihiro...Matsumoto...David...Black...Yukihiro...Matsumoto..."
```

When you create the enumerator, the arguments you give it for the purpose of supplying its proxied method with arguments are the arguments-the objects-it will use permanently. So watch for side effects. (In this particular case, you can avoid the side effect by adding strings-`string + "#{name}..."`-instead of appending to the string with `<<` because the addition operation creates a new string object. Still, the cautionary tale is generally useful.)

**Note** You can call `Enumerator.new(obj, method_name, arg1, arg2...)` as an equivalent to `obj.enum_for(method_name, arg1, arg2...)`. But using this form of `Enumerator.new` is discouraged. Use `enum_for` for the method attachment scenario and `Enumerator.new` for the block-based scenario described in previous section.

Now you know how to create enumerators of both kinds: the kind whose knowledge of how to iterate is conveyed to it in a code block, and the kind that gets the knowledge from another object. Enumerators are also created implicitly when you make blockless calls to certain iterator methods. 

### *Implicit creation of enumerators by blockless iterator calls* ###
By definition, an iterator is a method that yields one or more values to a block. But what if there's no block?

The answer is that most built-in iterators return an enumerator when they're called without a block. Here's an example from the `String` class: the `each_byte` method (see earlier section). First, here's a classic iterator usage of the method, without an enumerator but with a block:

```irb
>> str = "Hello"
=> "Hello"
>> str.each_byte {|b| puts b }
72
101
108
108
111
=> "Hello"
```
`each_byte` iterates over the bytes in the string and returns its receiver (the string). But if you call `each_byte` with no block, you get an enumerator:

```irb
>> str.each_byte
=> #<Enumerator: "Hello":each_byte>
```
The enumerator you get is equivalent to what you would get if you did this:

```irb
>> str.enum_for(:each_byte)
=> #<Enumerator: "Hello":each_byte>
```
You'll find that lots of methods from `Enumerable` return enumerators when you call then without a block (including `each`, `map`, `select`, and `inject`, and others.) The main use case for these automatically returned enumerators is *chaining*: calling another method immediately on the enumerator. We'll look at chaining as part of the coverage of enumerator semantics in the next section.

