## *Modules and Program Organization* ##

What is a module? Like classes, modules are bundles of methods and constants. As their name suggests, modules encourage modular design: program design that breaks large components into smaller ones and lets you mix and match object behaviors.
Unlike Classes however, modules don't have instances; instead, you specify that you want to add the functionality of a particular module to that of a class or of a specific object.
It's no accident that modules are similar in many respects to classes: The `Class` class in a subclass of the `Module` class, so every class object is also a module object.

You could say that modules are the more basic structure than classes, and classes are just a specialization.

1. All objects descend from `Object`; and the `Kernel` module contains the majority of the methods common to all objects. 
