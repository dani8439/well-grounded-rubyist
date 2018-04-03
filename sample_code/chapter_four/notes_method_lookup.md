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

The search ends when the method being searched for is found, or with an error condition if it isn't found. The error condition is triggered by a special method called `method_missing`, which gets called as a last resort for otherwise unmatched messages. You can override `method_missing` (that is, define it anew in one of your own classes or modules) to define custom behavior for such messages, as will be seen later on.

### HOW FAR DOES THE METHOD SEARCH GO? ###
Ultimately, every object in Ruby is an instance of some class descended from the big class in the sky: `BasicObject`. However many classes and modules it may cross along the way, the search for a method can always go as far up as `BasicObject`. But recall that the whole point of `BasicObject` is that it has few instance methods. Getting to know `BasicObject` doesn't tell you much about the bulk of the methods that all Ruby objects share
  If you want to understand the common behavior and functionality of all Ruby objects, you have to descend
from the clouds and look at `Object` rather than `BasicObject`. More precisely, you have to look at `Kernel`, a module that `Object` mixes in. It's in `Kernel` (as its name suggests) that most of Ruby's fundamental methods objects are defined. And because `Object` mixes in `Kernel`, all instances of `Object` and all descendants of `Object` have access to the instance methods in `Kernel`.

`Object` is a subclass of `BasicObject`. Every class that doesn't have an explicit superclas is a subclass of `Object`. Can see evidence of this default in irb:

 `=> class C`

 `=> end`

 `=> nil`

 `=> C.superclass`

 `=> Object`

Every class has `Object`-and therefore `Kernel` and `BasicObject`-among its ancestors. Of course, there's still the paradox that `BasicObject` is an `Object`, and `Object` is a `Class`, and `Class` is an `Object`. But as we saw earlier, a little bit of circularity in the class model serves to jump-start the hierarchy; and once setin motion, it operates logically and cleanly.
