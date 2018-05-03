## *Error handling and exceptions* ##
Way back in chapter 1, we looked at how to test code for syntax errors:

`$ ruby -cw filename.rb`

Passing the `-cw` test means Ruby can run your program. But it doesn't mean nothing will go wrong while your program is running. You can write a syntactically correct program-a program that the interpreter will accept and execute-that does all sorts of unacceptable things. Ruby handles unacceptable behavior at runtime by *raising an exception.*

### *Raising and rescuing exceptions* ###
An *exception* is a special kind of object, an instance of the class `Exception` or a descendant of that class. *Raising* an exception means stopping normal execution of the program and either dealing with the problem that's been encountered or exiting the program completely.

Which of these happens-dealing with the problem or aborting the program-depends on whether you've provided a `rescue` clause. If you haven't provided a clause, the program terminates; if you have, control flows ot the `rescue` clause.

To see exceptions in action, try dividing by zero:

`$ ruby -e 1/10`

Ruby raises an exception:

```irb
-e:1:in `/': divided by 0 (ZeroDivisionError)
  from -e:1:in `<main>'
```
`ZeroDivisionError` is the name of this particular exception. More technically, it's the name of a class-a descendant class of the class `Exception`. Ruby has a whole family tree of exceptions classes, all of them going back eventually to `Exception.`

### SOME COMMON EXCEPTIONS ###
The table below shows some common exceptions (each of which is a class, descended from `Exception`) along with common reasons they're raised and an example of code that will raise each on:

## Common Exceptions ##
|Exception Name          |  Common reason(s)              | How to raise it                              |
|------------------------|--------------------------------|----------------------------------------------|
| `RuntimeError`         | The default exception raised by the `raise` method |`Raise`                   |
|  `NoMethodError`       | An object is sent a message it can't resolve to a method name; the default `method_missing` raises this exception. |   `a = Object.new`      `a.some_unknown_method_name`           |
