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

## **What about Singleton methods?** ##
You're familiar from chapter 3 with the *singleton method* -a method defined directly on an object (`def obj.talk`)-- and you may wonder where in the method-lookup path singleton methods lie. The answer is that they lie in a special class, created for the sole purpose of containing them: the object's singleton class. We'll look at singleton classes in detail later in the book.

A somewhat specialized but useful and common technique is available for navigating the lookup path explicitly: the keyword `super`.

## *Going up the method search path with super* ##
Inside the body of a method definition, you can use the `super` keyword
to jump up to the next-highest definition in the method-lookup path of the method you're currently executing.
  The following listing shows a basic example (after which we'll get to the "Why would you do that?"
aspect).

See module_m.rb for code example

Note that `M#report` would have been the first match in a search for a report method if `C#report` didn't exist. The `super` keyword gives you a way to call what would have been the applicable version of a method in cases where the method has been overridden later in the lookup path. Why would you want to do this?

  Sometimes, particularly when you're writing a subclass, a method in an existing class does almost but
not quite what you want. With `super`, you can have the best of both worlds by hooking into or wrapping the original method, as the next listing illustrates. (Bicycle.rb)

  When we call `super`, we don't explicitly forward the `gears` argument that's passed to `initialize`.
Yet when the original `initialize` method in `Bicycle` is called, any arguments provided to the `Tandem` version are visible. This is a special behavior of `super`. The way `super` handles arguments is as follows:

  • Called with no argument list (empty or otherwise), `super` automatically forwards the arguments that were passed to the method from which it's called.

  • Called with an empty argument list-`super()`-`super`, sends no arguments to the higher-up method, even if arguments were passed to the current method.

  • Called with specific arguments -`super(a,b,c)`-`super` sends exactly those arguments.

This unusual treatment of arguments exists because the most common case is the first one, where you want to bump up to the next-higher method with the same arguments as those received by the method from which `super` is being called. That case is given the simplest syntax-you just type `super`. (And because `super` is a keyword rather than a method, it can be engineered to provide this special behavior).
  Now that we've seen how method lookup works, let's consider what happens when method lookup fails.
(notes 4.md)
