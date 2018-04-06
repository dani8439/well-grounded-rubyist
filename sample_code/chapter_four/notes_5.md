# *Class/module design and naming* #
The fact that Ruby has classes and modules-along with the fact that from an object's perspective, all that matters is whether a given method exists, not what class or module the method's definition is in-means you have a lot of choice when it comes to your programs' design and structure. This richness of design choice raises some considerations you should be aware of.

  We've already looked at one case(the `Stack` class) where it would have been possible to put all the
necessary method definitions into one class, but it was advantageous to yank some of them out, put them in a module (`Stacklike`), and then mix the module into the class. There's no rule for deciding when to do which. It depends on your present and-to the extent you can predict them-future needs. It's sometimes tempting to break everything out into separate modules, because modules you write for one program may be useful in another ("I just know I'm going to need that `ThreePronged` module again someday!" says the packrat voice in your head). But there's such a thing as overmodularization. It depends on the situation. You've got a couple of powerful tools available to you-mix-ins and inheritance-and you need to consider in each case how to balance them.

## *Mix-ins and/or inheritance* ##
Module mix-ins are closely related to class inheritance. In both cases, one entity (class or module) is establishing a close connection with another by becoming neighbors on a method-lookup path. In some cases, you may find that you can design part of your program either with modules or with inheritance.


  Our  `CargoHold` class is an example. We implemented it by having it mix in the `Stacklike` module. But
had we cone the route of writing a `Stack` class instead of a `Stacklike` module, we still could have had a `CargoHold`. It would have been a subclass of `Stack`, as illustrated below:

```ruby
class Stack
  attr_reader :stack
  def initialize
    @stack = []
  end
  def add_to_stack(obj)
    @stack.push(obj)
  end
  def take_from_stack
    @stack.pop
  end
end

class Suitcase
end

class CargoHold < Stack
  def load_and_report(obj)
    print "Loading object "
    puts obj.object_id
    add_to_stack(obj)
  end
  def unload
    take_from_stack
  end
end
```

From the point of view of an individual `CargoHold` object, the process works in this listing exactly as it worked in the earlier implementation, where `CargoHold` mixed in the `Stacklike` module. The object is concerned with finding and executing methods that correspond to the messages it receives. It either finds such methods on its method-lookup path, or it doesn't. It doesn't care whether the methods were defined in a module or a class. It's like searching a house for a screwdriver: you don't care which room you find it in, and which room you find it in makes no difference to what happens when you subsequently employ the screwdriver for a task.

There's nothing wrong with this inheritance-based approach to implementing `CargoHold`, except that it eats up the one inheritance opportunity `CargoHold` has. If another class might be more suitable than `Stack` to serve as `CargoHold`'s superclass (like, hypothetically `StorageSpace` or `AirplaneSection`), we might end up needing the flexibility we'd gain by turning at least one of those classes into a module.

No single rule or formula always results in the right design. But it's useful to keep a couple of considerations in mind when you're making class-versus-module decisions:

  • *Modules don't have instances.* It follows that entities or things are generally best modeled in classes, and characteristics or properties of entities or things are best encapsulated in modules. Correspondingly, as noted earlier, class names tend to be nouns, whereas module names are often adjectives (`Stack` vs `Stacklike`).

  • A *class can have only one superclass, but it can mix in as many modules as it wants.* If you're using inheritance, give priority to creating a sensible superclass/subclass relationship. Don't use up a class's one and only superclass relationship to endow the class with what might turn out to be just one of several sets of characteristics.

Summing up these rules in one example, here is what you should *not* do:

```ruby
module Vehicle
...
class Truck < SelfPropelling
  include Vehicle
...
```

Rather, you should do this:
```ruby
module SelfPropelling
...
class Vehicle
  include SelfPropelling
...
class Truck < Vehicle
...
```
The second version models the entities and properties much more neatly. `Truck` descends from `Vehicle` (which makes sense), whereas `SelfPropelling` is a characteristic of vehicles (at least, all those we care about in this model of the world)-a characteristic that's passed on to trucks by virtue of `Truck` being a descendent, or specialized form of `Vehicle`.

Another important consideration in class/module design is the nesting of modules and/or classes inside each other.

## *Nesting modules and classes* ##
You can nest a class definition inside a module definition like this:

```ruby
module Tools
  class Hammer
  end
end
```

To create an instance of the `Hammer` class defined inside the `Tools` module, you use the double-colon constant lookup token (`::`) to point the way to the name of the class:

`h = Tools::Hammer.new`

Nested module/class chains like `Tools::Hammer` are sometimes used to create separate namespaces for classes, modules, and methods. This technique can help if two classes have a similar name but aren't the same class. For example, if you have a `Tools::Hammer` class, you can also have a `Piano::Hammer` class, and the two `Hammer` classes won't conflict with each other because each is nested in its own namespace (`Tools` in one case, `Piano` in the other).

(An alternative way to achieve this separation would be to have a  `ToolsHammer` class and a `PianoHammer` class, without bothering to nest them in modules. But stringing names together like that can quickly lead to visual clutter, especially when elements are nested deeper than two levels.)

## **Class or module?** ##
When you see a construct like `Tools::Hammer`, you can't tell solely from that construct what's a class and what's a module-nor, for that matter, whether `Hammer` is a plain, old constant. (`Tools` has to be a class or module, because it's got `Hammer` nested inside it.) In many cases, the fact that you can't tell classes from modules in this kind of context doesn't matter; what matters is the nesting or chaining of names in a way that makes sense. That's just as well, because you can't tell what's what without looking at the source code or the documentation. This is a consequence of the fact that classes are modules-the class `Class` is as subclass of the class `Module`-and in many respects (with the most notable exception that classes can be instantiated), their behavior is similar. Of course, normally you'd know what `Tools::Hammer` represents, either because you wrote the code or because you've seen documentation. Still, it pays to realize that the notation itself doesn't tell you everything.
