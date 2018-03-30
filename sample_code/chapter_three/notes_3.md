## *Classes as objects and message receivers* ##

Classes are special objects: they're the only kind of object that has the power to spawn new objects (instances). Nonetheless, they're objects. When you create a class, like `Ticket`, you can send messages to it, add methods to it, pass it around to other objects as a method argument, and generally do anything to it you would do another object.
  Like other objects, classes can be created -- indeed, in more than one way.

### *Creating class objects* ###
Every class -`Object, Person Ticket` - is an instance of a class called `Class`. As you've already seen, you can create a class object with the special `class` keyword formula:

`class Ticket`
`# your code here`
`end`

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

⋅⋅* From their class
⋅⋅* From the superclass and earlier ancestors of their class
⋅⋅* From their own store of singleton methods (the "talk" in `def obj.talk`)

The situation is basically the same for classes. There are some, but very few, special cases or bells and whistles for class objects. Mostly they behave like other objects.

###Three scenarios for method calling###
  Instances of `Class` can call methods that are defined as instance methods in their class. `Ticket` for
example, is an instance of `Class`, and `Class` defines an instance method called `new`. That's why we can write:

`Ticket.new`

  The superclass of `Class` is `Module`. Instances of `Class` therefore have access to the instance
methods defined in `Module`; among these are the `attr_accessor` family of methods. That's why we can write:

`class Ticket`

`attr_reader :venue, :date`

`attr_accessor :price`

Those method calls go directly to the class object `Ticket`, which is in the role of the default object `self` at the point when calls are made. That just leaves the final scenario; calling a singleton method of a class object. (see singleton method notes)
