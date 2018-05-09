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

Not every class of objects needs, or should have, all these methods. (It's hard to imagine what it would mean for one `Bicycle` to be greater than or equal to another. Gears?) But for classes that do need full comparison functionality, Ruby provides a convenient way to get it. If you want objects of class `MyClass` to have the full suite of comparison methods, all you have to do is the following:

1. Mix a module called `Comparable` (which comes with Ruby) into `MyClass`.

2. Define a comparison method with the name `<=>` as an instance method in `MyClass`.

The comparison method `<=>` (usually called the *spaceship operator* or *spaceship method*) is the heart of the matter. Inside this method, you redefine what you mean be *less than*, *equal to*, and *greater than*. Once you've done that, Ruby has all it needs to provide the corresponding comparison methods.

For example, let's say you're taking bids on a job and using a Ruby script to help you keep track of what bids have come in. You decide it would be handy to be able to compare any two `Bid` objects, based on an `estimate` attribute, using simple comparison operators like `>` and `<`. *Greater than* means asking for more money, and *less than* means asking for less money.

A simple first version of the `Bid` class might look like this:

```ruby
class Bid
  include Comparable
  attr_accessor :estimate    
  def <=>(other_bid)                               
    if self.estimate < other_bid.estimate
      -1
    elsif self.estimate > other_bid.estimate
      1
    else
      0
    end
  end
end
```
The spaceship method (in `def <=>(other_bid)`) consists of a cascading `if/elsif/else` statement. Depending on which branch is executed, the method returns a negative number (by convention `-1`), a positive number (by convention `1`), or `0`. Those three return values are predefined, prearranged signals to Ruby. Your `<=>` method must return one of those three values every time it's called-and they always mean less than, equal to, and greater than, respectively.

You can shorten this method. Bid estimates are either floating-point numbers or integers (the latter, if you don't bother with the cents part of the figure or if you store the amounts as cents rather than dollars). Numbers already know how to compare themselves to each other, including integers to floats. `Bid`'s `<=>` method can therefore piggyback on the existing `<=>` methods of the `Integer` and `Float` classes, like this:

```ruby
def <=>(other_bid)
    self.estimate <=> other_bid.estimate
end
```
In this version of the spaceship method, we're punting; we're saying that if you want to know how two bids compare to each other, bump the question to the estimate values for the two bids and use that comparison  as the basis for the bid-to-bid comparison.

The payoff for defining the spaceship operator and including `Comparable` is that you can from then on use the whole set of comparison methods on pairs of your objects. In this example, `bid1` wins the contract; it's less than (as determined by `<`) `bid2`:

```irb
>> bid1 = Bid.new
=> #<Bid:0x00000000d3ca48>
>> bid2 = Bid.new
=> #<Bid:0x00000000d47ce0>
>> bid1.estimate = 100
=> 100
>> bid2.estimate = 105
=> 105
>> bid1 < bid2
=> true
```
The `<` method (along with `>`, `>=`, `<=`, `==`, `!=`, and `between?`) is defined in terms of `<=>`, inside the `Comparable` module. (`b.between?(a,c)` tells you whether *b > a* and *b < c*.)

All Ruby numerical classes include `Comparable` and have a definition for `<=>`. The same is true of the `String` class; you can compare strings using the full assortment of `Comparable` method/operators. `Comparable` is a handy tool, giving you a lot of functionality in return for, essentially, one method definition.

## *Inspecting object capabilities* ##
