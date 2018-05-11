# *Strings, symbols, and other scalar objects* #

The term *scalar* means *one-dimensional.* Here, it refers to objects that represent single values, as opposed to collection or container objects that hold multiple values. There are some shades of gray: strings, for example, can be viewed as collections of characters in addition to being single units of text. Scalar is to some extent in the eye of the beholder.

The built-in objects we'll look at include the following:

• Strings, which are Ruby's standard way of handling textual material of any length.

• Symbols, which are (among other things) another way of representing text in Ruby.

• Integers

• Floating-point numbers.

• `Time`, `Date`, and `DateTime` objects.

# *Working with strings* #
Ruby provides two built-in classes that, between them, provide all the functionality of text representation: the `String` class. Strings and symbols are deeply different from each other, but they're similar enough in their shared capacity to represent text that they merit being discussed in the same chapter. Strings are the standard way to represent bodies of text of arbitrary content and length. We've seen strings in many contexts already; here, we'll get more deeply into some of their semantics and abilities.

## *String notation* ##
A *string literal* is generally enclosed in quotation marks:

`"This is a string."`

Single quotes can also be used:

`'This is also a string.'`

But a single-quoted string behaves differently, in some circumstances, than a double quoted string. The main difference is that string interpolation doesn't work with single-quoted strings. Try these two snippets, and you'll see the difference:

```ruby
puts "Two plus two is #{2 + 2}."
puts 'Two plus two is #{2 + 2}.'
```

As you'll see if you paste these lines into irb, you get two very different results:

```irb
Two plus two is 4.
=> nil

Two plus two is #{2 + 2}.
=> nil
```
Single quotes disable the `#{...}` interpolation mechanism. If you need that mechanism, you can't use single quotes. Conversely, you can, if necessary, *escape* (and thereby disable) the string interpolation mechanism in a double-quoted string, using backslashes:

`puts "Escaped interpolation: \"\#{2 + 2}\"."`

Single- and double-quoted strings also behave differently with respect to the need to escape certain characters. The following statements document and demonstrate the differences. Look closely at which are single-quoted and which are double-quoted, and at how the backslash is used:

```ruby
puts "Backslashes (\\) have to be escaped in double quotes."
puts 'You can just type \ once in a single quoted string.'
puts "But whichever type of quotation mark you use..."
puts "...you have to escape its quotation symbol, such as \"."
puts 'That applies to \' in single-quoted strings too.'
puts 'Backslash-n just looks like \n between single quotes.'
puts "But it means newline\nin a double-quoted string."
puts 'Same with \t, which comes out as \t with single quotes...'
puts "...but inserts a tab character:\tinside double quotes."
puts "You can escape the backslash to get \\n and \\t with double quotes."
```
Here's the output from the barrage of quotations. It doesn't line up line-for-line with the code, but you can see why if you look at the statement that outputs a newline character:

```irb
Backslashes (\) have to be escaped in double quotes.
You can just type \ once in a single quoted string.
But whichever type of quotation mark you use...
...you have to escape its quotation symbol, such as ".
That applies to ' in single-quoted strings too.
Backslash-n just looks like \n between single quotes.
But it means newline
in a double-quoted string.
Same with \t, which comes out as \t with single quotes...
...but inserts a tab character: inside double quotes.
You can escape the backslash to get \n and \t with double quotes.
```

You'll see other cases of string interpolation and character escaping as we proceed. Meanwhile, by far the best way to get a feel for these two behaviors firsthand is to experiment with strings in irb.

Ruby gives you several ways to write strings in addition to single and double quotation marks.
