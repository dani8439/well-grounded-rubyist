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

We've made it so that a subclass of `Car` can maintain its own state, because we've shifted from a class variable to an instance variable. Every time `total_count` or `total_count=` is called, the `@total_count` to which it refers is the one belonging to self at that point in execution. Once again, we're back in business using instance variables to maintain state per object (class objects, in this case).

The biggest obstacle to understanding these examples is understanding the fact that classes are objects-and that every object, whether it's a car, a person, *or a class*, gets to have its own stash of instance variables. `Car` and `Hybrid` can keep track of manufacturing numbers separately, thanks to the way instance variables are quarantined per object.

We've reached the limit of our identifier scope journey. We've seen much of what variables and constants can do (and what they can't do) and how these abilities are pegged to the rules governing scope and self. In the interest of fulfilling the chapter's goal of showing us how to orient ourselves regarding who gets to do what, and where, in Ruby code, we'll look at one more major subtopic: Ruby's system of method-access rules.

## *Deploying method-access rules* ##
As we've seen, the main business of a Ruby program is to send messages to objects. And the main business of an object is to respond to messages. Sometimes an object wants to be able to send itself messages that it doesn't want anyone else to be able to send it. For this scenario, Ruby provides the ability to make a method private.

There are two access levels other than private: protected, which is a slight variation on private, and public. Public is the default access level; if you don't specify that a method is protected or private, it's public. Public instance methods are the common currency of Ruby programming. Most of the messages you send to objects are calling public methods.

We'll focus here on methods that aren't public, starting with private methods.

### *Private methods* ###
Think of an object as someone you ask to perform a task for you. Let's say you ask someone to bake you a cake. In the course of baking you a cake, the baker will presumably perform a lot of small tasks: measure sugar, crack an egg, stir batter, and so forth.

The baker does all these things, but not all of them have equal status when it comes to what the baker is willing to do in response to requests from other people. It would be weird if you called a baker and said, "Please stir some batter" or "Please crack an egg." What you say is "Please bake me a cake", and you let the baker deal with the details.

Let's model the baking scenario. We'll use minimal, placeholder classes for some of the objects in our domain, but we'll develop the `Baker` class in more detail.

```ruby
class Cake
  def initialize(batter)
    @batter = batter
    @baked = true
  end
end
class Egg
end
class Flour
end
class Baker
  def bake_cake
    @batter = []   #<---- Implements @batter as array of objects (ingredients)
    pour_flour
    add_egg
    stir_batter
    return Cake.new(@batter)      #<---- Returns new Cake object
  end
  def pour_flour
    @batter.push(Flour.new)       #<---- Adds element (ingredient) to @batter
  end
  def add_egg
    @batter.push(Egg.new)
  end
  def stir_batter
  end
  private :pour_flour, :add_egg, :stir_batter     #1.
end
```

There's something new in this code: the `private` method(#1), which takes as arguments a list of the methods you want to make private. (If you don't supply any arguments, the call to `private` acts like an on switch: all the instance methods you define below it, until you reverse the effect by calling `public` or `protected`, will be private.)

Private means that the method can't be called with an explicit receiver,. You can't say

```ruby
b = Baker.new
b.add_egg
```

As you'll see if you try it, calling `add_egg` this way results in a fatal error:

`baker.rb:31:in `<main>': private method `add_egg' called for #<Baker:0x00000000867360> (NoMethodError)`

`add_egg` is a private method, but you've specified the receiving object, `b`, explicitly. That's not allowed.

Okay; let's go along with the rules. We won't specify a receiver. We'll just say

`add_egg`

But wait. Can we call `add_egg` in isolation? Where will the message go? How can a method be called if there's no object handling the message?

A little detective work will answer this question.

If you don't use an explicit receiver for a method call, Ruby assumes that you want to send the message to the current object, self. Thinking logically, you can conclude that the message `add_egg` has an object to go to only if self is an object that responds to `add_egg`, In other words, you can only call the `add_egg` instance method of `Baker` when self is an instance of `Baker`.

And when is self an instance of `Baker`?

When any instance method of `Baker` is being executed. Inside the definition of `bake_cake`, for example, you can call `add_egg`, and Ruby will know what to do. Whenever Ruby hits that call to `add_egg` inside that method definition, it sends the message `add_egg` to self, and self is a `Baker` object.

### **Private and singleton are different** ###
It's important to note the difference between a private method and a singleton method. A singleton method is "private" in the loose, informal sense that it belongs to only one objet, but it isn't private in the technical sense. (You can make a singleton method private, but by default it isn't.) A private, non-singleton instance method, on the other hand, may be shared by any number of objects but can only be called under the right circumstances. What determines whether you can call a private method isn't the object you're sending the message to, but which object is self at the time you send the message.

---

It comes down to this: by tagging `add_egg` as private, you're saying the `Baker` object gets to send this message to itself (the baker can tell himself or herself to add an egg to the batter), but no one else can send the message to the baker (you, as an outsider, can't tell the baker to add an egg to the batter). Ruby enforces this privacy through the mechanism of forbidding an explicit receiver. And the only circumstances under which you can omit the receiver are precisely the circumstances in which it's okay to call a private method.

It's all elegantly engineered. There's one small fly in the ointment, though.

#### PRIVATE SETTER(=) METHODS ####
The implementation of private access through the "no explicit receiver" rule runs into a hitch when it comes to methods that end with equal signs. As you'll recall, when you call a setter method, you have to specify the receiver. You can't do this

`dog_years = age * 7`

because Ruby will think that `dog_years` is a local variable. You have to do this:

`self.dog_years = age * 7`

But the need for an explicit receiver makes it hard to declare the method `dog_years=` private, at least by the logic of the "no explicit receiver" requirements for calling private methods.

The way out of this conundrum is that Ruby doesn't apply the rule to setter methods. If you declare `dog_years=` private, you can call it with a receiver-as long as the receiver is `self`. It can't be another reference to self; it has to be the keyword `self`.

Here's an implementation of a dog-years-aware `Dog`:

```ruby
class Dog
  attr_reader :age, :dog_years
  def dog_years=(years)
    @dog_years = years
  end
  def age=(years)
    @age = years
    self.dog_years = years * 7
  end
  private :dog_years=
end
```

You indicate how old a dog is, and the dog automatically knows its age in dog years:

```ruby
rover = Dog.new
rover.age = 10
puts "Rover is #{rover.dog_years} in dog years."   #<--- Output: Rover is 70 in dog years.
```

The setter method `age=` performs the service of setting the dog years, which it does by calling the private method `dog_years=`. In doing so, it uses the explicit receiver `self`. If you do it any other way, it won't work. With no receiver, you'd be setting a local variable. And if you use the same object, but under a different name, like this

```ruby
def age=(years)
  @age = years
  dog = self
  dog.dog_years = years * 7
end
```
execution is halted by a fatal error:

```irb
dog.rb:9:in `age=': private method `dog_years=' called for #<Dog:0x000000026882b8 @age=10> (NoMethodError)
Did you mean?  dog_years
        from dog.rb:15:in `<main>'
```

Ruby's policy is that it's okay to use an explicit receiver for private setter methods, but you have to thread the needle by making sure the receiver is exactly `self`.

This third method-access level, along with public and private, is protected.

### *Protected methods* ###
A protected method is like a slightly kinder, gentler private method. The rule for protected methods is as follows: you can call a protected method on an object `x`, as long as the default object (self) is an instance of the same class as `x` or of an ancestor or descendant class of `x`'s class.

This rule sounds convoluted. But it's generally used for a particular reason: you want one instance of a certain class to do something with another instance of its class. The following listing shows such a case:

```ruby
class C
  def initialize(n)
    @n = n
  end
  def n
    @n
  end
  def compare(c)
    if c.n > n
      puts "The other object's n is bigger."
    else
      puts "The other object's n is the same or smaller."
    end
  end
  protected :n
end
c1 = C.new(100)
c2 = C.new(101)
c1.compare(c2)     #<--- Output: The other object's n is bigger
```

The goal in this listing is to compare one `C` with another `C` instance. The comparison depends on the result of a call to the method `n`. The object doing the comparing (`c1`, in the example) has to ask the other object (`c2`) to execute its `n` method. Therefore, `n` can't be private.

That's where the protected level comes in. With `n` protected rather than private, `c1` can ask `c2` to execute `n`, because `c1` and `c2` are both instances of the same class. But if you try to call the `n` method of a `C` object when self is anything other than an instance of `C` (or of one of `C`'s ancestors or descendants), the method fails.

A protected method is thus like a private method, but with an exemption for cases where the class of self (`c1`) and the class of the object having the method called on it (`c2`) are the same or related by inheritance.

### **Inheritance and method access** ###
Subclasses inherit the method-access rules of their superclasses. Given a class `C` with a set of access rules, and a class `D` that's a subclass of `C`, instances of `D` exhibit the same access behavior as instances of `C`. But you can set up new rules inside the class definition of `D`, in which case the new rules take precedence for instances of `D` over the rules inherited from `C`.
---

The last topic we'll cover in this chapter is top-level methods. As you'll see, top-level methods enjoy a special case status. But even this status meshes logically with the aspects of Ruby's design you've encountered in this chapter.
