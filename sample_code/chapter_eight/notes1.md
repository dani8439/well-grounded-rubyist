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

### OTHER QUOTING MECHANISMS ###
The alternate quoting mechanisms take the form `%char{text}`, where `char` is one of those several special characters and the curly braces stand in for a delimiter of your choosing. Here's an example of one of these mechanisms: `%q`, which produces a single-quoted string.

`puts %q{You needn't escape apostrophes when using %q.}`

As the sample sentence points out, because you're not using the single-quote character as a quote character, you can use it unescaped inside the string.

Also available to you are `%Q{}`, which generates a double-quoted string, and plain `%{}` (percent sign and delimiter), which also generates a double-quoted string. Naturally, you don't need to escape the double-quote character inside strings that are represented with either of these notations.

The delimiter for the %-style notations can be just about anything you want, as long as the opening delimiter matches the closing one. *Matching* in this case means either making up a left/right pair of braces (curly, curved, or square) or being two of the same characters. Thus all of the following are acceptable:

```ruby
%q-A string-
%Q/Another String/
%[Yet another string]
```
You can't use alphanumeric characters as your delimiters, but if you feel like being obscure, you can use a space. It's hard to see in an example, so the entire following example is surrounded by square brackets that you shouldn't type if you're entering the example in an irb session or Ruby program file:

`[%q Hello!]`

The space-delimited example, aside from being silly (although instructive), brings to mind the question of what happens if you use the delimiter inside the string (because many strings have spaces inside them). If the delimiter is a single character, you have to escape it:

```ruby
[%q Hello\ there!]
%q-Better escape the \- inside this string!-
```

If you're using left/right matching braces and Ruby sees a left-hand one inside the string, it assumes that the brace is part of the string and looks for a matching right-hand one. If you want to include an unmatched brace of the same type as the ones you're using for delimiters, you have to escape it:

```ruby
%Q[I can put [] in here unescaped.]
%q(I have to escape \ (if I use it alone in here.)
%Q(And the same goes for \).)
```

Each of the `%char`-style quoting mechanisms generates either a single- or double-quoted string. That distinction pervades stringdom; ever string is one or the other, no matter which notation you use-including the next one we'll look at, the "here" document syntax.

**irb doesn't play well with some of this syntax**
irb has its own Ruby parser, which has to contend with the fact that as it parses one line, it has no way of knowing what the next line will be. The result is that irb does things a little differently from the Ruby interpreter. In the case of quote mechanisms, you may find that in irb, escaping unmatched square and other brackets produces odd results. Generally, you're better off plugging in these examples into the command line format `ruby -e 'puts %q[ Example: \[]'` and similar.

### "HERE" DOCUMENTS ###
A *"here" document*, or *here-doc,* is a string, usually a multiline string, that often takes the form of a template or a set of data lines. It's said to be "here" because it's physically present in the program file, not read in from a separate text file.

Here-docs come into being through the `<<` operator, as shown below:

```irb
>> text = <<EOM
This is the first line of text.
This is the second line.
Now we're done.
EOM
=> "This is the first line of text.\nThis is the second line.\nNow we're done.\n"
```
The expression `<<EOM` means *the text that follows, up to but not including the next occurrence of "EOM."* The delimiter can be any string; `EOM` (end of message) is a common choice. It has to be flush-left, and it has to be the only thing on the line where it occurs. You can switch off the flush-left requirement by putting a hyphen before the `<<` operator:

```
>> text = <<-EOM
The EOM doesn't have to be flush left!
      EOM
=> "The EOM doesn't have to be flush left!\n"  
```

The EOM that stops the reading of this here-doc (only a one-line document this time) is in the middle of the line.

By default, here-docs are read in as double-quoted strings. Thus they can include string interpolation and use of escape characters like `\n` and `\t`. If you want a single-quoted here-doc, put the closing delimiter in single quotes when you start the document. To make the difference clearer, this example includes a `puts` of the here-doc:

```irb
>> text = <<-'EOM'
Single-quoted!
Note the literal \n.
And the literal #{2 + 2}.
EOM
 => "Single-quoted!\nNote the literal \\n.\nAnd the literal \#{2 + 2}.\n"
>> puts text
Single-quoted!
Note the literal \n.
And the literal #{2 + 2}.
 => nil
```
The `<<EOM` or equivalent doesn't have to be the last thing on its line. Wherever it occurs, it serves as a placeholder for the upcoming here-doc. HEre's one that gets converted to an integer and multiplied by 10:

```irb
a = <<EOM.to_i * 10
5
EOM
puts a      #Output: 50
```
