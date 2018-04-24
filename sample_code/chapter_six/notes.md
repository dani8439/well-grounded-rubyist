# *Control-flow technique* #

Ruby's control-flow techniques include the following:

• *Conditional execution* - Execution depends on the truth of an expression. 

• *Looping* - A single segment of code is executed repeatedly.

• *Iteration* - A call to a method is supplemented with a segment of code that the method can call one or more times during its own execution. 

• *Exceptions* - Error conditions are handled by special control-flow rules. 

They're all indespensible to both the understanding and the practice of Ruby. The first, condition execution (`if` and friends), is a fundamental and straightforward programming tool in almost any programming language. Looping is a more specialized but closely related technique, and Ruby provides you with several ways to do it. When we get to iteration, we'll be in true Ruby hallmark territory. The technique isn't unique to Ruby, but it's a relatively rare programming language feature that figures prominently in Ruby. Finally, we'll look at Ruby's extensive mechanism for handling error conditions through exceptions. Exceptions stop the flow of a program, either completely or until the error condition has been dealt with. Exceptions are objects, and you can create your own exception classes, inheriting from the ones built in to Ruby, for specialized handling of error conditions in your programs.

## *Conditional code execution* ## 
*Allow a user access to a site if the password is corred. Print an error message unless the requested item exists. Concede defeat if the king is checkmated.* The list of uses for controlling the flow of a program conditionally-executing specific lines or segments of code only if certain conditions are met-is endless. Without getting too philosophical, we might even say that decision making based on unpredictable but discernible conditions is as common in programming as it is in life. 

Ruby gives you a number of ways to control program flow on a conditional basis. The most important ones fall into two categories:

• `if` and related keywords.

• Case statements. 

We'll look at both in this section. 

### *The if keyword and friends* ###
The workhorse of conditional execution, not surprisingly, is the `if` keyword. `if` clauses can take serveral forms. The simplest is the following: 

```ruby 
if condition 
  # code here, executed if condition is true
end
```

The code inside the conditional can be any length and can include nested conditional blocks. 

You can also put an entire `if` clause on a single line, using the `then` keyword after the condition: 

`if x > 10 then puts x end`

You can also use semicolons to mimic the line breaks, and to set off the `end` keyword:

`if x > 10; puts x; end`

Conditional execution often involves more than one branch; you may want to do one thing if the condition succeeds and another if it doesn't. For example, *if the password is correct, let the user in; otherwise pring an error message.* Ruby makes full provisions for multiple conditional branches, using `else` and `elsif`.

