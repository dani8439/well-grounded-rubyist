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

