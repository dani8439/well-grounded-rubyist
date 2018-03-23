# Organizing Objects with classes #

*Note* Methods that you define for one particular object - as in `def ticket.price` - are called *singleton methods*. You've already seen examples, and we'll look more in depth at how singleton methods work in chapter 13. An object that has a `price` method doesn't care whether it's calling a singleton method or an instance method of its class. But the distinction is important from the programmer's perspective

# Setter Methods #

*Tip* The percent sign technique (`$#{"%.2f" % ticket.price}`) allows you to format strings using `sprintf`-like syntax. Ruby also has a `sprintf` method (also available with the name `format`); we could rewrite the ticket price example as `sprintf("%.2f", ticket.price)`. Possible format specifiers (the `%` things inside the pattern string) include `%d` for decimal numbers, `%s` for strings, `%f` for floats, and `%x` for hexadecimal numbers. Run `ri sprintf` for full documentation.

Ruby allows you to define methods that end with an equal sign (=). Let's replace set_price with a method
called `price=`("price" plus an equal sign):

`def price=(amount)`

` @price = amount`

`end`

`price=` does exactly what `set_price` did, and in spit of the slightly odd method name, you can call it just like any other method:

`ticket.price=(63.00)`

The equal sign gives you that familiar "assigning a value to something" feeling, so you know you're dealing with a setter method. It still looks odd, though; but Ruby takes care of that too


## *Syntactic sugar for assignment-like methods* ##

Programmers use the term *syntactic sugar* to refer to special rules that let you write your code in a way that doesn't correspond to the normal rules but that's easier to remember how to do and looks better.
  Ruby gives you some syntactic sugar for calling setter methods. Instead of

  `ticket.price=(63.00)`

  you're allowed to do this:

  `ticket.price = 63.00`

  When the interpreter sees this sequence of code, it automatically ignores the space before the equal sign and reads `price = ` as the single message `price=` (a call to the method whose name is `price=`, which we've defined). As for the right-hand side, parentheses are optional for method arguments, as long as there's no ambuiguity. SO you can put 63.00 there, and it will be picked up as the argument to the `price=` method.
    The intent behind the inclusion of this special syntax is to allow you to write method calls that look
  like assignments. If you just saw `ticket.price = 63.00` in a program, you might assume that `ticket.price` is some kind of l-value to which the value 63.00 is behing assigned. But it isn't. The whole thing is a method call. THe receiver is `ticket`, the method is `price=`, and the single argument is `63.00`.
    The more you use this setter style of method, the more you'll appreciate how much better the sugared
  version looks. This kind of attention to appearance is typical of Ruby.
    Keep in mind, too, that setter methods can do more than simple variable assignment.

## *Setter methods Unleashed* ##
The ability to write your own =-terminated methods and the fact that Ruby provides the syntactic sugar way of calling those methods open up some interesting possibilities.
  One possibility is abuse. It's possible to write =-terminated methods that look like they're going to do
something involving assignment but don't:

`class Silly`

` def price=(x)`

`   puts "The current time is #{Time.now}"`

` end`

`end`

`s = Silly.new`

`s.price = 111.22`

This example discards the argument it receives (`111.22`) and prints out an unrelated message:

`The  current time is 2014-02-09 09:53:31 -0500`

This example is a deliberate caricature. But the point is important: Ruby checks your syntax but doesn't police your semantics. You're allowed to write methods with names that end with =, and you'll always get the assignment-syntax sugar. Whether the method's name makes any sense in relation to what the method does is in your hands.
  Equal sign methods can also serve as filters or gatekeepers. Let's say we want to set the price of a
ticket only if the price makes sense as a dollar-and-cents amount. We can add intelligence to the `price=` method to ensure the correctness of the data. Here, we'll multiply the number by 100, lop off any remaining decimal-place number with the `to_i` (convert to integer) operation, and compare the result with the original number multiplied by 100. This should expose any extra decimal digits beyond the hundreths column:
