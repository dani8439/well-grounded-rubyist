## *Error handling and exceptions* ##
Way back in chapter 1, we looked at how to test code for syntax errors:

`$ ruby -cw filename.rb`

Passing the `-cw` test means Ruby can run your program. But it doesn't mean nothing will go wrong while your program is running. You can write a syntactically correct program-a program that the interpreter will accept and execute-that does all sorts of unacceptable things. Ruby handles unacceptable behavior at runtime by *raising an exception.*

### *Raising and rescuing exceptions* ###
An *exception* is a special kind of object, an instance of the class `Exception` or a descendant of that class. *Raising* an exception means stopping normal execution of the program and either dealing with the problem that's been encountered or exiting the program completely.

Which of these happens-dealing with the problem or aborting the program-depends on whether you've provided a `rescue` clause. If you haven't provided a clause, the program terminates; if you have, control flows ot the `rescue` clause.

To see exceptions in action, try dividing by zero:

`$ ruby -e 1/10` 
