# *Regular expressions and regexp-based string operations* #
A *regular expression* in Ruby serves the same purposes it does in other languages: it specifies a pattern of characters, a pattern that may or may not correctly predict (that is, match) a given string. Pattern-match operations are used for conditional branching (match/no match), pinpointing substrings (parts of a string that match parts of the pattern), and various text-filtering techniques.

Regular expressions in Ruby are objects. You send messages *to* a regular expression. Regular expressions add something to the Ruby landscape but, as objects, they also fit nicely into the landscape.


## *What are regular expressions?* ##
Regular expressions appear in many programming languages, with minor differences among the incarnations. Their purpose is to specify character patterns that subsequently are determined to match (or not match) strings. Pattern matching, in turn, serves as the basis for operations like parsing log files, testing keyboard input for validity, and isolating substrings-operations, in other words, of frequent and considerable use to anyone who has to process strings and text.

Regular expressions have a weird reputation. Using them is a powerful, concentrated technique; they burn through a large subset of text-processing problems like acid through a padlock. They're also, in the view of many people, difficult to use, to read, opaque, unmaintainable, and ultimately counterproductive.

A number of Ruby built-in methods take regular expressions as arguments and perform selection or modification on one or more string objects. Regular expressions are used, for example, to *scan* a string for multiple occurrences of a pattern, to *substitute* a replacement string for a substring, and to *split* a string into multiple substrings based on a matching separator.

## *Writing regular expressions* ##
Regular expressions are written with familiar characters-of course-but you have to learn to read and write them as strings unto themselves. They're not strings, and their meaning isn't always as obvious as that of strings. They're representations of *patterns*.

### *Seeing patterns* ###
A regular expressions (regexp or regex) specifies a pattern. For every such pattern, every string in the world either matches the pattern or doesn't match it. The Ruby methods that use regular expressions use them either to determine whether a given string matches a given pattern or to make that determination and also take some action based on the answer.

Patterns of the kind specified by regular expressions are most easily understood-initially, in plain language. Here are several examples of patterns expressed this way:

  • The letter a, followed by a digit.

  • Any uppercase letter, followed by at least one lowercase letter.

  • Three digits, followed by a hyphen, followed by four digits.

A pattern can also include components and constraints related to positioning inside the string:

  • The beginning of a line, followed by one or more whitespace characters.

  • The character . (period) at the end of a string.

  • An uppercase letter at the beginning of a word.

Pattern components like "the beginning of a line", which match a condition rather than a character in a string, are nonetheless expressed with characters or sequences of characters in the regexp.

Regular expressions provide a language for expressing patterns. Learning to write them consists principally of learning how various things are expressed inside a regexp. The most commonly applied rules of regexp construction are fairly easy to learn. You just have to remember that a regexp, although it contains characters, isn't a string. It's a special notation for expressing a pattern that may or may not correctly describe some or all of any given string.

### *Simple matching with literal regular expressions* ###
Regular expressions are instances of the `Regexp` class, which is one of the Ruby classes that has a literal constructor for easy instantiation. The regexp literal constructor is a pair of forward slashes:

`//`

As odd as this may look, it really is a regexp, if a skeletal one. You can veryify that it gives you an instance of the `Regexp` class in irb:

```irb
>> //.class
=> Regexp
```

The specifics of the regexp go between the slashes. We'll start to construct a few simple regular expressions as we look at the basics of the matching process.

Any pattern-matching operation has two main players: a regexp and a string. The regexp expressions predictions abou thte string. Either the string fulfills those predictions (matches the pattern) or it doesn't.

The simplest way to find out whether there's a match between a pattern and a string is with the `match` method. You can do this either direction-regexp objects and string objects both respond to `match`, and both of these examples succeed and pring `"Match!"`:

```ruby
puts "Match!" if /abc/.match("The alphabet starts with abc.")  #<-- Match!
puts "Match!" if "The alphabet starts with abc.".match(/abc/)  #<-- Match!
```

The string version of `match` (the second line of the two) differs from the regexp version in that it converts a string argument *to* a regexp. (We'll return to that a little later.) In the example, the argument is already a regexp (`/abc/`), so no conversion is necessary.

In addition to the `match` method, Ruby also features a pattern-matching operator, `=~` (equal sign and tilde), which goes between a string and a regexp:

```ruby
puts "Match!" if /abc/ =~ "The alphabet starts with abc."   #<-- Match!
puts "Match!" if "The alphabet starts wtih abc." =~ /abc/   #<-- Match!
```

