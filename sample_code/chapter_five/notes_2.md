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

And objects are supposed to have a certain privacy. When you ask an object to do something, you're not supposed to care what the object does internally to get the job done. Even if you yourself wrote the code for the object's methods, when you send the object a message, you treat the object as a black box that works behind the scenes and provides a response.

Global variables distort the landscape by providing a layer of information shared by every object in every context. The result is that objects stop talking to each other and, instead, share information by setting global variables.

Here's a small example-a rewrite of our earlier `Person` class (the one with the first, optional middle, and last names). This time, instead of attributes on the object, we'll generate the whole name from globals:

```ruby
class Person
  def whole_name
    n = $first_name + " "
    n << "#{$middle_name} " if $middle_name
    n << $last_name
  end
end
```

To use this class and to get a whole name from an instance of it, you'd have to do this:

```ruby
david = Person.new
$first_name = "David"
$middle_name = "Alan"
$last_name = "Black"
puts david.whole_name

# Output: David Alan Black
```

This version still derives the whole name, from outside, by querying the object. But the components of the name are handed around over the heads of the object, so to speak, in a separate network of global variables. It's concise and easy, but it's also drastically limited. What would happen if you had lots of `Person` objects, or if you wanted to save a `Person` object, including its various names, to a database? Your code would quickly become tangles to say the least.

Globally scoped date is fundamentally in conflict with the object-oriented philosophy of endowing objects with abilities and then getting things done by sending requests to those objects. Some Ruby programmers work for years and never use a single global variable (except perhaps a few of the built-in ones). That may or may not end up being your experience, but it's not a bad target to aim for.

Now that we've finished with the "try not to do this" part, let's move on to a detailed consideration of local scope.

## *Local Scope* ##
*Local Scope* is a basic layer of the fabric of every Ruby program. At any given moment, your program is in a particular local scope. The main thing that changes from one local scope to another is your supply of local variables. When you leave a local scope-by returning from a method call, or by doing something that triggers a new local scope-you get a new supply. Even if you've assigned to a local variable `x` in one scope, you can assign to a new `x` in a new scope, and the two `x`'s won't interfere with each other.

You can tell by looking at a Ruby program where the local scopes begin and end, based on a few rules:

• The top level (outside all definition blocks) has its own local scope.

• Every class or module-definition block (`class`, `module`) has its own local scope, even nested class-/module-definition blocks.

• Every method definition (`def`) has its own local scope; more precisely, every call to a method generates a new local scope, with all local variables reset to an undefined state.

Exceptions and additions to these rules exist, but they're fairly few and don't concern us right now.
