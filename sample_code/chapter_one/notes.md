# *Bootstrapping your Ruby literacy* #

## *Basic Ruby language literacy* ##

**The interactive Ruby console program (irb) is your new best friend**

```irb 
irb --simple-prompt
```
Will make irb output easier to read. 

### *A Ruby syntax survival kit* ### 

#### Basic operations in Ruby ####
|   Operation         |           Example(s)          |                                 Comments                          |
|---------------------|-------------------------------|-------------------------------------------------------------------|
| Arithmetic          | `2 + 3` (addition)            | All of these operations work on integers or floating point        |             
|                     | `2 - 3` (subtraction)         | numbers (*floats*). Mixing integers and floats together, as       |
|                     | `2 * 3` (multiplication)      |some of the examples do, produces a floating-point result.         
|                     | `2/3` (division)              |                                                                   |
|                     | `10.3 + 20.25`                |                                                                   |
|                     | `103 - 202.5`                 |                                                                   |
|                     | `32.9 * 10`                   |                                                                   |
|                     | `100.0/0.23`                  | Note that you need to write `0.23` rather than `.23`              |
| Assignment          | `x = 1`                       | This operation binds a local variable (on the left) to an         |
|                     | `string = "Hello"`            | object (on the right). For now you can think of an object         |
|                     |                               | as a value represented by the variable.            
| Compare two values  | `x == y`                      | Note the two equal signs (not just one, as in assignment).        |
| Convert a numeric   | `x = "100".to_i`              | To perform arithmetic, you have to make sure you
| string to a number  | `s = "100"`                   | have numbers rather than strings of characters.
|                     | `x = s.to_i`                  | `to_i` performs string-to-integer conversion.                     |

#### Basic input/output methods and flow control in Ruby #### 
|        Operation          |     Example(s)             |                         Comments                                |
|---------------------------|----------------------------|-----------------------------------------------------------------|
| Print something to the screen    |`print "Hello"`  | `puts` adds a newline to the string it outputs if there             |
|                           |`puts "Hello"`               | isn't one at the end already; `print` doesn't.                 |
|                           |`x = "Hello"`                | `print` prints exactly what it's told to and leaves            |
|                           |`puts x`                     | the cursor at the end. (Note: on some platforms, an            |
|                           |`x = "Hello"`                | extra line is automatically output at the end of a             |
|                           |`print x`                    | program.)                                                      |
|                           |`x = "Hello"`                | `p` outputs an inspect string, which may contain extra         |
|                           |`p x`                        | information about what it's printing.                          |
|Gets a line of keyboard input | `gets`                   | You can assign the input line directly to a variable           |
|                           | `string = gets`             | (the variable `string` in the second example.                  |
|Conditional execution      |`if x == y`                  | Conditional statements always end with the word `end`          |
|                           | `puts "Yes!"`               | More on these in chapter 6.                                    |
|                           | `else`                      |                                                                |
|                           | `puts "No!"`                |                                                                |
|                           | `end`                       |                                                                |


#### Ruby's special objects and comment ###
|       Operation           |     Example(s)              |                          Comments                              |
|---------------------------|-----------------------------|----------------------------------------------------------------|
| Special value objects     | `true`                      | The objects `true` and `false` often serve as return values for conditional expressions. The object `nil` is a kind of "nonobject" indicating the absence of a value or result. `false` and `nil` cause a conditional expression to fail; all other objects (including `true`, of course, but also including `0` and empty strings) cause it to succeed. More on this in chapter 7.  
|                           | `false`                     | 
|                           | `nil`                       | 
| Default object            | `self`                      | The keyword `self` refers to the default object. Self is a role that different objects play, depending on the execution context. Method calls that don't specify a calling object are called on `self`. More on this in chapter 5. 
| Put commends in code files | `# A comment`              | Comments are ignored by the interpreter.                       |
|                            | `x = 1 # A comment`        |                                                                |

### *The variety of Ruby identifiers* ###

• Variables:

  -Local
  
  -Instance
  
  -Class 
  
  -Global 
 
• Constants 

• Keywords

• Method names

#### VARIABLES #### 
*Local variables* start with a lowercase letter or an underscore and consist of letters, underscores, and/or digits, `x`, `string`, `abc`, `start_value`, and `firstName` are all valid local variable names. Note, however, that the Ruby convention is to use underscores rather than camel case when composing local variable names from multiple words-for example, `first_name` rather than `firstName`. 

*Instance variables,* which serve the purpose of storing information for individual objects, always start with a singlt at sign (`@`) and consist thereafter of the same character set as local variables-for example, `@age`, and `@last_name`. Although a local variable can't start with an uppercase letter, an instance variable can have one int he first position after the at sign (though it may not have a digit in this position). But usually the character after the at sign is a lowercase letter.

* Class variables,* which store information per class hierarcy (again don't worry about the semantics at this stage), follow the same rules as instance variables, except that htey start with two at signs-for example, `@@running_total`. 

*Global variables* are recognizable by their leading dollar sign (`$`)-for example, `$population`. The segment after the dollar sign doesn't follow local-variable naming convention; there are global variables called `$:`, `$1`, `$/`, as well as `$stdin` and `$LOAD_PATH`. As long as it begins with a dollar sign, it's a global variable. As for the nonalphanumeric ones, the only such identifiers you're likely to see are predefined so you don't need to worry about which punctuation marks are legal and which aren't.

This table summarizes Ruby's variable naming rules:

|   Type    |  Ruby convention    |                                   Nonconventional                                       |
|-----------|---------------------|-----------------------------------------------------------------------------------------|
| Local     |  `first_name`       | `firstName`, `_firstName`, `__firstName`, `name1`                                       |
| Instance  |  `@first_name`      | `@First_name`, `@firstName`, `@name1`                                                   |
| Class     |  `@@first-name`     | `@@First_name`, `@@firstName`, `@@name1`                                                |
| Global    |  `$FIRST_NAME`      | `$first_name`, `$firstName`, `$name1`                                                   |

### CONSTANTS ### 
Constants begin with an uppercase letter. `A`, `String`, `FirstName`, and `STDIN` are all valid constant names. The Ruby convention is to use either camel case (`FirstName`) or underscore-separated all-uppercase words (`FIRST_NAME`) in composing constant names from multiple words.

### KEYWORDS ### 
Ruby has numerous keywords: predefined, reserved terms associated with specific programming tasks and contexts. Keywords include `def` (for method definitions), `class` (for class definitions), `if` (conditional execution), and `__FILE__` (the name of the file currently being executed). THere are about 40 of them, and they're generally short, single-word (as opposed to underscore-composed) identifiers.

### METHOD NAMES ### 
Names of methods in Ruby follow the same rules and conventions as local variables (except that they can end with `?`, `!`, or `=`, with significance you'll see later). This is by design: methods don't call attention to themselves as methods but rather blend into the texture of a program as, simply, expressions that provide a value. In some contexts you can't tell just by looking at an expression whether you're seeing a local variable or a method name-and that's intentional.

## *Method calls, messages, and Ruby objects* ###
Ruby sees all data structures and values-from simple scalar (atomic) values like integers and strings, to complex data structures like arrays- as *objects*. Every object is capable of understanding a certain set of *messages.* Each message that an object understands corresponds directly to a *method*-a named, executable routine whose execution the object has the ability to trigger.

Objects are represented either by literal constructors-like quotation marks for strings-or by variables to which they've been bound. Message sending is achieved via the special dot operator: the message to the right of the dot is sent to the object to the left of the dot. (There are other, more specialized ways to send messages to objects, but the dot is the most common and fundamental way.) Consider this example:

```ruby
x = "100".to_i
```

The dot means that the message `to_i` is being sent to the string `"100"`. The string `"100"` is called the *receiver* of the message. We can also say that the method `to_i` is being *called* o the string `"100"`. The result of the method call-the integer 100-serves as the right-handed side of the assignment to the variable `x`. 

**Why the double terminology?** 
Why bother saying both "sending the message `to_i`" and "calling the method `to_i`"? Why have two ways of describing the same operation? Because they aren't quite the same. Most of the time, you send a message to a receiving object, and the object executes the corresponding method. But sometimes there's no corresponding method. You can put anything to the right of the dot, and there's no guarantee that the receiver will have a method that matches the message you send.

If that sounds like chaos, it isn't, because objects can intercept unknown messages and try to make sense of them. The Ruby on rails web development framework, for example, makes heavy use of the technique of sending unknown messages to objects, intercepting those messages, and making sense of them on the fly based on dynamic conditions like the names of the columns in the tables of the current database.

--

Methods can take *arguments,* which are also objects. (Almost everything in RUby is an object, although some syntactic structures that help you create and manipulate objects aren't themselves objects.) Here's a method call with an argument:

```ruby 
x = "100".to_i(9)
```

Calling `to_i` on 100 with an argument of 9 generates a decimal integer equivalent to the base-nine number 100: `x` is now equal to 81 decimal.

This example also shows the use of parentheses around method arguments. These parentheses are usually optional, but in more ocmplex cases they may be required to clear up what may otherwise be ambiguities in the syntax. Many programmers use parentheses in most or all method calls, just to be safe.

The whole universe of a Ruby program consists of objects and hte messages that are sent to them. As a Ruby programmer, you spend most of your time either specifying the things you want objects to be able to do (by defining methods) or asking the objects to do those things (by sending them messages). 

When you see a dot in what would otherwise be an inexplicable position, you should interpret it as a message (on the right) being sent to an object (on the left). Keep in mind, too, that some method calls take the form of *bareword*-style invocations, like the call to `puts` in this example:

```ruby 
puts "Hello."
```

Here, in spite of the lack of a message-sending dot and an explicit receier for the message, we're sending the message `puts` with the argument `"Hello."` to an object, the default object `self`. There's always a `self` defined when your program is running although which object is `self` changes, according to specific rules.

The most important concept in Ruby is the concept of the object. CLosely related and playing an important supporting role, is the concept of the *class*. 

#### THE ORIGIN OF OBJECTS IN CLASSES ####
*Classes* define clusters of behavior or functionality, and every object is an instance of exactly one class. Ruby provides a large number of built-in classes, representing important foundational data types (classes like `String`, `Array`, and `Fixnum`). Every time you create a string object, you've created an instance of the class `String`.

You can also write your own classes. You can even modify existing RUby classes; if you don't like the behavior of strings or arrays, you can change it. It's almost always a bad idea to do so, but Ruby allows it. (We'll look at the pros and cons of making changes to built in classes in chapter 13).

Although every Ruby object is an instance of a class, the concept of class is less important than the concept of object. That's because objects can change, acquiring methods and behaviors that weren't defined in their class. The class is responsible for launching the object into existence, a process known as *instantiation*; but the object, thereafter, as a life of its own. 

The ability of objects to adopt behaviors that their class didn't give them is one of the most central defining principles of the design of Ruby as a language. As you can surmise, we'll come back to it frequently in a variety of contexts. For now, just be aware that although every object has a class, the class of an object isn't the sole determinant of what the object can do.

Armed with some Ruby literacy (and some material to refer back to when in doubt), let's walk through the steps involved in running a program. 

## *Writing and saving a simple program* ## 
At this point, you can start creating program files in the Ruby sample code directory you created a little while back. Your first program will be a Celsius-to_Fahrenheit temperature converter.

**Note** A real-world temperature converter would, of course, use floating-point numbers. We're sticking to integers in the input and ouput to keep the focus on matters of program structure and execution.

We'll work through this example several times, adding to it and modifying as we go. Subsequent iterations will

• Tidy the program's output 

• Accept input via the keyboard from the user 

• Read a value in from a file 

• Write the result of the program to a file 

The first version is simple; the focus is on the file-creation and program-running processes, rather than any elaborate program logic.

#### CREATING A FIRST PROGRAM FILE #### 
Using a plain-text editor, type the code from the following listing into a text file and save it under the filename c2f.rb in your sample code directory.

```ruby
celsius = 100
fahrenheit = (celsius * 9 / 5) + 32
puts "The result is: "
puts fahrenheit 
puts "."
```
**NOTE** Depending on your operating system, you may be able to run Ruby program files standalone-that is, with just the filename, or with a shorter name (like c2f) and no file extension. Keep in mind, though, that the .rb filename extension is mandatory in some cases, mainly involving programs that occupy more than one file (which you'll learn about in detail later) and that need a mechanism for the files to find each other. In this book, all Ruby program filenames end in .rb to ensure that hte examples work on as many platforms and with as few administrative digressions, as possible.

You now have a complete (albeit tiny) Ruby program on your disk, and you can run it. 

### *Feeding the program to Ruby* ### 
Running a Ruby program involves passing the program's source file (or files) to the Ruby interpreter, which is called `ruby`. You'll do that now... sort of. You'll feed the program to `ruby`, but instead of asking RUby to run the program, you'll ask it to check the program code for syntax errors.

#### CHECKING FOR SYNTAX ERRORS #### 
If you add 31 instead of 32 in your conversion formula, that's a programming error. Ruby will still happily run your program and give you the flawed result. But if you accidentally leave out the closing parenthesis in the second line of the program, that's a syntax error, and Ruby won't run the program:

```irb
$ ruby broken_c2f.rb 
broken_c2f.rb:5: syntax error. unexpected end-of-input, expecting ')'
```
(The error is reported on line 5-the last line of the program-because Ruby waits paitiently to see whether you're ever going to close the parenthesis before concluding that you're not.)

Conveniently, the Ruby interpreter can check programs for syntax errors without running the programs. It reads through the file and tells you whether the syntax is okay. To run a syntax check on your file, do this:

```irb 
$ ruby -cw c2f.rb
```
The `-cw` command-line flag is shorthand for two flats: `-c` and `-w`. The `-c` flag means *check for syntax errors*. The `-w` flag activates a higher level of warning: Ruby will fuss at you if you've done things that are legal RUby but are questionable on grounds other than syntax.

Assuming you've typed the file correctly, you should see the message:

```irb 
Syntax OK 
```
printed on your screen.

#### RUNNING THE PROGRAM #### 
To run the program, pass the file once more to the interpreter, but this time without the combined `-c` snd `-w` flags:

```irb
$ ruby c2f.rb
```
If all goes well, you'll see the output for the calculation:

```irb
The result is 
212
.
```
The result of the calculation is correct, but the output spread over three lines looks bad.

#### SECOND CONVERTER ITERATION #### 
The problem can be traced to the difference between the `puts` command and the `print` command. `puts` adds a newline to the end of the string it prints out, if the string doesn't end with one already. `print`, on the other hand, prints out the string you ask it to and then stops; it doesn't automatically jump tot he next line.

To fix the problem, change the first two `puts` commands to `print`:

```ruby
print "The result is "
print fahrenheit 
puts "."
```
(Note the black space after `is`, which ensures that a space appears between `is` and th enumber.) Now the output is 

`The result is 212`.

`puts` is short for *put* (that is, print) *string.* Although *put* may not intuitively invoke the notion of skipping down to the next line, that's what `puts` does: like `print`, it prints what you tell it to, but then it also automatically goes to the next line. If you ask `puts` to print a line that already ends iwth a newline, it doesn't bother adding one.

If you're used to print facilities in languages that don't automatically add a newline, such as Perl's `print` function, you may find yourself writing code like this in Ruby when you want to print a value followed by a newline:

```ruby
print fahrenheit, "\n"
```
You almost never have to do this, though, because `puts` adds a newline for you. You'll pick up the `puts` habit, along with other Ruby idioms and conventions, as you go along.

**WARNING** On some platforms (Windows in particular), an extra newline character is printed out at the end of the run of a program. This means a `print` that should really be a `puts` will be hard to detect, because it will act like a `puts`. Being aware of the difference between the two and using the one you want based ont he usual behavior should be sufficient to ensure you get the desired results.

Having looked at a little screen output, let's widen the I/O field a bit to include keyboard input and file operations. 

### *Keyboard and file I/O* ### 
Ruby offers lots of techniques for reading data during the course of program execution, both from the keyboard and from disk files. You'll find uses for them-if not in the course of writing every application, then almost certainly while writing Ruby code to maintain, convert, housekeep, or otherwise manipulate the environment in which you work. We'll look at some of these input techniques here; an expanded look at I/O operations can be found in chapter 12. 

#### KEYBOARD INPUT #### 
A program that tells you over and over again that 100º Celsius equals 212º Fahrenheit has limited value. A more valuable program lets you specify a Celsius temperature and tells you the Fahrenheit equivalent.

Modifying the program to allow for this functionality involves adding a couple of steps and using one method each from first code example, and second code example: `gets` (get a line of keyboard input), and `to_i` (convert to an integer), one of which you're familiar with already. Because this is a new program, not just a correction, put the version from the following listing in a new file: c2f1.rb (the *i* stands for interactive). 

```ruby 
print "Hello. Please enter a Celsius value: "
celsius = gets
fahrenheit = (celsius.to_i * 9 / 5) + 32
print "The Fahrenheit equivalent is "
print fahrenheit
puts "."
````
A couple of sample runs demonstrate the new program in action:

```irb
$ ruby c2fi.rb
Hello. Please Enter a Celsius value: 100
The Fahrenheit equivalent is 212.
$ ruby c2fi.rb
Hello. Please enter a Celsius value: 23
The Fahrenheit equivalent is 73.
```
**Shortening the code**
You can shorten the code in the listing 1.2 considerably by consolidating the operations of input, calculation, and output. A compressed rewrite looks like this:

```ruby
print "Hello. Please enter a Celsius value: "
print "The Fahrenheit equivalent is ", gets.to_i * 9/5 + 32. ".\n"
```
This version economizes on variables-there aren't any-but requires anyone reading it to follow a somewhat denser (but shorter) set of expressions. Any given program usually has several or many spots where you have to decide between longer (but maybe clearer?) and shorter (but perhaps a bit cryptic). And sometimes, shorter cna be clearer. It's all part of developing a Ruby code style.

We now have a generalized, if not terribly nuanced, solution to the problem of converting from Celsius to Fahrenheit. Let's widen the circle to include file input.

#### READING FROM A FILE ####
Reading a file from a Ruby program isn't much more difficult, at least in many cases, than reading a line of keyboard input. The next version of our temperature converter will read one number from a file and convert it from Celsius to Fahrenheit.

First, create a new file called temp.dat (temperature data), containing one line with one number on it:

```dat
100
```
Now create a third program file, called c2fin.rb (*in* for [file] input), as shown in the next listing:

```ruby

puts "Reading Celsius temperature value from data file..."
num = File.read("temp.dat")
celsius = num.to_i
fahrenheit = (celsius * 9 / 5) + 32
puts "The number is " + num 
print "Result: "
puts fahrenheit
```
This time, the sample run and its output look like this:

```
$ ruby c2fin.rb
Reading Celsius temperature value from data file...
The number is 100
Result: 212
```
Naturally, if you change the number in the file, the result will be different.

What about writing the result of the calculation to a file?

#### WRITING TO A FILE ####
The simplest file-writing operation is just a little more elaborate than the simplest file-reading operation. As you can see from the following listing, the main extra step when you write to a file is the specification of a file *mode*-in this case, `w` (for *write*). Save the version of the program from this listing to c2fout.rb and run it.

```ruby
print "Hello. Please enter a Celsius value: "
celsius = gets.to_i
fahrenheit = (celsius * 9 / 5) + 32
puts "Saving result to output file 'temp.out'"
fh = File.new("temp.out", "w")
fh.puts fahrenheit 
fh.close
```
The method call `fh.puts fahrenheit` has the effect of printing the value of `fahrenheit` to the file for which `fh` is a write handle. If you inspect the file temp.out, you should see that it contains the Fahrenheit equivalent of whatever number you typed in.

As an exercise, you might try to combine the previous examples into a Ruby program that reads a number from a file and writes the Fahrenheit conversion to a different file. Meanwhile, with some basic Ruby syntax in place, our next stop will be an examination of the Ruby installation. This, in turn, will equip you for a look at how Ruby manages extensions and libraries.
