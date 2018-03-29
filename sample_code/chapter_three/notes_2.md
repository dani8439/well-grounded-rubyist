## Basic Object ##

The `BasicObject` class, is older than old; it comes before `Object` in the Ruby class family tree.  the idea behind `BasicObject` is to offer a kind of blank-slate object - an object with almost no methods. (Indeed the precedence for `BasicObject` was a library by Jim Weirich called `BlankSlate`.) `BasicObjects` have so few methods that you'll run into trouble if you create a `BasicObject` instance in rib:

`>> BasicObject.new`

`(Object doesn't support #inspect)`

The object gets created, but irb can't display teh customary string representation of it because it has no `inspect` method.
  A newly created `BasicObject` instance, has only 8 instance methods -- whereas a new instance of
`Object` has 55. You're not likely to need to instantiate or subclass `BasicObject` on a regular basis, if ever. It's mainly handy for situations where you're modeling objects closely to some particular domain, almost to the point of writing a kind of Ruby dialect, and you don't want any false positives when you send messages to whether your objects should play dumb when you send them messages like `display, extend, or clone.`
  Having put inheritance into the mix and looked at some of the key components of the lineage of Ruby
objects, let's return to the subject of classes -- specifically, to one of the most striking aspects of classes: the fact that they are objects and can therefore serve as receivers of messages, just like other objects.
