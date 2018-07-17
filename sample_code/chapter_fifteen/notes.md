# *Callbacks, hooks, and runtime introspection* #
In keeping with its dynamic nature and its encouragement of flexible, supple object and program design, Ruby provides a large number of ways to examine what's going on while your program is running and to set up event-based callbacks and hooks-essentially, tripwires that are pulled at specified times and for specific reasons-in the form of methods with special, reserved names for which you can, if you wish, provide definitions. Thus you can rig a module so that a particular method gets called every time a class includes that module, or write a callback method for a class that gets called every time the class is inherited, and so on.

In addition to runtime callbacks, Ruby lets you perform more passive but often critical acts of examination: you can ask objects what methods they can execute (in even more ways than you've seen already) or what instance variables they have. You can query classes and modules for their constants and their instance methods. You can examine a stack trace to determine what method calls got you to a particular point in your program-and you even get access to the filenames and line numbers of all the method calls along the way.

In short, Ruby invites you to the party: you get to see what's going on, in considerable detail, via techniques for runtime introspection; and you can order Ruby to push certain buttons in reaction to runtime events. This chapter, the last in the book, will explore a variety of these introspective and callback techniques and will equip you to take ever greater advantage of the facilities offered by this remarkable, and remarkably dynamic, language.

## *Callbacks and hooks* ##
The use of *callbacks* and *hooks* is a fairly common meta-programming technique. These methods are called when a particular even takes place during the run of a Ruby program. An event is something like

• A nonexistent method being called on an object.

• A module being mixed in to a class or another module.

• An object being extended with a module.

• A class being subclasses (inherited from).

• A reference being made to a nonexistant constant.

• An instance method being added to a class.

• A singletone method being added to an object.

For every event in that list, you can (if you choose) write a callback method that will be executed when the event happens. These callback methods are per-object or per-class, not global; if you want a method called when the class `Ticket` gets subclasses, you have to write the appropriate method specifically for class `Ticket`.

What follows are descriptions of each of these runtime event hooks. We'll look at them in the order they're listed above.

### *Intercepting unrecognized messages with method_missing* ### 
Back in chapter 4 (Section 4.3) you learned quite a lot about `method_missing`. To summarize: when you send a message to an object, the object executes the first method it finds on its method-lookup path with the same name as the message. If it fails to find any such method, it raises a `NoMethodError` exception-unless you've provided the object with a method called `method_missing`. (Refer back to section 4.3 if you want to refresh your memory on how `method_missing` works.)

Of course, `method_missing` deserves a berth in this chapter too, because it's arguably the most commonly used runtime hook in Ruby. Rather than repeat chapter 4's coverage, though, let's look at a couple of specific `method_missing` nuances. We'll consider using `method_missing` as a delegation technique; and we'll look at how `method_missing` works, and what happens when you override it, at the top of the class hierarchy.

#### DELEGATING WITH METHOD_MISSING ####

**Ruby's method-delegating techniques** 

#### THE ORIGINAL: BASICOBJECT#METHOD_MISSING ####

#### METHOD_MISSING, RESPOND_TO?, AND RESPOND_TO_MISSING? #### 

### *Trapping include and prepend operations* ### 

### *Intercepting extend* ###

#### SINGLETON-CLASS BEHAVIOR WITH EXTENDED AND INCLUDED ####

### *Intercepting inheritance with Class#inherited* ###

**The limits of the `inherited` callback**

### *The Module#const_missing method* ###

### *The method_added and singleton_method_added methods* ###

## *Intercepting object capability queries* ##

### *Listing an object's non-private methods* ### 

### *Listing private and protected methods* ###

### *Getting class and module instance methods* ###

#### GETTING ALL THE ENUMERABLE OVERRIDES ####

### *Listing objects' singleton methods* ###

## *Introspection of variables and constants* ## 

### *Listing local and global variables* ###

### *Listing instance variables* ###

**The irb underscore variable** 

## *Tracing execution* ##

### *Examining the stack trace with caller* ###

### *Writing a tool for parsing stack traces* ###

#### THE CALLERTOOLS::CALL CLASS ####

#### THE CALLERTOOLS::STACK CLASS ####

#### USING THE CALLERTOOLS MODULE ####

## *Callbacks and method inspection in practice* ##

### *MicroTest background: MiniTest* ###

### *Specifying and implementing MicroTest* ### 

**Note** 

## *Summary* ##
