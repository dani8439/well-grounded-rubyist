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

# *Enumerator semantics and uses* #
Now that you know how enumerators are wired and how to create them, we're going to look at how they're used-and why they're used.

Perhaps the hardest thing about enumerators, because it's the most difficult to interpret visually, is how things play out when you call the `each` method. We'll start by looking at that; then, we'll examine the practicalities of enumerators, particularly the ways in which an enumerator can protect an object from change and how you can use an enumerator to do fine-grained, controlled iterations. We'll look then at how enumerators fit into method chains in general and we'll see a couple of important specific cases.

### *How to use an enumerator's each method* ###
An enumerator's `each` method is hooked up to a method on another object, possibly a method other than `each`. If you use it directly, it behaves like that other method, including with respect to its return value.

This can produce some odd-looking results where calls to `each` return filtered, sorted, or mapped collections:

```irb
>> array = %w{ cat dog rabbit }
=> ["cat", "dog", "rabbit"]
>> e = array.map
=> #<Enumerator: ["cat", "dog", "rabbit"]:map>
>> e.each {|animal| animal.capitalize }
=> ["Cat", "Dog", "Rabbit"]       #<--- Returns mapping
```
There's nothing mysterious here. The enumerator isn't the same object as the array; it has its own ideas about what `each` means. Still, the overall effect of connecting an enumerator to the `map` method of an array is that you get an `each` operation with an array mapping as its return value. The usual `each` iteration of an array, as you've seen, exists principally for its side effects and returns its receiver (the array). But an enumerator's `each` serves as a kind of conduit to the method from which it pulls its values and behaves the same way in the matter of return value.

Another characteristic of enumerators that you should be aware of is the fact that they perform a kind of *un-overriding* of methods in `Enumerable`.

#### THE UN-OVERRIDING PHENOMENON ####
If a class defined `each` and includes `Enumerable`, its instances automatically get `map`, `select`, `inject`, and all the rest of `Enumerable`'s methods. All those methods are defined in terms of `each`.

But sometimes a given class has already overridden `Enumerable`'s version of a method with its own. A good example is `Hash#select`. The standard, out-of-the-box `select` method from `Enumerable` always returns an array, whatever the class of the object using it might be. A `select` operation on a hash, on the other hand, returns a hash:

```irb
>> h = { "cat" => "feline", "dog" => "canine", "cow" => "bovine" }
=> {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}
>> h.select {|key,value| key =~/c/ }
=> {"cat"=>"feline", "cow"=>"bovine"}
```
So far, so good (and nothing new). And if we hook up an enumerator to the `select` method, it gives us an `each` method that works like that method:

```irb
>> e = h.enum_for(:select)
=> #<Enumerator: {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}:select>
>> e.each {|key,value| key =~/c/ }
=> {"cat"=>"feline", "cow"=>"bovine"}
```

But what about an enumerator hooked up not to the hash's `select` method but to the hash's `each` method? We can get one by using `to_enum` and letting the target method default to `each`:

```irb
>> e = h.to_enum
=> #<Enumerator: {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}:each>
```

`Hash#each`, called with a block, returns the hash. The same is true of the enumerator's `each`-because it's just a front end to the hash's `each`. The blocks in these examples are empty because we're only concerned with the return values:

```irb
>> h.each { }
=> {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}
>> e.each { }
=> {"cat"=>"feline", "dog"=>"canine", "cow"=>"bovine"}
```

So far, it looks like the enumerator's `each` is a stand-in for the hash's `each`. But what happens if we use this `each` to perform a select operation?

```irb
>> e.select {|key,value| key =~ /c/ }
=> [["cat", "feline"], ["cow", "bovine"]]
```
The answer, as you can see, is that we get back an array, not a hash.

Why? If `e.each` is pegged to `h.each`, how does the return value of `e.select` get unpegged from the return value of `h.select`?

The key is that the call to `select` in the last example is a call to the `select` method of the *enumerator*, not the hash. And the `select` method of the enumerator is built directly on the enumerator's `each` method. In fact, the enumerator's `select` method is `Enumerable#select`, which always returns an array. The fact that `Hash#select` doesn't return an array is of no interest to the enumerator.

In this sense, the enumerator is adding enumerability to the hash, even though the hash is already enumerable. It's also un-overriding `Enumerable#select`; the `select` provided by the enumerator is `Enumerable#select`, even if the hash's `select` wasn't. (Technically, it's not an un-override, but it does produce the sensation that the enumerator is occluding the select logic of the original hash).

The lesson is that it's important to remember that an enumerator is a different object from the collection from which it siphons its iterated objects. Although this difference between objects can give rise to some possibly odd results, like `select` being rerouted through the `Enumerable` module, it's definitely beneficial in at least one important way: accessing a collection through an enumerator, rather than through the collection itself, protects the collection object from change.

### *Protecting objects with enumerators* ###
Consider a method that expects, say, an array as its argument. (Yes, it's a bit un-Rubylike to focus on the object's class, but you'll see that isn't the main point here.)

`def give_me_an_array(array)`

If you pass an array object to this method, the method can alter that object:

`array << "new element"`

If you want to protect the original array from change, you can duplicate it and pass along the duplicate-or you can pass along an enumerator instead:

`give_me_an_array(array.to_enum)`

The enumerator will happily allow for iterations through the array, but it won't absorb changes. (It will respond with a fatal error if you try calling `<<` on it.) In other words, an enumerator can serve as a kind of gateway to a collection object such that it allows iteration and examination of elements but disallows destructive operations.

The deck of cards code from the earlier section provides a nice opportunity for some object protection. In that code, the `Deck` class has a reader attribute `cards`. When a deck is created, its `@cards` instance variable is initialized to an array containing all the cards. There's a vulnerability here. What if someone gets hold of the `@cards` array through the `cards` reader attribute and alters it?

```irb
deck = PlayingCard::Deck.new
deck.cards << "JOKER!!"
```
Ideally, we'd like to be able to read from the cards array but not alter it. (We could freeze it with the `freeze` method, which prevents further changes to objects, but we'll need to change the deck inside the `Deck` class when it's dealt from.) Enumerators provide a solution. Instead of a reader attribute, let's make the `cards` method return an enumerator:

```ruby
class PlayingCard
  SUITS = %w{ clubs diamonds hearts spades }
  RANKS = %w{ 2 3 4 5 6 7 8 9 10 J Q K A }
  class Deck
    def cards
      @cards.to_enum
    end
    def initialize(n=1)
      @cards = []
      SUITS.cycle(n) do |s|
        RANKS.cycle(1) do |r|
          @cards << "#{r} of #{s}"
        end
      end
    end
  end
end
```

It's still possible to pry into the `@cards` array and mess it up if you're determined. But the enumerator provides a significant amount of protection:

```ruby
deck = PlayingCard::Deck.new
deck.cards << "JOKER!!"     #<-- NoMethodError: undefined method `<<' for #<Enumerator:0x00000001dea0c0>
```
Of course, if you want the calling code to be able to address the cards as an array, returning an enumerator may be counterproductive. (And at least one other technique protects objects under circumstances like this: return `@cards.dup`.) But if it's a good fit, the protective qualities of an enumerator can be convenient.

Because enumerators are objects, they have state. Furthermore, they use their state to track their own progress so you can stop and start their iterations. We'll look now at the techniques for controlling enumerators in this way.

### *Fine-grained iteration with enumerators* ###
Enumerators maintain state: they keep track of where they are in their enumeration.

Several methods make direct use of this information. Consider this example:

```ruby
names = %w{ David Yukihiro}
e = names.to_enum
puts e.next
puts e.next
e.rewind
puts e.next
```
The output from these commands is:

```irb
David
=> nil
Yukihiro
=> nil
David
=> nil
```
The enumerator allows you to move in slow motion, so to speak, through the enumeration of the array, stopping and restarting at will. In this respect, it's like one of those editing tables where a film editor cranks the film manually. Unlike a projector, which you switch one and let it do its thing, the editing table allows you to influence the progress of the film as it proceeds.

This point also sheds light on the difference between an enumerator and an iterator. An enumerator is an object, and can therefore maintain state. It remembers where it is in the enumeration. An iterator is a method. When you call it, the call is atomic; the entire call happens, and then it's over. Thanks to code blocks, there is of course a certain useful complexity to Ruby method calls: the method can call back to the block, and decisions can be made that affect the outcome. But it's still a method. An iterator doesn't have state. An enumerator is an enumerable object.

Interestingly, you can use an enumerator on a non-enumerable object. All you need is for your object to have a method that yields something so the enumerator can adopt that method as the basis for its own `each` method. As a result, the non-enumerable object becomes, in effect, enumerable.

### *Adding enumerability with an enumerator* ###
An enumerator can add enumerability to objects that don't have it. It's a matter of wiring: if you hook up an enumerator's `each` method to any iterator, then you can use the enumerator to perform enumerable operations on the object that owns the iterator, whether that object considers itself enumerable or not.

When you hook up an enumerator to the `String#bytes` method, you're effectively adding enumerability to an object (a string) that doesn't have it, in the sense that `String` doesn't mix in `Enumerable`. You can achieve much the same effect with classes of your own. Consider the following class, which doesn't mix in `Enumerable` but does have one iterator method:

```ruby
module Music
  class Scale
    NOTES = %w{ c c# d d# e e# f f# g a a# b}
    def play
      NOTES.each {|note| yield note }
    end
  end
end
```

Given this class, it's possible to iterate through the notes of a scale:

```ruby
scale = Music::Scale.new
scale.play {|note| puts "Next note is #{note}" }
```

with the result:

```irb
Next note is c
Next note is c#
Next note is d
Next note is d#
Next note is e
```
and so forth. But the scale isn't technically an enumerable. The standard methods from `Enumerable` won't work because the class `Music::Scale` doesn't mix in `Enumerable` and doesn't define `each`:

`scale.map {|note| note.upcase }`

The result is:

`music.rb:27:in `<main>': undefined method `map' for #<Music::Scale:0x0000000169b698> (NoMethodError)
Did you mean?  tap`

Now, in practice, if you wanted scales to be fully enumerable, you'd almost certainly mix in `Enumerable` and change the name of `play` to `each`. But you can also make a scale enumerable by hooking it up to an enumerator.

Here's how to create an enumerator for the scale object, tied in to the `play` method:

`enum = scale.enum_for(:play)`  <--- Or `scale.enum(:play)`

The enumerator, `enum`, has an `each` method; that method performs the same iteration that the scale's `play` method performs. Furthermore, unlike the scale, the enumerator *is* an enumerable object; it has `map`, `select`, `inject`, and all the other standard methods from `Enumerable`. If you use the enumerator, you get enumerable operations on a fundamentally non-enumerable object:

```ruby
p enum.map {|note| note.upcase }
p enum.select {|note| note.include?('f') }
```
The first line's output is:

```irb
["C", "C#", "D", "D#", "E", "E#", "F", "F#", "G", "A", "A#", "B"]
```

and the second line's output is:

```irb
["f", "f#"]
```

An enumerator, then, attaches itself to a particular method on a particular object and uses that method as the foundation method-the `each`-for the entire enumerable toolset.

Attaching an enumerator to a non-enumerable object like the scale object is a good exercise because it illustrates the difference between the original object and the enumerator so sharply. But in the vast majority of cases, the objects for which enumerators are created are themselves enumerables: arrays, hashes, and so forth. Most of the examples in what follows will involve enumerable objects (the exception being strings). In addition to taking us into the realm of the most common practices, this will allow us to look more broadly at the possible advantages of using enumerators.

Throughout, keep in mind the lesson of the `Music::Scale` object and its enumerator: an enumerator is an enumerable object whose `each` method operates as a kind of siphon, pulling values from an iterator defined on a different object.

We'll conclude our examination of enumerators with a look at techniques that involve chaining enumerators and method calls.


