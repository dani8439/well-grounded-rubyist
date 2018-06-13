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
puts "Match!" if "The alphabet starts with abc." =~ /abc/   #<-- Match!
```
As you might guess, this pattern-matching "operator" is an instance method of both the `String` and `Regexp` classes. It's one of the many Ruby methods that provide the syntactic sugar of an infix-operator usage style.

The `match` method and the `=~` operator are equally useful when you're after a simple yes/no answer to the question of whether there's a match between a string and a pattern. If there's no match, you get back `nil`. That's handy for conditionals; all four of the previous examples test the results of their match operations with an `if` test. Where `match` and `=~` differ from each other chiefly is in what they return when there *is* a match: `=~` returns the numerical index of the character in the string where the match started, whereas `match` returns an instance of the class `MatchData`:

```irb
>> "The alphabet starts with abc" =~ /abc/
=> 25
>> /abc/.match("The alphabet starts with abc.")
=> #<MatchData "abc">
```

The first example finds a match in position 25 of the string. In the second example, the creation of a `MatchData` object means that a match was found.

We'll examine `MatchData` objects a little further on. For the moment, we'll be concerned mainly with getting a yes/no answer to an attempted match, so any of the techniques shown thus far will work. For the sake of consistency, and because we'll be more concerned with `MatchData` objects than numerical indexes of substrings, most of the examples in this chapter will stick to the `Regexp#match` method.

## *Building a pattern in a regular expression* ##
When you write a regexp, you put the definition of your pattern between the forward slashes. Remember that what you're putting there isn't a string but a set of predictions and constraints that you want to look for in a string.

The possible components of a regexp include the following:

  • *Literal characters*, meaning "match this character"

  • The *dot wildcard character (.)*, meaning "match any character" (except `\n`, the new-line character)

  • *Character classes*, meaning "match one of these characters"

### *Literal characters in patterns* ###
Any literal character you put in a regexp matches *itself* in the string. Thus the regexp:

`/a/`

matches any string containing the letter a.

Some characters have special meanings to the regexp parser (as you'll see in detail shortly). When you want to match one of these special characters as itself, you have to escape it with a backslash (`\`). For example, to match the character `?` (question mark), you have to write this:

`/\?/`

The backslash means "don't treat the next character as special, treat it as itself."

The special characters include those listed between the parentheses here: (`^$?./\[]{}()+*`). Among them, as you can see, is the dot, which is a special character in regular expressions.

### *The dot wildcard character (.)* ###
Sometimes you'll want to match *any character* at some point in your pattern. You do this with the special dot wildcard character (.). A dot matches any character with the exception of a newline. (There's a way to make it match newlines too, which you'll see a little later.)

The pattern in this regexp matches both "dejected" and "rejected":

`/.ejected/`

It also matches "%ejected" and "8ejected"

`puts "Match!" if /.ejected/.match("%ejected")`

The wildcard dot is handy, but sometimes it gives you more matches than you want. You can impose constraints on matches while still allowing for multiple possible strings, using character classes.

### *Character classes* ###
A *character class* is an explicit list of characters placed inside the regexp in square brackets:

`/[dr]ejected/`

This means "match either *d* or *r* followed by *ejected.*" This new pattern matches either "dejected" or "rejected" but not "&ejected." A character class is a kind of partial or constrained wildcard: it allows for multiple possible characters, but only a limited number of them.

Inside a chracter class, you can also insert a *range* of characters. A common case is this, for lowercase letters:

`/[a-z]/`

To match a hexadecimal digit, you might use several ranges inside a character class:

`/[A-Fa-f0-9]/`

This matches any character *a* through *f* (upper- or lowercase) or any digit.

**Character classes are longer than what they match**
Even a short character class like `[a]` takes up more than one space in a regexp. But remember, each character class matches *one character* in the string. When you look at a character class like `/[dr]/`, it may look like it's going to match the substring `dr`. But it isn't: it's going to match either `d` or `r`.

----

Sometimes you need to match any character *except* those on a special list. You may, for example, be looking for the first character in a string that is *not* a valid hexadecimal digit.

You perform this kind of negative search by negating a character class. To do so, you put a caret (^) at the beginning of the class. For example, here's a character class that matches any character except a valid hexadecimal digit:

`/[^A-Fa-f0-9]/`

And here's how you might find the index of the first occurrence of a non-hex character in a string:

```irb
>> string = "ABC3934 is a hex number."
=> "ABC3934 is a hex number."
>> string =~ /[^A-Fa-f0-9]/
=> 7
```

A character class, positive or negative, can contain any characters. Some character classes are so common that they have special abbreviations.

#### SPECIAL ESCAPE SEQUENCES FOR COMMON CHARACTER CLASSES ####
To match any digit, you can do this:

`/[0-9]/`

You can also accomplish the same thing more concisely with the special escape sequence `\d`:

`/\d/`

Notice that there are no square brackets here: it's just `\d`. Two other useful escape sequences for predefined character classes are these:

  • `\w` matches any digit, alphabetical character, or underscore (`_`).

  • `\s` matches any whitespace character (space, tab, newline).

Each of these predefined character classes also has a negated form. You can match any character that isn't a digit by doing this:

`/\D/`

Similarly, `\W` matches any character other than an alphanumeric character or underscore, and `\S` matches any non-whitespace character.

A successful call to `match` returns a `MatchData` object. Let's look at `MatchData` objects and their capabilities up close. 

## *Matching, substring captures, and MatchData* ##
So far, we've looked at basic match operations:

```ruby
regex.match(string)
string.match(regex)
```
These are essentially true/false tests: either there's a match or there isn't. Now we'll examine what happens on successful and unsuccessful matches and what a match operation can do for you beyond the yes/no answer.

### *Capturing submatches with parentheses* ###
One of the most important techniques of regexp construction is the use of parentheses to specify *captures.*

The idea is this. When you test for a match between a string-say, a line from a file-and a pattern, it's usually because you want to do something with the string or, more commonly, with part of the string. The capture notation allows you to isolate and save substrings of the string that match particular subpatterns.

For example, ket's say we have a string containing information about a person:

`Peel,Emma,Mrs.,talented amateur`

From this string, we need to harvest the person's last name and title. We know the fields are comma separated, and we know what order they come in: last name, first name, title, occupation.

To construct a pattern that matches such a string, we might think in English alongside the following lines:

*First* `some alphabetical characters,`

*then* `a comma,`

*then* `some alphabetical characters,`

*then* `a comma,`

*then* `either 'Mr.' or 'Mrs.'`

We're keeping it simple: no hyphenated names, no doctors or professors, no leaving off the final period on Mr. and Mrs. (which would be done in British usage). The regexp, then, might look like this:

`/[A-Za-z]+,[A-Za-z]+,Mrs?\./`

The question mark after the *s* means *match zero or one s.* Expressing it that way lets us match either "Mr." and "Mrs." concisely. The pattern matches the string, as irb attests:

```irb
>> /[A-Za-z]+,[A-Za-z]+,Mrs?\./.match("Peel,Emma,Mrs.,talented amateur")
=> #<MatchData "Peel,Emma,Mrs.">
```
We got a `MatchData` object rather than `nil`; there was a match.

But now what? How do we isolate the substrings we're interested in (`"Peel"` and `"Mrs."`)?

This is where parenthetical groupings come in. We want two such groupings: one around the subpattern that matches the last name, and one around the subpattern that matches the title:

`/([A-Za-z]+),([A-Za-z]+),(Mrs?\.)/`

Now, when we perform the match

`/([A-Za-z]+),([A-Za-z]+),(Mrs?\.)/.match("Peel,Emma,Mrs.,talented amateur")`

two things happen:

• We get a `MatchData` object that gives us access to the submatches (discussed in a moment)

• Ruby automatically populates a series of variables for us, which also give us access to those submatches.

The variables that Ruby populates are global variables, and their names are based on numbers: `$1`, `$2`, and so forth. `$1` contains the substring matched by the subpattern inside the *first* set of parentheses from the left in the regexp. Examining `$1` after the previous match (for example, with `puts $1`) displays `Peel`. `$2` contains the substring matched by the *second* subpattern; and so forth. In general, the rule is this: after a successful match operation, the variable *$n* (where *n* is a number) contains the substring matched by the subpattern inside the *n* the set of parentheses from the left in the regexp.

**NOTE** If you've used Perl, you may have seen the variable `$0`, which represents not a specific captured subpattern but the entire substring that has been successfully matched. Ruby uses `$0` for something else: it contains the name of the Ruby program file for which the current program or script was initially started up. Instead of `$0` for pattern matches, Ruby provides a method; you call `string` on the `MatchData` object returned by the match. You'll see an example of the `string` method in next section.

---

We can combine these techniques with string interpolation to generate a salutation for a letter, based on performing the match and grabbing the `$1` and `$2` variables:

```ruby
line_from_file = "Peel,Emma,Mrs.,talented amateur"
/([A-Za-z]+),[A-Za-z]+,(Mrs?\.)/.match(line_from_file)
puts "Dear #{$2} #{$1},"   #Output: Dear Mrs. Peel,
```
The *$n*-style variables are handy for grabbing submatches. But you can accomplish the same thing in a more structured, programmatic way by querying the `MatchData` object returned by your match operation.
