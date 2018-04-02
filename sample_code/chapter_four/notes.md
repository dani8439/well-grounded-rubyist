## *Modules and Program Organization* ##

What is a module? Like classes, modules are bundles of methods and constants. As their name suggests, modules encourage modular design: program design that breaks large components into smaller ones and lets you mix and match object behaviors.
Unlike Classes however, modules don't have instances; instead, you specify that you want to add the functionality of a particular module to that of a class or of a specific object.
It's no accident that modules are similar in many respects to classes: The `Class` class in a subclass of the `Module` class, so every class object is also a module object.

You could say that modules are the more basic structure than classes, and classes are just a specialization.

1. All objects descend from `Object`; and the `Kernel` module contains the majority of the methods common to all objects.

### *Basics of module creation and use* ###
Modules get *mixed in* to classes, using either the `include` method or the `prepend` method.

Mixing in a module bears a strong resemblance to inheriting from a superclass. If, say, class `B` inherits from class `A`, instances of class `B` can call instance methods of class `A`. And if, say, class `C` mixes in module `M`, instances of class `C` can call instance methods of module `M`.

The main difference between inheriting from a class and mixing in a module is that you can mix in more than one module. No class can inherit from more than one class. In cases where you want numerous extra behaviors for a class's instances-and you don't want to stash them all in the class's superclass and its ancestral classes-you can use modules to organize your code in a more granular way. Each module can add something different to the methods available through the class.

### *A module encapsulating "stacklikeness"* ###
A *stack* is a data structure that operates on the last in, first out (LIFO) principle. The classic example is a (physical) stack of plates. The first plate to be used is the last one placed on the stack. Stacks are usually discussed paired with queues, which exhibit first in, first out (FIFO) behavior. Think of a cafeteria: the plates are in a stack; the customers are in a queue.

(see notes in stacklike.rb)

The module `Stacklike` thus implements stacklikeness by selectively deploying behaviors that already exist for `Array` objects: add an element to the end of the array, take an element off the end. Arrays are more versatile than stacks: a stack can't do everything an array can. For example, you can remove elements from an array in any order; whereas by definition the only element you can remove from a stack is the one that was added most recently. But an array can do everything a stack can. As long as we don't ask it to do anything unstacklike, using an array asa a kind of agent or proxy for the specifically stacklike add/remove actions makes sense.

We now have a module that implements stacklike behavior: maintining a list of items, such that new ones can be added to the end and the most recently added one can be removed. Next question is, what can we do with this module?

### *Mixing a module into a class* ###

`s = Stacklike.new` <-- Wrong! No such method. 
