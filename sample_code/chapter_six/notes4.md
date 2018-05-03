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
|  `NameError` | The interpreter hits an identifier it can't resolve as a variable or method name. | `a = some_random_identifier` |
| `IOError` | Caused by reading a closed stream, writing to a read-only stream, and similar operations. | `STDIN.puts("Don't write to STDIN!")`|
| `Erno::Error` | A family of errors relates to file I/O | `File.open(-12)` |
| `TypeError` | A method receives an argument it can't handle. | `a = 3 + "can't add a string to a number!"` |
| `ArgumentError` | Caused by using the wrong number of arguments | `def m(x); end; m(1,2,3,4,5)` |

You can try these examples in irb; you'll get an error message, but the session shouldn't terminate. irb is good about making potentially fatal errors nonfatal-and you can do something similar in your programs, too.

### *The rescue keyword to the rescue!* ###
Having an exception raised doesn't have to mean your program terminates. You can handle exceptions-deal with the problem and keep the program running-by means of the `rescue` keyword. Rescuing involves a `rescue` block, which is delimited with the `begin` and `end` keywords and has a `rescue` clause in the middle:

```ruby
print "Enter a number: "
n = gets.to_i
begin
  result = 100 / n
rescue
  puts "Your number didn't work. Was it zero???"
  exit
end
puts "100/#{n} is #{result}."
```

If you run this program and enter `0` as your number, the division operation (`100/n`) raises a `ZeroDivisionError`. Because you've done this inside a `begin/end` block with a `rescue` clause, control is passed to the `rescue` clause. An error message is printed out, and the program exits.

If you enter something other than `0` and the division succeeds, program control skips over the `rescue` statement and block, and execution resumes thereafter (with the call to `puts`).

You can refine this technique by pinpointing the exception you want to trap. Instead of a generic rescue instruction, which rescues any error that's a descendant class of `StandardError`, you tell `rescue` what to rescue:

`rescue ZeroDivisionError`

This traps a single type of exception but not others. The advantage is that you're no longer running the risk of inadvertently covering up some other problem by rescuing too eagerly.

Rescuing exceptions inside a method body or code block has a couple of distinct features worth noting.

### USING RESCUE INSIDE METHODS AND CODE BLOCKS ###
The beginning of a method or code block provides an implicit `begin/end` context. Therefore, if you use the `rescue` keyword inside a method or code block, you don't have to say `begin` explicitly-assuming that you want the `rescue` clause to govern the entire method or block:

```ruby
def open_user_file
  print "File to open: "
  filename = gets.chomp
  fh = File.open(filename) #<---1.
  yield fh
  fh.close
rescue     #<---2.
    puts "Couldn't open your file!"
end
```
If the file-opening operation 
