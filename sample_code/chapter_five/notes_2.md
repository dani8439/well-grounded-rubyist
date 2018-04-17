## *Determining Scope* ##
*Scope* refers to the reach or visibility of identifiers, specifically variables and constants. Different types of identifiers have different scoping rules; using, say, the identifier `x` for a local variable in each of the two method definitions has a different effect than using the global variable `$x` in the same two places, because local and global variables differ as to scope. This section considers three types of variables: global, local, and class variables. (As we've just seen, instance variables are self-bound, rather than scope-bound). We'll also look at the rules for resolving constants.

Self and scope are similar in that they both change over the course of a program, and in that you can deduce what's going on with them by reading the program as well as running it. But scope and self aren't the same thing. You can start a new local scope without self changing-but sometimes scope and self change together. They have in common the fact that they're both necessary to make sense of what your code is going to do. Like knowing which object self is, knowing what scope you're in tells you the significance of the code.

Let's star with global variables-not the most commonly used construct, but an important one to grasp.

### *Global scope and global variables* ###
*Global Scope* is scope that covers the entire program. Global scope is enjoyed by global variables, which are recognizable by their initial dollar-sign (`$`) character. They're available everywhere. They walk through walls: even if you start a new class or method definition, even if the identity of self changes, the global variables you've initialized are still available to you.

In other words, global variables never go out of scope (An exception to this is "thread-local globals", which we'll meet later on.) In this example, a method defined inside a class-definition body (two scopes removed from the outer- or top-level scope of the program) has access to a global variable initialized at the top:

```ruby
$gvar = "I'm a global!"
class C
  def examine_global
    puts $gvar
  end
end
c = C.new
c.examine_global

# I'm a global!
```

You'll be told by `$gvar` in no uncertain terms, "I'm a global!" If you change all the occurrences of `$gvar` to a non-global variable such as `local_var`, you'll see that the top-level `local_var` isn't in scope inside the method definition block.

```ruby
class_c_2.rb:4:in `examine_global': undefined local variable or method `local_var' for #<C:0x000000010950f0> (NameError)
Did you mean?  local_variables
        from class_c_2.rb:8:in `<main>'
```
### BUILT-IN GLOBAL VARIABLES ###

The Ruby interpreter starts up with a fairly large number of global variables already initialized. These variables store information that's of potential use anywhere and everywhere in your program. For example, the global variable `$0` contains the name of the startup file for the currently running program. The global `$:` (dollar sign followed by a colon) contains the directories that make up the path Ruby searches when you load an external file. `$$` contains the process ID of the Ruby process. And there are more.

**TIP**
To see descriptions of all the built-in global variables you're likely to need - can look them up in the file English.rb in your Ruby installation.

Creating your own global variables can be tempting, especially for beginning programmers and people learning a new language (not just Ruby either). But that's rarely a good or appropriate choice.

### PROS AND CONS OF GLOBAL VARIABLES ###
Globals appear to solve lots of design problems: you don't have to worry about scope, and multiple classes can share information by stashing it in globals rather than designing objects that have to be queried with method calls. Without doubt, global variables have a certain allure.

But they're used very little by experienced programmers. The reasons for avoiding them are similar to the reasons they're tempting. Using global variables tends to end up being a substitute for solid, flexible program design, rather than contributing to it. One of the main points of object-oriented programming is that data and actions are encapsulated in objects. You're *supposed* to have to query objects for information and to request that they perform actions.
