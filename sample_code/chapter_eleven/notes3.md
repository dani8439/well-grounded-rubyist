## *Converting strings and regular expressions to each other* ##
The fact that regular expressions aren't strings is easy to absorb at a glance in the case of regular expressions like this:

`/[a-c]{3}/`

With its special character-class and repetition syntax, this pattern doesn't look much like any of the strings it matches (`"aaa"`, `"aab"`, `"aac"`, and so forth).

It gets a little harder *not* to see a direct link between a regexp and a string when faced with a regexp like this:

`/abc/`

This regexp isn't the string `"abc"`. Moreover, it matches not only `"abc"` but any string with the substring `"abc"` somewhere inside it (like "Now I know my abcs."). There's no unique relationship between a string and a similar-looking regexp.

Still, although the visual resemblance between some strings and some regular expressions doesn't mean they're the same thing, regular expressions and strings do interact in important ways. Let's look at some flow in the string-to-regexp direction and then some going the opposite way.

### *String-to-regexp idioms* ###
To begin with, you can perform string (or string-style) interpolation inside a regexp. You do so with the familiar `#{...}` interpolation technique.

```irb
>> str = "def"
=> "def"
>> /abc#{str}/
=> /abcdef/
```
The value of `str` is dropped into the regexp and made part of it, just as it would be if you were using the same technique to interpolate it into a string.

The interpolation technique becomes more complicated when the string you're interpolating contains regexp special characters. For example, consider a string containing a period (.). As you know, the period or dot has a special meaning in regular expressions: it matches any single character except newline. In a string, it's just a dot. When it comes to interpolating strings into regular expressions, this has the potential to cause confusion:

```irb
>> str = "a.c"
=> "a.c"
>> re = /#{str}/
=> /a.c/
>> re.match("a.c")
=> #<MatchData "a.c">
>> re.match("abc")
=> #<MatchData "abc">
```
Both matches succeed; they return `MatchData` objects rather than `nil`. The dot in the pattern matches a dot in the string `"a.c"`. But it also matches the b in `"abc"`. The dot, which started life just as a dot inside `str`, takes on special meaning when it becomes part of the regexp.

But you can *escape* the special characters inside a string before you drop the string into a regexp. You don't have to do this manually: the `Regexp` class provides a `Regexp.escape` class method that does it for you. You can see what this method does by running it on a couple of strings in isolation:

```irb
>> Regexp.escape("a.c")
=> "a\\.c"
>> Regexp.escape("^abc")
=> "\\^abc"
```
(irb double backslashes because it's outputting double-quoted strings. If you wish, you can `puts` the expressions, and you'll see them in their real form with single backslashes.)

As a result of this kind of escaping, you can constrain your regular expressions to match exactly the strings you interpolate into them:

```irb
>> str = "a.c"
=> "a.c"
>> re = /#{Regexp.escape(str)}/
=> /a\.c/
>> re.match("a.c")
=> #<MatchData "a.c">
>> re.match("abc")
=> nil
```
This time, the attempt to use the dot as a wildcard match character fails; `"abc"` isn't a match for the escaped, interpolated string.

It's also possible to instantiate a regexp from a string by passing the string to `Regexp.new`:

```irb
>> Regexp.new('(.*)\s+Black')
=> /(.*)\s+Black/
```

The usual character-escaping and/or regexp-escaping logic applies:

```irb

>> Regexp.new('Mr\. David Black')
=> /Mr\. David Black/
>> Regexp.new(Regexp.escape("Mr. David Black"))
=> /Mr\.\ David\ Black/
```

Notice that the literal space characters have been escaped with backslashes-not strictly necessary unless you're using the `x` modifier, but not detrimental either.

You can also pass a literal regexp to `Regexp.new`, in which case you get back a new, identical regexp. Because you can always just use the literal regexp in the first place, `Regexp.new` is more commonly used to convert strings to regexps.

The use of single-quoted strings makes it unnecessary to double up on the backslashes. If you use double quotes (which you may have to, depending on what sorts of interpolation you need to do), remember that you need to write `Mr\\.` so the backslash is part of the string passed to the regexp constructor. Otherwise, it will only have the effect of placing a literal dot in the string-which was going to happen anyway-and that dot will make it into the regexp without a slash and will therefore be interpreted as a wildcard dot.

Now let's look at some conversion techniques in the other direction: regexp to string. This is something you'll do mostly for debugging and analysis purposes.

### *Going from a regular expression to a string* ###
Like all Ruby objects, regular expressions can represent themselves in string form. The way they do this may look odd at first:

```irb
>> puts /abc/
(?-mix:abc)
=> nil
```
This is an alternate regexp notation-one that rarely sees the light of day except when generated by the `to_s` instance method of regexp objects. What looks like *mix* is actually a list of modifiers (`m`, `i`, and `x`) with a minus sign in front indicating that the modifiers are all switched off.

You can play with `puts`ing regular expressions in irb, and you'll see more about how this notation works. We won't pursue it here, in part because there's another way to get a string representation of a regexp that looks more like what you probably typed-by calling `inspect` or `p` (which in turn calls `inspect`):

```irb
>> /abc/.inspect
=> "/abc/"
```
Going from regular expressions to strings is useful primarily when you're studying and/or troubleshooting regular expressions. It's a good way to make sure your regular expressions are what you think they are.

At this point, we'll bring regular expressions full circle by examining the roles they play in some important methods of other classes. We've gotten this far using the `match` method almost exclusively, but `match` is just the beginning.
