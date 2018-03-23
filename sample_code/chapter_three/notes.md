# Organizing Objects with classes #

*Note* Methods that you define for one particular object - as in `def ticket.price` - are called *singleton methods*. You've already seen examples, and we'll look more in depth at how singleton methods work in chapter 13. An object that has a `price` method doesn't care whether it's calling a singleton method or an instance method of its class. But the distinction is important from the programmer's perspective

# Setter Methods #

*Tip* The percent sign technique (`$#{"%.2f" % ticket.price}`) allows you to format strings using `sprintf`-like syntax. Ruby also has a `sprintf` method (also available with the name `format`); we could rewrite the ticket price example as `sprintf("%.2f", ticket.price)`. Possible format specifiers (the `%` things inside the pattern string) include `%d` for decimal numbers, `%s` for strings, `%f` for floats, and `%x` for hexadecimal numbers. Run `ri sprintf` for full documentation.

Ruby allows you to define methods that end with an equal sign (=). Let's replace set_price with a method
called `price=`("price" plus an equal sign):

`def price=(amount)`

  `@price = amount`
  
`end`
