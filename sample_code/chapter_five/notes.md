# *The default object (self), scope, and visibility* #
  In describing and discussing computer programs, we often use spatial and, sometimes, human metaphors. We
talk about being "in" a class definition or returning "from" a method call. We address objects in the second person, as in `obj.respond_to?("x")` (this is, "Hey `obj`, to you respond to `x`?"). As a program runs, the question of which objects are being addressed, and where in the imaginary space of the program they stand, constantly shifts.

  The shifts aren't just metaphorical. The meanings of identifiers shift too. A few elements mean the same
thing everywhere. Integers, for example, mean what they mean wherever you see them. The same is true for keywords: you can't just use keywords like `def` and `class` as variable names, so when you see them, you can easily glean what they're doing. But most elements depend on context for their meaning. Most words and tokens-most identifiers-can mean different things at different places and times.

  Two topics focused on in this chapter: *self* and *scope*. *Self* is the "current" or "default" object,
a role typically assigned to many objects in sequence (though only one at a time) as a program runs. The self object in Ruby is like the first person or *I* of the program. As in a book with multiple first-person narrators, the *I* role can get passed around. There's always one self, but what object it is will vary. The rules of scope govern the visibility of variables (and other elements, but largely variables). It's important to know what scope you're in, so that you can tell what variables refer to and not confuse them with variables from different scopes that have the same name, nor with similarly named methods.

  Between them, self and scope are the master keys to orienting yourself in a Ruby program. If you know
what scope you're in and know what object is self, you'll be able to tell what's going on, and you'll be able to analyze errors quickly.

  The third main topic is *method access*. Ruby provides mechanisms for making distinctions among access
levels of methods. Basically, this means rules limiting the calling of methods depending on what self is. Method access is therefore a meta-topic, grounded in the study of self and scope.

  *Top-level methods* will pull several of these threads together, they are written outside of any class
or module definition.

## *Understanding self, the current/default object* ##
One of the cornerstones of Ruby programming-the backbone, in some respects-is the default object or current object, accessible to you in your program through the keyword `self`. At every point when your program is running, there's one and only one self. Being self has certain privileges, as you'll see. In this section, will look at how Ruby determines which object is self at a given point and what privileges are granted to the object that is self.

### *Who gets to be self, and where* ###
There's always one (and only one) current object or self. You can tell which object it is by following small set of rules below:

#### How the current object(self) is determined ####
|      Context        |         Example        |        Which object is self?                       |
|---------------------|------------------------|----------------------------------------------------|  
|Top level of program | Any code outside of other blocks|`main`(built-in top-level default object)  |
|Class definition     | `class C`              | The class object `C`                               |
|                     |      `self`            |                                                    |
|Module Definition    | `module M`             | The module object `M`                              |
|                     | `self`                 |                                                    |
|Method Definitions   | 1. Top level (outside any definition block): | Whatever object is self when the method is called; top-level methods are available as private methods to all objects.                |
