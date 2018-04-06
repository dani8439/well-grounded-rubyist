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

`Object` is a subclass of `BasicObject`. Every class that doesn't have an explicit superclass is a subclass of `Object`. Can see evidence of this default in irb:

 `=> class C`

 `=> end`

 `=> nil`

 `=> C.superclass`

 `=> Object`

Every class has `Object`-and therefore `Kernel` and `BasicObject`-among its ancestors. Of course, there's still the paradox that `BasicObject` is an `Object`, and `Object` is a `Class`, and `Class` is an `Object`. But as we saw earlier, a little bit of circularity in the class model serves to jump-start the hierarchy; and once set in motion, it operates logically and cleanly.

### Defining the same method more than once ###
If you define a method twice in the same class, the second definition takes precedence over the first. (Learned in previous chapter). The same is true of modules. The rules come down to this: there can be only one method of a given nape per class or module at any given time. If you have a method called `calculate_interest` in your `BankAccount` class and you write a second method called `calculate_interest` in the same class, the class forgets all about the first version in the method.

  That's how classes and modules keep house. But when we flip to an object's-eye view, the question of
having access to two or more methods with the same name becomes more involved.

  An object's methods can come from any number of classes and modules. True, any one class or module can
have only one `calculate_interest` method (to use that name as an example). But an object can have multiple `calculate_interest` methods in its method-lookup path, because the method-lookup path passes through multiple classes or multiple modules.

  Still, the rule for objects is analogous to the rule for classes and modules: an object can see only one
version of a method with a given name at any given time. If the object's method-lookup path includes two or more same-named methods, the first one encountered is the "winner" and is executed.

See two-method-module.rb for example.

Two `calculate_interest` methods lie on the method-lookup path of object `c`. But the lookup hits the class `BankAccount` (`account`'s class) before it hits the module `InterestBearing` (a mix-in of class `BankAccount`). Therefore, the report method it executes is the one defined in `BankAccount`.

  An object may have two methods with the same name on its method-lookup path in another circumstance:
when a class mixes in two or more modules, more than one implements the method being searched for. In such a case, the modules are searched in reverse order of inclusion-that is, the most recently mixed-in module is searched first. If the most recently mixed-in module happens to contain a method with the same name as a method in a module that was mixed in earlier, the version of the method in the newly mixed-in module takes precedence because the newer module is closer on the object's method-lookup path.

See example in mixed-in-module.rb - a case where two modules `M` and `N`, both define a `report` method and are both mixed in a class, `C`.

In this example, when you sent the "report" message to an instance of this class, and it walks the lookup path looking for a matching method, the first `report` method encountered in `c`'s method lookup path is the one in *the most recently mixed-in module*. In this case, that means `N`, so `N`'s report method wins over `M`'s report method of the same name.

But what happens when we include a module more than once? It has no effect!
Re-including a module doesn't do anything. Because `M` already lies on the search path, the second `include M` instruction has no effect. `N` is still considered the most recently included module.

In short, you can manipulate the method-lookup paths of your objects, but only up the a point.
