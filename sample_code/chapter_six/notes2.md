## Repeating Action with Loops ##
Ruby's facilities for looping repeatedly through code also allow you to incorporate conditional logic: you can loop *while* a given condition is true (such as a variable being equal to a given value), and you can loop *until* a given condition is true. You can also break out of a loop *unconditionally*, terminating the loop at a certain point, and resume execution of the program
after the loop.

We'll look at several ways to loop-starting, appropriately with a method called `loop`.

### *Unconditional looping with the loop method* ###
The `loop` method doesn't take any normal arguments: you just call it. It does, however, take a code block-that is, a delimited set of program instructions, written as part of the method call (the call to `loop`) and available to be executed *from* the method. (We'll look at code blocks in much more detail later in this chapter. Can get by with just the placeholder level of knowledge here.) The anatomy of a call to `loop`, then, looks like this:

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
The output from this example is the same as the output from the previous example. There's a difference between putting `while` at the beginning and putting it at the end. If you put `while` at the beginning, and if the `while` condition is false, the code isn't executed:

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
the number 10 is printed. Obviously, `n` isn't less than 10 at any point. But because the `while` test is positioned at the end of the statement, the body is executed once before the test is performed. Like `if` and `unless`, the conditional loop keywords come as a pair: `while` and `until`.

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

### *Looping based on a list of values* ###
Let's say you want to print a chart of Fahrenheit equivalents of Celsius values. You can do this by putting the Celsius values in an array and then looping through the array using the `for/in` keyword pair. The loop runs once for each value in the array; each time through, that value is assigned to a variable when you specify:

```ruby
celsius = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
puts "Celsius\tFahrenheit" #<--- Header for chart (\t prints a tab)
for c in celsius
  puts "#{c}\t#{Temperature.c2f(c)}"
end
```
The body of the loop (the `puts` statement) runs 11 times. The first time through, the value of `c` is `0`. The second time, `c`, is `10`; the third time, it's `20`; and so forth.

`for` is a powerful tool. Oddly enough, though, on closer inspection it turns out that `for` is just an alternate way of doing something even more powerful.

## *Iterators and code blocks* ##
The control-flow techniques we've looked at so far involve controlling how many times or under what conditions, a segment of code gets executed. In this section, we'll examine a different kind of control-flow facility. The techniques we'll discuss here don't just perform an execute-or-skip operation on a segment of code; they bounce control of the program from one scope to another and back again, through *iteration*.

### *The ingredients of iteration* ###
In focusing on movement between local scopes, it may sound like we've gone back to talking about method calls. After all, when you call a method on an object, control is passed to the body of the method (a different scope); and when the method has finished executing, control returns to the point right after the point where the method call took place.

We are indeed back in method-call territory, but we're exploring new aspects of it, not just revisiting the old. We're talking about a new construct called a *code block* and a keyword by the name of `yield`.

We saw earlier a code sample that looked like this:

`loop { puts "Looping forever!" }`

The word `loop` and the message in the string clue you in as to what you get if you run it: that message, printed forever. But what *exactly* is going on? Why does that `puts` statement get executed at all-and why does it get executed in a loop?

The answer is that `loop` is an *iterator*. An iterator is a Ruby method that has an extra ingredient in its calling syntax: it expects you to provide it with a code block. The curly braces in the loop example delimit the block; the code in the block consists of the `puts` statement.

The `loop` method has access to the code inside the block: the method can *call* (execute) the block. To do this from an iterator of your own, you use the keyword `yield`. Together, the code block (supplied by the calling code) and `yield` (invoked from within the method) are the chief ingredients of iteration.

`loop` itself is written in C (and uses a C function to achieve the same effect as `yield`). But the whole idea of looping suggests an interesting exercise: reimplementing the `loop` in pure Ruby. This exercise will give you a first glimpse at `yield` in action.

### *Iteration, home-style* ###
The job of `loop` is to yield control to the block, again and again. Here's how you might write your own version of `loop`:

```ruby
def my_loop
  while true
    yield
  end
end
```
Or even shorter:

```ruby
def my_loop
  yield while true
end
```
Then you'd call it just like you call `loop`:

`my_loop { puts "My-looping forever!" }`

and the message would be printed over and over.

By providing a code block, you're giving `my_loop` something-a chunk of code-to which it can yield control. When the method yields to the block, the code in the block runs, and then control returns to the method. Yielding isn't the same as returning from a method. Yielding takes place while the method is still running. After the code block executes, control returns to the method at the statement immediately following the call to `yield`.

The code block is part of the method call-that is, part of its syntax. This is an important point: a code block isn't an argument. The arguments to methods are the arguments. The code block is the code block. They're two separate constructs. You can see the logic behind the distinction if you look at the full picture of how method calls are put together.

### *The anatomy of the method call* ###
Every method call in Ruby has the following syntax:

• A receiver object or variable (defaulting to `self` if absent)

• A dot (required if there's an explicit receive; disallowed otherwise)

• A method name (required)

• An argument list (optional; defaults to ())

• A code block (option; no default)

Note in particular that the argument list and the code block are separate. Their existence varies independently. All of these are syntactically legitimate Ruby method calls:

```ruby
loop { puts "Hi" }
loop() { puts "Hi" }
string.scan(/[^,]+/)
string.scan(/[^,]+/) { |word| puts word }
```
(The last example shows a block parameter, `word`. We'll get back to block parameters presently.) The difference between a method call with a block and a method call without a block comes down to whether or not the method can yield. If there's a block, then it can; if not, it can't, because there's nothing to yield to.

Furthermore, some methods are written so they'll at least do *something*, whether you pass them a code block or not. `String#split` for example, splits its receiver (a string, of course), on the delimiter you pass in and returns an array of the split elements. If you pass it a block, `split` also yields the split elements to the block, one at a time. Your block can then do whatever it wants with each substring: print it out, stash it in a database column, and so forth.

If you learn to think of the code block as a syntactic element of the method call, rather than as one of the arguments, you'll be able to keep things straight as you see more variations on the basic iteration theme.

Earlier you saw, in brief, that code blocks can be delimited either by curly braces or by the `do/end` keyword pair. Let's look more closely now at how these two delimiter options differ from each other.

### *Curly braces vs. do/end in code block syntax* ###
The difference between the two ways of delimiting a code block is a difference in precedence. Look at this example, and you'll start to see how it plays out:

```irb
>> array = [1, 2, 3]
=> [1, 2, 3]
>> array.map {|n| n * 10 } #<--1.
=> [10, 20, 30]
>> array.map do |n| n * 10 end #<--2
=> [10, 20, 30]
>> puts array.map {|n| n * 10 }  #<--3
10
20
30
=> nil
>> puts array.map do |n| n * 10 end #<--4
  #<Enumerator:0x0000000101123048>
=> nil
```
The `map` method works through an array one method at a time, calling the code block once for each item and creating a new array consisting of the results of all of those calls to the block. Mapping our `[1, 2, 3]` array through a block that multiplies each item by 10 results in the new array `[10, 20 ,30]`. Furthermore, for a simple map operation, it doesn't matter whether we use curly braces (#1) or `do/end` (#2). The results are the same.

But look at what happens when we use the outcome of the map operation as an argument to `puts`. The curly-brace version prints out the `[10, 20, 30]` array (one item per line, in keeping with how `puts` handles arrays) (#3). But the `do/end` version returns an enumerator-which is precisely what `map` does when it's called with *no* code block (#4). (You'll learn more about enumerators later on. The relevant point here is that the two block syntaxes produce different results.)

The reason is that the precedence is different. The first `puts` statement is interpreted like this:

`puts(array.map {|n| n * 10 })`

The second is interpreted like this:

`puts(array.map) do |n| n * 10 end`

In the second case, the code block is interpreted as being part of the call to `puts`, not the call to `map`. And if you call `puts` with a block, it ignores the block. So the `do/end` version is really equivalent to

`puts array.map`

And that's why we get an enumerator.

The call to `map` using a `do/end`-style code block illustrates the fact that if you supply a code block but the method you call doesn't see it (or doesn't look for it), no error occurs: methods aren't obliged to yield, and many methods (including `map`) have well defined behaviors for cases where there's a code block and cases where there isn't. If a method seems to be ignoring a block that you expect it to yield to, look closely at the precedence rules and make sure the block really is available to the method.

We'll continue looking at iterators and iteration by doing with several built-in Ruby iterators what we did with `loop`: examining the method and then implementing our own. We'll start with a method that's a slight refinement of `loop`:`times`.

### *Implementing times* ###
The `times` method is an instance method of the `Integer` class, which means you call it as a method on integers. It runs the code block *n* times, for any integer *n*, and at the end of the method the return value is *n*.

You can see both the output and the return value if you run a `times` example in irb:

```irb
>> 5.times { puts "Writing this 5 times!" }    #<---1
Writing this 5 times!
Writing this 5 times!
Writing this 5 times!
Writing this 5 times!
Writing this 5 times!
=> 5      #<---2

```
The call to the method includes a code block(#1) that gets executed five times. The return value of the *whole* method is the object we started with: the integer 5(#2).

The behavior of `times` illustrates nicely the fact that yielding to a block and returning from a method are two different things. A method may yield to its block any number of times, from zero to infinity (the latter in the case of `loop`). But every method returns exactly once (assuming no fatal errors) when it's finished doing everything it's going to do. It's a bit like a jump in figure skating. You take off, execute some rotations in the air, and land. And no matter how many rotations you execute, you only take off once and only land once. Similarly, a method call caused the method to run once and to return once. But in between, like rotations in the air, the method can yield control back to the block (if there is one) zero or more times.

Before we implement `times`, let's look at another of its features. Each time `times` yields to its block, it yields something. Sure enough, code blocks, like methods, can take arguments. When a method yields, it can yield one or more values.

The block picks up the argument through its parameters. In the case of `times`, you can supply a single parameter, and that parameter will be bound to whatever value gets yielded to the block on each iteration. As you might guess, the values yielded by `times` are the integers 0 through *n*-1:

```irb
>> 5.times {|i| puts "I'm on iteration #{i}!" }
I'm on iteration 0!
I'm on iteration 1!
I'm on iteration 2!
I'm on iteration 3!
I'm on iteration 4!
=> 5
```
Each time through-that is, each time `times` yields to the code block-it yields the next value, and that value is placed in the variable `i`.

We're ready to implement `times`-or rather, `my_times`-and here's what it looks like:
