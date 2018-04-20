### EVALUATING THE PROS AND CONS OF CLASS VARIABLES ###
The bread-and-butter way to maintain state in an object is the instance variable. Class variables come in handy because they break down the dam between a class object and instances of that class. But by so doing, and especially because of their hierarchy-based scope, they take on a kind of quasi-global quality: a class variable isn't global, but it sure is visible to a lot of objects, once you add up all the subclasses and all the instances of those subclasses.

The issue at hand is that it's useful to have a way to maintain state in a class. You saw this even in the simple `Car` class example. We wanted somewhere to stash class-relevant information, like the makes of cars and the total number of cars manufactured. We also wanted to get at that information, both from class methods and from instance methods. Class variables are popular because they're the easiest way to distribute data in that configuration.

But they're also leaky. Too many objects can get hold of them. Let's say we wanted to create a subclass of `Car` called `Hybrid` to keep a count of manufactured (partly) electric vehicles. We couldn't do this:

```ruby
class Hybrid < Car
end
hy = Hybrid.new("Honda")
puts "There are #{Hybrid.total_count} hybrids in existence!"
```
because `Hybrid.total_count` is the asme method as `Car.total_count`, and it wraps the same variable. Class variables aren't reissued freshly for every subclass, the way instance variables are for every object.

To track hybrids separately, we'd have to do something like this:

```ruby
class Hybrid < Car
  @@total_hybrid_count = 0
  # etc
end
```

Although there are ways to abstract and semi-automate this kind of splitting out of code by class namespace, it's not the easiest or most transparent technique in the world.

What's the alternative?

### MAINTAINING PER-CLASS STATE WITH INSTANCE VARIABLES OF CLASS OBJECTS ###
The alternative is to go back to basics. We need a slot where we can put a value (the total count), and it should be a different slot for every class. In other words, we need to maintain state on a per-class basis; and because classes are objects, that means on a per-object basis (for a certain group of objects, namely, class objects). And per-object state, whether the object in question is a class or something else, suggests instance variables.

The following shows a rewrite of the `Car` class from earlier. Two of the class variables are still there, but `@@total_count` has been transformed into an instance variable:


```ruby
class Car
  @@makes = []
  @@cars = {}
  attr_reader :make
  def self.total_count
    @total_count ||= 0                    #1.
  end
  def self.total_count=(n)
    @total_count = n                      #2.
  end
  def self.add_make(make)
    unless @@makes.include?(make)
      @@makes << make
      @@cars[make] = 0
    end
  end
  def initialize(make)
    if @@makes.include?(make)
      puts "Creating a new #{make}!"
      @make = make
      @@cars[make] += 1
      self.class.total_count += 1         #3.
    else      
      raise "No such make: #{make}."
    end
  end
  def make_mates
    @@cars[self.make]
  end
end
```

The key here is storing the counter in an instance variable belonging to the class object `Car`, and wrapping that instance variable in accessor methods-manually written ones, but accessor methods nonetheless. The accessor methods are `Car.total_count` and `Car.total_count=`. The first of these performs the task of initializing `@total_count` to zero (#1). It does the initialization conditionally, using the or-equals operator, so that on the second and subsequent calls to `total_count`, the value of the instance variable is simply returns.

The `total_count=` method is an attribute-writer method, likewise written as a class method so that the object whose instance variable is in use is the class object(#2). With these methods in place, we can now increment the total count from inside the instance method `initialize` by calling `self.class.total_count=`(#3).

The payoff comes when we subclass `Car`. Let's have another look at `Hybrid` and some sample code that uses it:

```ruby
class Hybrid < Car
end
h3 = Hybrid.new("Honda")
f2 = Hybrid.new("Ford")
puts "There are #{Hybrid.total_count} hybrids on the road!"   #<-- Output: There are 2 hybrids on the road!
```

`Hybrid` is the new class object. It isn't the same object as `Car`. Therefore, it has its own instance variables. When we create a new `Hybrid` instance, the `initialize` method from `Car` is executed. But this time, the expression

`self.class.total_count += 1`

has a different meaning. The receiver of the "total_count=" message is `Hybrid`, not `Car`. That means when the `total_count=` class method is executed, the instance variable `@total_count` belongs to `Hybrid`. (Instance variables always belong to self.) Adding to `Hybrid`'s total count therefore won't affect `Car`'s total count. 

We've made it so that a subclass of `Car`
