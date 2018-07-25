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
  fh = File.open(filename)        #1.
  yield fh
  fh.close
rescue                            #2.
    puts "Couldn't open your file!"
end
```
If the file-opening operation (#1) triggers an exception, control jumps directly to the `rescue` clause (#2). The `def/end` keywords serve to delimit the scope of the rescue operation. But you may want to get a little more fine-grained about which lines your `rescue` clause applies to. In the previous example, the `rescue` clause is triggered even if an exception is raised for reasons having nothing to do with trying to open the file. For example, if the call to `gets` raises an exception for any reason, the rescue clause executes.

To get more fine-grained, you have to go back to using an explicit `begin/end` wrapper:

```ruby
def open_user_file
  print "File to open: "
  filename = gets.chomp
  begin                               #1
    fh = File.open(filename)
  rescue                              #2
    puts "Couldn't open your file!"
    return                            #3
  end
  yield fh
  fh.close
end
```
In this version, the `rescue` clause only governs what comes between the `begin` keyword (#1) and `rescue` (#2). Moreover, it's necessary to give an explicit `return` command inside the `rescue` clause (#3) because otherwise the method will continue to execute.

So far, we've been looking at how to trap exceptions raised by Ruby-and you'll learn more exception-trapping techniques. But let's turn now to the other side of the coin: how to raise exceptions yourself.

### *Raising exceptions explicitly* ###
When it comes to Ruby's traditional flexibility and compact coding power, exceptions are, so to speak, no exception. You can raise exceptions in your own code, and you can create new exceptions to raise.

To raise an exception, you use `raise` plus the name of the exception you wish to raise. If you don't provide an exception name (and if you're no re-raising a different kind of exception, as described later), Ruby raises the rather generic `RuntimeError`. You can also give `raise` a second argument, which is used as the message string when the exception is raised:

```ruby
def fussy_method(x)
  raise ArgumentError, "I need a number under 10" unless x < 10
end
fussy_method(20)
```
If run from a file called fussy.rb, this code prints out the following:

```irb
fussy.rb:2:in `fussy_method': I need a number under 10 (ArgumentError)
        from fussy.rb:4:in `<main>'
```
You can also use `rescue` in such a case:

```ruby
begin
  fussy_method(20)
rescue ArgumentError
  puts "That was not an acceptable number!"
end
```
A nice tweak is that if you give `raise` a message as the only argument, rather than as the second argument where an exception class is the first argument, `raise` figures out that you want it to raise a `RuntimeError` using the message provided. These two lines are equivalent:

```ruby
raise "Problem!"
raise RuntimeError, "Problem!"
```
In your `rescue` clauses, it's possible to capture the exception object in a variable and query it for possibly useful information.

### *Capturing an exception in a rescue clause* ###
To assign the exception object to a variable, you use the special operator `=>` along with the `rescue` command. The exception object, like any object, responds to messages. Particularly useful are the `backtrace` and the `message` methods. `backtrace` returns an array of strings representing the call stack at the time the exception was raised: method names, filenames, and line numbers, showing a full roadmap of the code that was executed along the way to the exception. `message` returns the message string provided to `raise`, if any.

To see these facilities in action, put the preceding definition of `fussy_method` in the file fussy.rb (if you haven't already), and then add the following `begin/end` block:

```ruby
begin
  fussy_method(20)
rescue ArgumentError => e                              #1
  puts "That was not an acceptable number!"
  puts "Here's the backtrace for this exception: "
  puts e.backtrace                                     #2
  puts "And here's the exception object's message: "
  puts e.message                                       #3
end
```
In the `rescue` clause, we assign the exception object to the variable `e` (#1) and then ask the exception object to display its backtrace(#2) and its message(#3). Assuming you've got one blank line between `fussy_method` and `begin` keyword, you'll see the following output  (and, in any case, you'll see something almost identical, although the line numbers may differ) when you run fussy.rb.

```irb
That was not an acceptable number!
Here's the backtrace for this exception:
fussy.rb:2:in `fussy_method'
fussy.rb:17:in `<main>'
And here's the exception object's message:
I need a number under 10
```
The backtrace shows you that we were in the `fussy_method` method on line 2 of fussy.rb when the exception was raised, and that we were previously on line 6 of the same file in the `<main>` context-in other words, at the top level of the program (outside of any class, module, or method definition.) The message, "I need a number under 10" comes from the call to `raise` inside `fussy_method`. Your `rescue` clause can also re-raise the exception that triggered it.

<Note in text about language of exception raising being class-based. Instances of the exception classes are raised, but we get a break from writing `raise ZeroDivisionError.new`.>

### RE-RAISING AN EXCEPTION ###
It's not uncommon to want to re-raise an exception, allowing the next location on the call stack to handle it after your `rescue` block has handled it. You might, for example, want to log something about the exception but still have it treated as an exception by the calling code.

Here's a second version of the `begin/end` block from the `open_user_file` method a few examples back. This version assumes that you have a `logfile` method that returns a writeable file handle on a log file:

```ruby
begin
  fh = File.open(filename)
rescue => e
  logfile.puts("User tried to open #{filename}, #{Time.now}")
  logfile.puts("Exception: #{e.message}")
  raise
end
```
The idea here is to intercept the exception, make a note of it in the log file, and then re-raise it by calling `raise`. (Even though there's no argument to `raise` from inside a `rescue` clause it figures out that you want to re-raise the exception being handled and not the usual generic `RuntimeError.`) The spot in the program that called `open_user_file` in the first place then has to handle the exception-or not, if it's better to allow it to stop program execution.

Another refinement of handling control flow with exceptions is the `ensure` clause, which executes unconditionally no matter what else happens when an exception is raised.

### *The ensure clause* ###
Let's say you want to read a line from a data file and raise an exception if the line doesn't include a particular substring. If it does include the substring, you want to return the line. If it doesn't, you want to raise `ArgumentError`. But whatever happens, you want to close the file handle before the method finishes.

Here's how you might accomplish this using an `ensure` clause:

```ruby
def line_from_file(filename, substring)
  fh = File.open(filename)
  begin
    line = fh.gets
    raise ArgumentError unless line.include?(substring)
  rescue ArgumentError
    puts "Invalid line!"
    raise
  ensure
    fh.close
  end
  return line
end
```
In this example, the `begin/end` block wraps the line that reads from the file, and the `rescue` clause only handles `ArgumentError`-which means that if something else goes wrong (like the file not existing), it isn't rescued. But if `ArgumentError` is raised based on the test for the inclusion of `substring` in the string `line`, the `rescue` clause is executed.

Moreover, the `ensure` clause is executed whether an exception is raised or not. `ensure` is pegged to the `begin/end` structure of which it's a part, and its execution is unconditional. In this example, we want to ensure that the file handle gets closed. The `ensure` clause takes care of this, whatever else may have happened.

One lingering problem with the `line_from_file` method is that `ArgumentError` isn't the best name for the exception we're raising. The best name would be something like `InvalidLineError`, which doesn't exis. Fortunately, you can create your own exception classes and name them whatever you want.

**NOTE**
There's a better way to open a file, involving a code block that wraps the file operations and takes care of closing the file for you. But one thing at a time, we'll see that technique later on when we look at I/O techniques.

### *Creating your own exception classes* ###
You create a new exception class by inheriting from `Exception` or from a descendant class of `Exception`:

```ruby
class MyNewException < Exception
end
raise MyNewException, "some new kind of error has occurred!"
```
This technique offers two primary benefits. First, by letting you give new names to exception classes, it performs a self-documenting function: when a `MyNewException` gets raised, it's distinct from say, a `ZeroDivisionError` or a plain-vanilla `RuntimeError`.

Second, this approach lets you pinpoint your rescue operations. Once you've created `MyNewException`, you can rescue it by name:

```ruby
class MyNewException < Exception
end
begin
  puts "About to raise exception..."
  raise MyNewException
rescue MyNewException => e
  puts "Just raised an exception: #{e}"
end
```
The output from this snippet is as follows:

```irb
About to raise exception...
Just raised an exception: MyNewException
```
Only `MyNewException` errors will be trapped by that `rescue` clause. If another exception is raised first for any reason, it will result in program termination without rescue.

Here's what our `line_from_file` method would look like with a custom exception-along with the code that creates the custom exception class. We'll inherit from `StandardError`, the superclass of `RuntimeError`:

```ruby
class InvalidLineError < StandardError
end
def line_from_file(filename, substring)
  fh = File.open(filename)
  line = fh.gets
  raise InvalidLineError unless line.include?(substring)
  return line
rescue InvalidLineError
  puts "Invalid line!"
  raise
ensure
  fh.close
end
```

This time around, we'll fully pinpoint the exception we want to intercept.

Simply by inheriting from `StandardError`, `InvalidLineError` provides a meaningful exception name and refines the semantics of the rescue operation. Custom exception classes are easy and cheap to produce and can add considerable value. Ruby itself has lots of exception classes-so take the hint, and don't hesitate to create your own any time you feel that none of the built-in exceptions quite expresses what you need. And don't forget that exceptions are classes, classes are constants, and constants can be namespaced, courtesy of nesting:

```ruby
module TextHandler
  class InvalidLineError < StandardError
  end
end
def line_from_file(filename, substring)
  fh = File.open(filename)
  line = fh.gets
  raise TextHandler::InvalidLineError unless line.include?(substring)   #<-- Nicely namespaced exception name!
```
Namespacing exceptions this way is polite, in the sense that it lets other people name exceptions as they like without fearing name clashes. It also becomes a necessity once you start creating more than a very small number of exception classes.

With our exploration of exceptions and how they're handled, we've reached the end of this examination of control flow. As you've seen, control can jump around a fair amount-but if you keep in mind the different kinds of jumping (conditionals, loops, iterators, and exceptions), you'll be able to follow any Ruby code and write code that makes productive use of the many flow-related techniques available.

## *Summary* ##
In this chapter you've seen

• Conditionals (`if/unless` and `case/when`)

• Loops (`loop`, `for`, `while`, and `until`)

• Iterators and code blocks, including block parameters and variables

• Examples of implementing Ruby methods in Ruby

•Exceptions and exception handling

This chapter has covered several wide-ranging topics, bundled together because they have in common the fact that they involve control flow. Conditionals move control around based on the truth or falsehood of expressions. Loops repeata segment of code unconditionally, conditionally, or once for each item in a list. Iterators-methods that yield to a code block you provide alongside the call to the method-are among Ruby's most distinctive features. You've learned how to write and call an iterator, techniques you'll encounter frequently later in this book (and beyond).

Exceptions are Ruby's mechanism for handling unrecoverable error conditions. *Unrecoverable* is relative: you can rescue an error condition and continue execution, but you have to stage a deliberate intervention via a `rescue` block and thus divert and gain control of the program where otherwise it would terminate. You can also create your own exception classes through inheritance from the built-in Ruby exception classes.

At this point, we'll delve into Ruby's built-in functionality, starting with some general, pervasive features and techniques, and proceeding to specific classes and modules. Not that you haven't seen and used many built-in features already; but it's time to get more systematic and to go more deeply into how the built-ins work. 
