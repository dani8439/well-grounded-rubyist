# *Bootstrapping your Ruby literacy* #

## *Basic Ruby language literacy* ##

**The interactive Ruby console program (irb) is your new best friend**

```irb 
irb --simple-prompt
```
Will make irb output easier to read. 

### *A Ruby syntax survival kit* ### 
(See table in book)

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
