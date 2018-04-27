## Repeating Action with Loops ##
Ruby's facilities for looping repeatedly through code also allow you to incorporate conditional logic: you can loop *while* a 
given condition is true (such as a variable being equal to a given value), and you can loop *until* a given condition is true. 
You can also break out of a loop *unconditionally*, terminating the loop at a certain point, and resume execution of the program 
after the loop.

We'll look at several ways to loop-starting, appropriately with a method called `loop`.

### *Unconditional looping with the loop method* ###
The `loop` method doesn't take any normal arguments: you just call it. It does, however, take a code block-that is, a delimited set of program instructions, written as part of the method call (the call to `loop`) and available to be executed *from* the method. (We'll look at code blocks in much more detail later in this chapter. Can get by with just the placeholder level of knowlege here.) The anatomy of a call to `loop`, then, looks like this:

`loop codeblock`

Code blocks can be written in one of two ways: either in curly braces (`{}`) or with the keywords `do` and `end`. The following two snippets are equivalent:

```ruby
loop { puts "Looping forever!" }

loop do 
  puts "Looping forever!"
end
```
A loose convention holds that one-line code blocks use the curly braces, and multiline blocks use `do/end`. But Ruby doesn't enforce this convention. (The braces and the `do/end` pair do, in fact, differ from each other slightly in terms of precedence. We don't have to worry about that now.)

Generally, you don't want a loop to loop forever; you want it to stop at some point. You can usually stop by pressing Ctrl-C, but there are other, more programmatic ways too.

### CONTROLLING THE LOOP ###
One way to stop a loop is with the `break` keyword, as in this admittedly verbose approach to setting `n` to 10:

```ruby
n = 1
loop do
  n = n + 1
  break if n > 9
end
```
Another technique skips to the next iteration of the loop without finishing the current iteration. To do this, you use the keyword `next`

```ruby
n = 1
loop do 
  n = n + 1
  next unless n == 10
  break
end
```
Here, control falls through to the `break` statement only if `n == 10 ` is true. If `n == 10` is *not* true (`unless n == 10`), the `next` is executed, and control jumps back to the beginning of the loop before it reaches `break`.

You can also loop conditionally: *while* a given condition is true or *until* a condition becomes true.

## *Conditional looping with the while and until keywords* ##
Conditional looping is achieved via the keywords `while` and `until`. These keywords can be used in any of several ways, depending on exactly how you want the looping to play out.

### THE WHILE KEYWORD ###
The `while` keyword allows you to run a loop while a given condition is true. A block starting with `while` has to end with `end`.  The code between `while` and `end` is the body of the `while` loop. Here's an example:

```ruby
n = 1
while n < 11
  puts n
  n = n + 1
end
puts "Done!"
```
The code prints the following:

```irb
1
2
3
4
5
6
7
8
9
10
Done!
```
As long as the condition `n < 11` is true, the loop executes. With each iteration of the loop, `n` is incremented by 1. The eleventh time the condition is tested, it's false (`n` is no longer less than 11), and the execution of the loop terminates.

You can also place `while` at the end of a loop. In this case, you need to use the keyword pair `begin/end` to mark where the loop is (otherwise, Ruby won't know how many of the lines previous to the `while` you want to include in the loop):

```ruby
n = 1
begin
  puts n
  n = n + 1
end while n < 11
puts "Done!"
```
The output from this example is the same as the output from the previous example. There's a difference betweet putting `while` at the beginning and putting it at the end. If you put `while` at the beginning, and if the `while` condition is false, the code isn't executed:

```ruby
n = 10
while n < 10
  puts n
end
```
Because `n` is already greater than 10 when you test `n < 10` is performed the first time, the body of the statement isn't executed. But if you put the `while` test at the end,

```ruby
n - 10
begin
  puts n
end while n < 10
```
the number 10 is printed. Obviously, `n` isn't less than 10 at any point. But because the `while` test is positioned at hte end of the statement, the body is executed once before the test is performed. Like `if` and `unless`, the conditional loop keywords come as a pair: `while` and `until`.

### THE UNTIL KEYWORD ###
The `until` keyword is used the same way as `while` but with reverse logic. Here's another labor-intensive way to print out the integers from 1 to 10, this time illustrating the use of `until`.

```
n = 1
until n > 10
  puts n
  n = n + 1
end
```
The body of the loop (the printing and incrementing of `n` in this example), is executed repeatedly until the condition is true.

You can also use `until` in the post-block position, in conjunction with a `begin/end` pairing. As with `while`, the block will execute once before the `until` condition is tested. Like their cousins `if` and `unless`, `while` and `until` can be used in a modifier position in one-line statements.

### THE WHILE AND UNTIL MODIFIERS ###
Here's a slightly shorter way to count to 10, using `until` in a modifier position:

```ruby
n = 1
n = n + 1 until n == 10
puts "We've reached 10!"
```
In place of the `until` statement, you could also use `while n < 10`.

Note that the one-line modifier versions of `while` and `until` don't behave the same way as the post-positioned `while` and `until` you use with a `begin/end` block. In other words, in a case like this

```ruby
a = 1
a += 1 until true
```
`a` will still be 1; the `a += 1` statement won't be executed, because `true` is already true. But in this case:

```ruby 
a = 1
begin
  a += 1
end until true
```
the body of the `begin/end` block does get executed once.

In addition to looping unconditionally (`loop`) and conditionally (`while`,`until`) you can loop through a list of values, running the loop once for each value. Ruby offers several ways to do this, one of which is the keyword `for`.
