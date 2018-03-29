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
