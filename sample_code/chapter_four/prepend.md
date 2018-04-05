## *Prepend* ##
Every time you `include` a module into a class, you're affecting what happens when instances of that class have to resolve messages into method names. The same is true of `prepend`. The difference is that if you `prepend` a module to a class, the object looks in that module first, before it looks in the class.

Look at prepend_example.rb for example.

The output is `Hello from module!` Why? Because we have prepended the `MeFirst` module to the class. That means that the instance of the class will look to the module first when it's trying to find a method called `report`. If we'd used `include`, the class would be searched before the module and the class's version of `report` would "win."
  You can see the difference between `include` and `prepend` reflected in the list of a class's ancestors -
which means all the classes and modules where an instance of the class will search for methods, listed in order. Here are the ancestors of the `Person` class from the last example, in irb:

`> Person.ancestors`

`=> [MeFirst, Person, Object, Readline, Kernel, BasicObject]`

Now modify the example(in prepend_example.rb) to use `include` instead of `prepend`. Two things happen. First the output changes:

`Hello from class!`

Second, the order of the ancestors changes:

`=> [Person, MeFirst, Object, Readline, Kernel, BasicObject]`

(Of course, the name `MeFirst` ceases to make sense, but we get the general idea).
  You can use `prepend` when you want a module's version of one or more methods to take precedence over
the versions defined in a given class. As mentioned earlier, `prepend` is new in Ruby 2.0. You won't see it used much, at least not yet. But it's useful to know it's there, both so that you can use it if you need it and so that you'll know what it means if you encounter it in someone else's code.

### *The rules of method lookup summarized* ###
The basic rules governing method lookup and the ordering of the method search path in Ruby 2.0 are illustrated in figure 4.2.
  To resolve a message into a method, an object looks for the method in:

  1. Modules prepended to its class, in reverse order of prepending.
  2. Its class.
  3. Modules included in its class, in reverse order of inclusion.
  4. Modules prepended to its superclass.
  5. Its class's superclass.
  6. Modules included in its superclass.
  7. Likewise, up to `Object` (and its mix-in `Kernel`) and `BasicObject`.

Note in particular the point that modules are searched for methods in reverse order of prepending or inclusion. That ensures predictable behavior in the event that a class mixes in two modules that define the same method.
