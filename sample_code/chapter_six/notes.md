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

### THE ELSE AND ELSIF KEYWORDS ###
You can provide an `else` branch in your `if` statement as follows:

```ruby
if condition
  # code executed if condition is true
else
  # code executed if condition is false
end
```

There's also an `elsif` keyword (spelled like that, with no second *e*). `elsif` lets you cascade your conditional logic to more levels than you can with just `if` and `else`:

```ruby
if condition1
  # code executed if condition1 is true
elsif condition1
  # code executed if condition1 is false
  # and condition2 is true
elsif condition3
  # code executed if neither condition1
  # nor condition2 is true, but condition3 is
end
```
You can have any number of `elsif` clauses in a given `if` statement. The code segment corresponding to the first successful `if` or `elsif` is executed, and the rest of the statement is ignored:

```ruby
print "Enter an integer: "
n = gets.to_i
if n > 0
  puts "Your number is positive."
elsif n < 0
  puts "Your number is negative."
else
  puts "Your number is zero."
end
```
Note that you can use a final `else` even if you already have one or more `elsif`s. The `else` clause is executed if none of the previous tests for truth has succeeded. If none of the conditions is true and there's no `else` clause, the whole `if` statement terminates with no action.

Sometimes you want an `if` condition to be negative: *if something isn't true, then execute a given segment of code.* You can do this in several ways.

### NEGATING CONDITIONS WITH NOT AND ! ###
One way to negate a condition is to use the `not` keyword:

`if not (x == 1)`

You can also use the negating `!` (exclamation point, or *bang*) operator:

`if !(x == 1)`

Both of these examples use parentheses to set apart the expression being tested. You don't need them in the first example; you can do this:

`if not x == 1`

But you *do* need the parentheses in the second example, because the negating `!` operator has higher precedence than the `==` operator. In other words, if you do this

`if !x == 1`

you're really in effect comparing the negation of `x` with the integer `1`:

`if (!x) == 1`

The best practice is to use parentheses most or even all of the time when writing constructs like this. Even if they're not strictly necessary, they can make it easier for you and others to understand your code and to modify it later if necessary.

A third way to express a negative condition is with `unless`.

### THE UNLESS KEYWORD ###
The `unless` keyword provides a more natural-sounding way to express the same semantics as `if not` or `if !`:

`unless x == 1`

But take "natural-sounding" with a grain of salt. Ruby programs are written in Ruby, not English, and you should aim for good Ruby style without worrying unduly about how your code reads as English prose. Not that English can't occasionally guide you; for instance, the `unless/else` sequence, which does a flip back from a negative to a positive not normally associated with the use of the word *unless*, can be a bit hard to follow:

```ruby
unless x > 100
  puts "Small number!"
else
  puts "Big number!"
end
```

In general, `if/else` reads better than `unless/else`- and by flipping the logic of the condition, you can always replace the latter with the former:

```ruby
if x <= 100
  puts "Small number!:"
else
  puts "Big number!"
end
```

If you come across a case where negating the logic seems more awkward than pairing `unless` with `else`, then keep `unless`. Otherwise, if you have an `else` clause, `if` is generally a better choice than `unless`.

You can also put conditional tests in *modifier* position, directly after a statement.

## **Life without the dangling `else` ambiguity** ##
In some languages, you can't tell which `else` clause goes with which `if` clause without a special rule. In C, for example, an `if` statement might look like this:

```ruby 
if (x)
  if (y) { execute this code }
  else { execute this code };    #<--- x is true, but y isn't.
end
```
But wait: Does the code behave the way the indentation indicates (the `else` belongs to the second `if`)? Or does it work like this?

```ruby
if (x)
  if (y) { execute this code }
else { execute this code };        #<--- x isn't true
end
```
All that's changed is the indentation of the third line (which doesn't matter to the C compiler; the indentation just makes the ambiguity visually obvious). Which `if` does the `else` belong to? And how do you tell?

You tell by knowing the rule in C: a dangling `else` goes with the last unmatched `if` (the first of the two behaviors in this example). But in Ruby, you have `end` to help you out:

```ruby 
if x > 50 
  if x > 100 
    puts "Big number"
  else
    puts "Medium number"
  end
end
```
The single `else` in this statement has to belong to the second `if`, because that `if` hasn't yet hit its `end`. The first `if` and the last `end` always belong together, the second `if` and the second-to-last `end` always belong together, and so forth. The `if/end` pairs encircle what belongs to them, including `else`. Of course, this means you have to place your `end` keywords correctly.

### CONDITIONAL MODIFIERS ###
It's not uncommon to see a conditional modifier at the end of a statement in a case like this one:

`puts "Big number!" if x > 100`

This is the same as:

```ruby
if x > 100
  puts "Big number!"
end
```
You can also do this with `unless`:

`puts "Big number!" unless x <= 100`

Conditional modifiers have a conversational tone. There's no `end` to worry about. You can't do as much with them (no `else` or `elsif` branching, for example), but when you need a simple conditional, they're often a good fit. Try to avoid really long statements that end with conditional modifiers, though; they can be hard to read and hard to keep in your head while waiting for the modifier at the end:

`puts "done" && return (x > y && a < b) unless c == 0` <-- Potentially confusing tacking on of an  unless to an already-long line.

Like other statements in Ruby, every `if` statement evaluates to an object. Let's look at how that plays out.

### THE VALUE OF IF STATEMENTS ###
If an `if` statement succeeds, the entire statement evaluates to whatever is represented by the code in the successful branch. Type this code into irb and you'll see the principle in action:

```irb
x = 1
if x < 0
  "negative"
elsif x > 0
  "positive"
else
  "zero"
```
As irb will tell you, the value of that entire `if` statement is the string "`positive`".

An `if` statement that doesn't succeed anywhere returns `nil`. Here's a full irb example of such a case:

```irb
>> x = 1
=> 1
>> if x == 2
>>    "it's 2!"
>> elsif x == 3
>>    "it's 3!"
>> end
=> nil    <-- Entire if statement evaluates to nil because it fails
```
Conditional statements interact with other aspects of Ruby syntax in a couple of ways that you need to be aware of-in particular, with assignment syntax. It's worth looking in some detail at how conditionals behave in assignments, because it involves some interesting points about how Ruby parses code.

## *Assignment syntax in condition bodies and tests* ##
Assignment syntax and conditional expressions cross paths at two points: in the bodies of conditional expressions, where the assigments may or may not happen at all, and in the conditional tests themselves:

```ruby 
if x = 1  #<--- Assignment in conditional test
  y = 2  #<--- Assignment in conditional body
end
```
What happens (or doesn't) when you use these idioms? We'll look at both, starting with variable assignment in the body of the conditional-specifically, local variable assignment, which displays some perhaps unexpected behavior in this context. 

### LOCAL VARIABLE ASSIGNMENT IN A CONDITIONAL BODY ###
Ruby doesn't draw as clear a line as compiled languages do between "compile time" and "runtime," but the interpreter does parse your code before running it, and certain decisions are made during the process. An important one is the recognition and allocation of local variables.

When the Ruby parser sees the sequence *identifiers, equal-sign,* and *value*, as in this expression,

`x = 1`

it allocates space for a local variable called `x`. The creation of the variable-not the assignment of a value to it, but the internal creation of a variable-always takes place as a result of this kind of expression, even if the code isn't executed!
Consider this example:

```ruby 
if false
  x = 1
end
p x   #<--- Output: nil
p y   #<--- Fatal error: y is unknown
```
The assignment to `x` isn't executed, because it's wrapped in a failing conditional test. But the Ruby parser sees the sequence `x = 1`, from which it deduces that the program involves a local variable `x`. The parser doesn't care whether `x` is ever assigned to a value. Its job is just to scour the code for local variables for which space needs to be allocated. 

The result is that `x` inhabits a strange kind of variable limbo. It has been brought into being and initialized to `nil`. In that respect, it differs from a variable that has no existence at all; as you can see in the example, examining `x` gives you the value `nil`, whereas trying to inspect the nonexistent variable `y` results in a fatal error. But although `x` exists, it hasn't played any role in the program. It exists only as an artifact of the parsing process.

None of this happens with class, instance, or global variables. All three of those variable types are recognizable by their appearance (`@@x, @x, $x`). But local variables look just like method calls. Ruby needs to apply some logic at parse time to figure out what's what, to as great an extent as it can.

You also have to keep your wits about you when using assignment syntax in the test part of a conditional.

### ASSIGNMENT IN A CONDITIONAL TEST ### 
In this example, not that the conditional test is an assignment (`x = 1`) and not an equality test (which would be `x==1`):

```ruby 
if x = 1
  puts "Hi!"
end
```
The assignment works as assignments generally do: `x` gets set to `1`. The test, therefore, reduces to `if 1`, which is true. Therefore, the body of the conditional is executed, and the string `"Hi!"` is printed.

But you also get a warning:

`warning: found = in conditional, should be ==`

Ruby's thinking in a case like this is as follows. The test expression `if x = 1` will always succeed, and the conditional body will always be executed. That means there's no conceivable reason for a programmer ever to type `if x = 1`. Therefore, Ruby concludes that you almost certainly meant to type something else and issues the warning to alert you to the probable mistake. Specifically, the warning suggests the `==` operator, which produces a real test (that is, a test that isn't necessarily always true).

What's particularly nice about this warning mechanism is that Ruby is smart enough not to warn you in cases where it's not certain that the condition will be true. If the right-hand side of the assignment is itself a variable or method call, then you don't get the warning:

`if x = y`  <--- **No warning**

Unlike `x = 1`, the assignment expression `x = y` may or may not succeed as a conditional test. (It will be false if `y` is false.) Therefore, it's not implausible that you'd test that expression, so Ruby doesn't warn you.

Why would you want to use an assigment in a conditional test? You certainly never have to; you can always do this:

```ruby 
x = y
if x
#etc
```
But sometimes it's handy to do the assigning and testing at the same time, particularly when you're using a method that returns `nil` on failure and some other value on success. A common example is pattern matching with the `match` method. This method, which you'll see a lot more of in chapter 11, tests a string against a regular expression, returning `nil` if there's no match and an instance of `MatchData` if there is one. The `MatchData` object can be queried for information about the specifics of the match. Note the use of a literal regular expression, `/la/`, in the course of testing for a match against the string `name`:

```ruby 
name = "David A. Black"
if m = /la/.match(name)    #<--- (#1).
  puts "Found a match!"
  print "Here's the unmatched start of the string: "
  puts m.pre_match 
  print "Here's the unmatched end of the string: "
  puts m.post_match 
else 
  puts "No match"
end
```
The output from this snippet is

```irb 
Found a match!
Here's the unmatched start of the string: David A. B
Here's the unmatched end of the string: ck
```
The match method looks for the pattern `la` in the string `"David A. Black"`. The variable `m` is assigned in the conditional(#1) and will be `nil` if there's no match. The deck is stacked in the example, of course: there's a match, so `m` is a `MatchData` object and can be queried. In the example, we ask it about the parts of the string that occurred before and after the matched part of the string, and it gives us the relevant substrings.

As always, you could rewrite the assignment and the conditional test like this:

```ruby 
m = /la/.match(name)
if m 
  # etc
end
```
You don't have to combine them into one expression. But at least in this case there's some semantic weight to doing so: the expression may or may not pass the conditional test, so it's reasonable to test it.

Althought `if` and friends are Ruby's bread-and-butter conditional keywords, they're not the only ones. We'll look next at `case` statements.
