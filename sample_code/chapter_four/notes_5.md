# *Class/module design and naming* #
The fact that Ruby has classes and modules-along with the fact that from an object's perspective, all that matters is whether a given method exists, not what class or module the method's definition is in-means you have a lot of choice when it comes to your programs' design and structure. This richness of design choice raises some considerations you should be aware of.

  We've already looked at one case(the `Stack` class) where it would have been possible to put all the
necessary method definitions into one class, but it was advantageous to yank some of them out, put them in a module (`Stacklike`), and then mix the module into the class. There's no rule for deciding when to do which. It depends on your present and-to the extent you can predict them-future needs.
