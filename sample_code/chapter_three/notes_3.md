## *Classes as objects and message receivers* ##

Classes are special objects: they're the only kind of object that has the power to spawn new objects (instances). Nonetheless, they're objects. When you create a class, like `Ticket`, you can send messages to it, add methods to it, pass it around to other objects as a method argument, and generally do anything to it you would do another object.
  Like other objects, classes can be created -- indeed, in more than one way.

### *Creating class objects* ###
Every class -`Object, Person Ticket` - is an instance of a class called `Class`. As you've already seen, you can create a class object with the special `class` keyword formula:

```ruby
class Ticket
  # your code here
end
```

That formula is a special provision by Ruby -- a way to make a nice-looking, easily accessible class-definition block. But you can also create a class the same way you create most other objects, by sending the message `new` to the class object `Class`.

`my_class = Class.new`

In this case, the variable `my_class` is assigned a new class object.
  `Class.new` corresponds precisely to other constructor calls like `Object.new` and `Ticket.new`. When
you instantiate the class `Class`, you create a class. That class, in turn, can create instances of its own:

`instance_of_my_class = my_class.new`

Saw earlier that class objects are usually represented by constants (like `Ticket` or `Object`). In the preceding scenario, the class object is bound to a regular local variable (`my_class`). Calling the `new` method send the message `new` to the class through that variable.

And yes, there's a paradox here...

### THE CLASS/OBJECT CHICKEN-OR-EGG PARADOX ###
The class `Class` is an instance of itself - that is, it's a `Class` object. And there's more. Remember the class `Object`? Well, `Object` is a class - but classes are objects. `Object` is an object. And `Class` is a class. And `Object` is a class, and `Class` is an object.
  Which came first? How can the class `Class` be created unless the class `Object` already exists? But how
can there be a class `Object` (or any other class) until there is a class `Class` of which there can be instances?
  The best way to deal with this paradox, at least for now, is to ignore it. Ruby has to do some of this
chicken-or-egg stuff to get the class and object system up and running-and then the circularity and paradoxes don't matter. In the course of programming, you just need to know that classes are objects, instances of the class called `Class`. (If you want to know in brief how it works, it's like this: every object has an internal record of what class it's an instance of, and the internal record inside the object `Class` points back to `Class` itself).
  Classes are objects, and objects receive messages and execute methods. How exactly does the
method-calling process play out in the case of class objects?

## *How class objects call methods* ##
When you send a message to a class object, it looks like this:

`Ticket.some_message`

Or, if you're inside a class-definition body and the class is playing the role of the default object `self`, it looks like this:

`class Ticket`
  `some_message`   <--- Such as `attr_accessor`

That's how the class object gets messages. But where do the methods come from to which the messages correspond?
  To understand where classes get their methods, think about where your objects in general get their
methods (minus modules, which haven't been explored yet):

1. From their class
2. From the superclass and earlier ancestors of their class
3. From their own store of singleton methods (the "talk" in `def obj.talk`)

The situation is basically the same for classes. There are some, but very few, special cases or bells and whistles for class objects. Mostly they behave like other objects.

###Three scenarios for method calling###
  Instances of `Class` can call methods that are defined as instance methods in their class. `Ticket` for
example, is an instance of `Class`, and `Class` defines an instance method called `new`. That's why we can write:

`Ticket.new`

  The superclass of `Class` is `Module`. Instances of `Class` therefore have access to the instance
methods defined in `Module`; among these are the `attr_accessor` family of methods. That's why we can write:

```ruby
  class Ticket
      attr_reader :venue, :date
      attr_accessor :price
  ```

Those method calls go directly to the class object `Ticket`, which is in the role of the default object `self` at the point when calls are made. That just leaves the final scenario; calling a singleton method of a class object. (see singleton method notes)

### The term *class method*: More trouble that it's worth? ###
Ruby lets objects have singleton methods, and classes are objects. So when you do `def Ticket.most_expensive`, you're basically creating a singleton method for `Ticket`. On the calling side, when you see a method called on a class object-like `Ticket.new` - you can't tell just by looking whether you're dealing with a singleton method defined directly on this class (`def Ticket.new`) or an instance method of the class `Class`.

Just to make it even more fun, the class `Class` has both a class-method version of `new` and an instance-method version; the former is called when you write `Class.new` and the latter when you write `Ticket.new`. Unless, of course, you override it by defining `new` for `Ticket` yourself...

Admittedly, `new` is a particularly thorny case. But in general, the term *class method* isn't necessarily a great fit for Ruby. It's a concept shared with other object-oriented languages, but in those languages there's a greater difference between class methods and instance methods. In Ruby, when you send a message to a class object, you can't tell where and how the corresponding method was defined.

So *class method* has a fuzzy meaning and a sharp meaning. Fuzzily, any method that gets called directly on a `Class` object is a class method. Sharply, a class method is defined, not just called, directly on a `Class` object. You'll hear it used both ways, and as long as you're aware of the underlying engineering and can make the sharp distictions when you need to, yo'll be fine.

### *When, and why, to write a class method* ###
Class methods serve a purpose. Some operations pertaining to a class can't be performed by individual instances of that class. The `new` method is an excellent example.We call `Ticket.new` because, until we've created an individual ticket, we can't send it any messages! Besides, the job of spawning a new object logically belongs to the class. It doesn't make sense for instances of `Ticket` to spawn each other. But it does makes sense for the instance-creation process to be centralized as an activity of the class `Ticket`
  Another similar case is the built-in Ruby method `File.open`- a method that, as seen in Chapter 1, opens
a file for reading and/or writing. The `open` operation is a bit like `new`; it initiates file input and/or output and returns a `File` object. It makes sense for `open` to be a class method of `File`: you're requesting the creation of an individual object from the class. The class is acting as a point of departure for the object it creates.
  `Ticket.most_expensive` is a different case, in that it doesn't create a new object- but it's still a
method that belongs logically to the class. Finding the most expensive ticket in a list of tickets can be viewed as an operation from above, something that's done collectively with respect to tickets, rather than something that's done by an individual ticket object. Writing `most_expensive` expensive as a class method of `Ticket` lets us keep the method in the ticket family, so to speak, while assigning it to the abstract, supervisory level represented by the class.
  It's not unheard of to create a class only for the purpose of giving it class methods. Our earlier
temperature-conversion exercises offer an opportunity for using this approach.

### Converting the Converter ###
Let's convert the converter class to a converter class, adding class methods for conversion in both directions:

```ruby
class Temperature
      def Temperature.c2f(celsius)
        celsius * 9.0/ 5 + 32
      end

      def Temperature.f2c(fahrenheit)
        (fahrenheit - 32) * 5 / 9.0
      end
    end
    ```

The idea is that we have temperature-related utility methods-methods pertaining to temperature as a concept but not to a specific temperature. The `Temperature` class is a good choice of object to own those methods. We could get fancier and have `Temperature` instances that knew either they were Celsius of Fahrenheit and could convert themselves; but practically speaking, having a `Temperature` class with class methods to perform the conversions is adequate and is an acceptable design. (Even better, because we don't need instances of `Temperature` at all, would be to use a module - a kid of "instanceless" class, which we'll learn more about later on).
  Class methods and instance methods aren't radically different from each other; they're all methods, and
their execution is always triggered by sending a message to an object. It's just that the object getting the message may be a class object. Still, there are differences and important points to keep in mind as you start writing methods at various levels.

## *Class methods vs. Instance methods* ##
By defining `Ticket.most_expensive`, we've defined a method that we can access through the class object `Ticket` but not through its instances. Individual ticket objects (instances of the class `Ticket`) don't have this method. Can test this easily -- add code to ticket class from previous section, where the variable `fg` referred to a `Ticket` object (for an event at the fairgrounds):

`puts "Testing the response of a ticket instance...."`

`wrong = fg.most_expensive`

Will get an error message, because `fg` has no method called `most_expensive`. The class of `fg`, namely `Ticket` has such a method. But `fg`, which is an instance of `Ticket` doesn't.
    Remember:
    1. Classes are objects.
    2. Instances of classes are objects, too.
    3. A class object (like `Ticket`) has its own methods, its own state, and its own identity. *It doesn't share these things with instances of itself.* Sending a message to `Ticket` isn't the same thing as sending a message to `fg` or `cc` or any other instance of `Ticket`.
If you ever get tangled up over what's a class method and what's an instance method, you can usually sort out the confusion by going back to these three principles.

## A note on method notation ##
In writing about and referring to Ruby methods (outside of code, that is) it's customary to refer to instance methods by naming the class (or module, as the case may be) in which they're defined, followed by a hash mark (#) and the name of the method; and to refer to class methods with a similar construct but using a period instead of the hash mark. Sometimes you'll see a double colon (::) instead of a period in the class-method case.

Here are some examples of this notation and what they refer to:
1. `Ticket#price` refers to the instance method `price` in the class `Ticket`.
2. `Ticket.most_expensive` refers to the class method `most_expensive` in the class `Ticket`.
3. `Ticket::most_expensive` also refers to the class method `most_expensive` in the class `Ticket`.

From now on, when you see this notation (in this book or elsewhere), you'll know what it means. (The second example - class-method reference using a dot-looks the same as a call to the method, but you'll know from the context whether it's a method call or a reference to the method it a discussion).
