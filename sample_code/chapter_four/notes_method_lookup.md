## *Method Lookup* ##

*Gets access to* a method, like *has* a method, is a vague way to put it. Need to get more of a fix on the process by considering an object's-eye view of it.

### AN OBJECT'S-EYE VIEW OF METHOD LOOKUP ###
You're the object, and someone sends you a message. You have to figure out how to respond to it-or whether you even *can* respond to it. Here's a bit of object stream-of-consciousness:

  I'm a Ruby object, and I've been sent the message 'report'. I have to try to find a method called `report` in my method lookup path. `report`, if it exists, resides in a class or module.

  I'm an instance of a class called `D`. Does class `D` define an instance method `report`?
  *No.*
  Does `D` mix in any modules?
  *No.*
  Does `D`'s superclass, `C`, define a `report` instance method?
  *No.*
  Does `C` mix in any modules?
  *Yes*, `M`.
  Does `M` define a `report` method?
  *Yes.*
  Good! I'll execute that method.

The search 
