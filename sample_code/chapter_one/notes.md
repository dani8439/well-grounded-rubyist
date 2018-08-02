# *Bootstrapping your Ruby literacy* #

## *Basic Ruby language literacy* ##

**The interactive Ruby console program (irb) is your new best friend**

```irb 
irb --simple-prompt
```
Will make irb output easier to read. 

### *A Ruby syntax survival kit* ### 

#### Basic operations in Ruby ####
|   Operation         |           Example(s)          |                                 Comments                                        |
|---------------------|-------------------------------|---------------------------------------------------------------------------------|
| Arithmetic          | `2 + 3` (addition)            | All of these operations work on integers or floating point numbers (*floats*). Mixing integers and floats together, as some of the examples do, produces a floating-point result.              
|                     | `2 - 3` (subtraction)         |         
|                     | `2 * 3` (multiplication)      |                                           
|                     | `2/3` (division)              |                                                                                 |
|                     | `10.3 + 20.25`                |                                                                                 |
|                     | `103 - 202.5`                 |                                                                                 |
|                     | `32.9 * 10`                   |                                                                                 |
|                     | `100.0/0.23`                  | Note that you need to write `0.23` rather than `.23`                            |
| Assignment          | `x = 1`                       | This operation binds a local variable (on the left) to an object (on the right). For now you can think of an object as a value represented by the variable.                   
|                     | `string = "Hello"`            | 
|                     |                               |                                                                 
| Compare two values  | `x == y`                      | Note the two equal signs (not just one, as in assignment).                      |
| Convert a numeric   | `x = "100".to_i`              | To perform arithmetic, you have to make sure you
| string to a number  | `s = "100"`                   | have numbers rather than strings of characters.
|                     | `x = s.to_i`                  | `to_i` performs string-to-integer conversion.                                   |

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
