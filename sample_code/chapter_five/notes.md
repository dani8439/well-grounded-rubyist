# *The default object (self), scope, and visibility* #
  In describing and discussing computer programs, we often use spatial and, sometimes, human metaphors. We
talk about being "in" a class definition or returning "from" a method call. We address objects in the second person, as in `obj.respond_to?("x")` (this is, "Hey `obj`, to you respond to `x`?"). As a program runs, the question of which objects are being addressed, and where in the imaginary space of the program they stand, constantly shifts.

  The shifts aren't just metaphorical. The meanings of identifiers shift too. A few elements mean the same
thing everywhere. Integers, for example, mean what they mean wherever you see them. The same is true for keywords: you can't just use keywords like `def` and `class` as variable names, so when you see them, you can easily glean what they're doing. But most elements depend on context for their meaning. Most words and tokens-most identifiers-can mean different things at different places and times.

  
