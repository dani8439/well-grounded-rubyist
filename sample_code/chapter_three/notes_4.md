## *Nature vs. nurture in Ruby Objects* ##
The relation between classes and their instances is essentially a relation between the general and the specific -a familiar pattern from the world at large. We're used to seeing the animal kingdom in general/specific terms, and likewise everything from musical instruments to university departments to libraries' shelving systems to pantheons of gods.

  To the extent that a programming language helps you model the real world (or conversely, that the real
world supplies you with ways to organize your programs), you could do worse than to rely heavily on the general-to-specific relationship. As you can see, inheritance-the superclass-to-subclass relationship-mirrors the general/specific ratio closely. Moreover, if you hang out in object-oriented circles you'll pick up some shorthand for this relationship: the phrase *is a*. If, say, `Ezine` inherits from `Magazine`, we say that "an ezine is a magazine." Similarly, a `Magazine` object is a `Publication`, if `Magazine` inherits from `Publication.`

  Ruby lets you model this way. You can get a lot of mileage out of thinking through your domain as a
cascaded, inheritance-based chart of objects. Ruby even provides an `is_a?` method that tells you whether an object has a given class either as its class or as one of its class's ancestral classes:

`>> mag = Magazine.new`

`=> #<Magazine:0x36289c>`

`>> mag.is_a?(Magazine)`

`=> true`

`>> mag.is_a?(Publication)`

`=> true`

Organizing classes into family trees of related entities, with each generation a little more specific than the last, can confer a pleasing sense of order and determinism on your program's landscape.

  But Ruby objects (unlike objects in some other object-oriented languages) can be individually modified.
An instance of a given class isn't stuck with only the behaviors and traits that its class has conferred upon it. You can always add methods on a per-object basis, as you've seen in numerous examples. Furthermore, classes can change. It's possible for an object to gain capabilities-methods-during its lifetime, if its class or ancestral class acquires new instance methods.

  In languages where you can't add methods to individual objects or to classes that have already been
written, an object's class (and the superclass of that class, and so forth) tells you everything you need to know about the object. If the object is an instance of `Magazine`, and you're familiar with the methods provided by the class `Magazine` for the use of its instances, you know exactly how the object behaves.

  But in Ruby the behavior or capabilities of an object can deviate from those supplied by it's class. We
can make a magazine sprout wings:

`mag = Magazine.new`

```ruby
    def mag.wings
      puts "Look! I can fly!"
    end
```

`mag.wings`    <--Output: Look! I can fly!

This demonstrates that the capabilities of the object was born with aren't necessarily the whole story.

  Thus the inheritance three-the upward cascade of class to superclass and super-superclass- isn't the
only determinant of an object's behavior. If you want to know what a brand-new magazine object does, look at the methods in the `Magazine` class and its ancestors. If you want to know what a magazine object can do later, you have to know what's happened to the object since its creation. (And `respond_to?`-the method that lets you determine in advance whether an object knows how to handle a particular method-can come in handy.)

  Ruby objects are tremendously flexible and dynamic. That flexibility translates into programmer power:
you can make magazines fly, make cows tell you who published them, and all the rest of it. As these silly examples make clear, the power implies responsibility. When you make changes to an individual object-when you add methods to that object, and that object alone-you must have a good reason.

  Most Ruby programmers are conservative in this area. You'll see less adding of methods to individual
objects than you might expect. The most common use case for adding methods directly to objects is the adding of class methods to class objects. The vast majority of singleton-style method definitions you'll see (`def some_object.some_method`) will be class-method definitions. Adding methods to other objects (magazines, tickets, cows, and so on) is also possible-but you have to do it carefully and selectively, and with the design of the program in mind.

  In most cases, object individuation has to do with dynamically determined conditions at runtime; for
example, you might add accessor methods to objects to match the names of database columns that you don't know until the program is running and you've queried the database. Or you might have a library of special methods that you've written for string objects, and that you want only certain strings to have access to.
Ruby frees you to do these things, because an object's class is only part of the story-its nature, as you might say, as opposed to its nurture.

  And there's another piece to the puzzle: modules, a Ruby construct you've seen mentioned here several
times in passing, which you'll meet up close and in depth in the next chapter.
