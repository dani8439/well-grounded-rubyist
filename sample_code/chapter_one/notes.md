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
