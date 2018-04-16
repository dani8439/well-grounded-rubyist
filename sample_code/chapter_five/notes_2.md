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
