## Repeating Action with Loops ##
Ruby's facilities for looping repeatedly through code also allow you to incorporate conditional logic: you can loop *while* a 
given condition is true (such as a variable being equal to a given value), and you can loop *until* a given condition is true. 
You can also break out of a loop *unconditionally*, terminating the loop at a certain point, and resume execution of the program 
after the loop.

We'll look at several ways to loop-starting, appropriately with a method called `loop`.

### Unconditional looping with the loop method ###
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

### Controlling the loop ###
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
 end
```
Here, control falls through to the `break` statement only if `n == 10 ` is true. If `n == 10` is *not* true (`unless n == 10`), the `next` is executed, and control jumps back to the beginning of the loop before it reaches `break`.

You can also loop conditionally: *while* a given condition is true or *until* a condition becomes true.

## Conditional looping with the while and until keywords ##
