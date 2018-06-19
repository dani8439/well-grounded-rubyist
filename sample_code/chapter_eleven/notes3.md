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

## *Common methods that use regular expressions* ##
The payoff for gaining facility with regular expressions in Ruby is the ability to use the methods that take regular expressions as arguments and do something with them.

To begin with, you can always use a `match` operation as a test in, say, a `find` or `find_all` operation on a collection. For example, to find all strings longer than 10 characters and containing at least 1 digit, from an array of strings called `array`, you can do this:

`array.find_all {|e| e.size > 10 and /\d/.match(e) }`

But a number of methods, mostly pertaining to strings, are based more directly on the use of regular expressions. We'll look at several of them in this section.

### *String#scan* ###
The `scan` method goes from left to right through a string, testing repeatedly for a match with the pattern you specify. The results are returned in an array.

For example, if you want to harvest all the digits in a string, you can do this:

```irb
>> "testing 1 2 3 testing 4 5 6".scan(/\d/)
=> ["1", "2", "3", "4", "5", "6"]
```

Note that `scan` jumps over things that don't match its pattern and looks for a match later in the string. This behavior is different from that of `match`, which stops for good when it finishes matching the pattern completely once.

If you use parenthetical groupings in the regexp you give to `scan`, the operation returns an array of arrays. Each inner array contains the results of one scan through the string:

```irb
>> str = "Leopold Auer was the teacher of Jascha Heifetz."
=> "Leopold Auer was the teacher of Jascha Heifetz."
>> violinists = str.scan(/([A-Z]\w+)\s+([A-Z]\w+)/)
=> [["Leopold", "Auer"], ["Jascha", "Heifetz"]]
```

This example nets you an array of arrays, where each inner array contains the first name and the last name of a person. Having each complete name stored in its own array makes it easy to iterate over the whole list of names, which we've conveniently stashed in the variable `violinists`:

```ruby
violinists.each do |fname, lname|
  puts "#{lname}'s first name was #{fname}."
end
```

The output from this snippet is as follows:

```irb
Auer's first name was Leopold.
Heifetz's first name was Jascha.
```
The regexp used for names in this example is, of course, overly simple: it neglects hyphens, middle names, and so forth. But it's a good illustration of how to use captures with `scan`.

`String#scan` can also take a code block-and that technique can, at times, save you a step. `scan` yields its results to the block, and the details of the yielding depend on whether you're using parenthetical captures. Here's a scan-block-based rewrite of the previous code:

```ruby
str.scan(/([A-Z]\w+)\s+([A-Z]\w+)/) do |fname, lname|
  puts "#{lname}'s first name was #{fname}."
end
```
Each time through the string, the block receives the captures in an array. If you're not doing any capturing, the block receives the matched substrings successively. Scanning for clumps of `\w` characters (`\w` is the character class consisting of letters, numbers, and underscore) might look like this:

`"one two three".scan(/\w+/) {|n| puts "Next number: #{n}" }`

which would produce this output:

```irb
Next number: one
Next number: two
Next number: three
=> "one two three"
```
Note that if you provide a block, `scan` doesn't store the results up an array and return them; it sends each result to the block and then discards it. That way, you can scan through long strings, doing something with the results a long the way, and avoid taking up memory with the substrings you've already seen and used.

Another common regexp-based string operation is `split`.

**Even more string scanning with the `StringScanner` class**
The standard library includes an extension called `strscan`, which provides the `StringScanner` class. `StringScanner` objects extend the available toolkit for scanning and examining strings. A `StringScanner` object maintains a pointer into the string, allowing for back-and-forth movement through the string using position and pointer semantics.

Here are some examples of the methods in `StringScanner`:

```irb
>> require 'strscan'                #<--- Loads scanner library
=> true
>> ss = StringScanner.new("Testing string scanning")  #<--- Creates scanner
=> #<StringScanner 0/23 @ "Testi...">
>> ss.scan_until(/ing/)             #<--- Scans string until regexp matches
=> "Testing"
>> ss.pos                     #<--- Examines new pointer position
=> 7  
>> ss.peek(7)           #<--- Looks at next 7 bytes (but doesn't advance pointer)
=> " string"
>> ss.unscan                  #<---- Undoes the previous scan
=> #<StringScanner 0/23 @ "Testi...">
>> ss.pos                           #<--- Moves pointer past regexp
=> 0
>> ss.skip(/Test/)                        #<---- Examines part of string to right of pointer
=> 4
>> ss.rest
=> "ing string scanning"
```

---

### *String#split* ###
In keeping with its name, `split` splits a string into multiple substrings, returning those substrings as an array. `split` can take either a regexp or a plain string as the separator for the split operation. It's commonly used to get an array consisting of all the characters in a string. To do this, you use an empty regexp:

```irb
>> "Ruby".split(//)
=> ["R", "u", "b", "y"]
```

`split` is often used in the course of converting flat, text-based configuration files to Ruby data structures. Typically, this involves going through a file line by line and converting each line. A single-line conversion might look like this:

```irb
>> line = "first_name=david;last_name=black;country=usa"
=> "first_name=david;last_name=black;country=usa"
>> record = line.split(/=|;/)
=> ["first_name", "david", "last_name", "black", "country", "usa"]
```

This leaves `record` containing an array:

`["first_name", "david", "last_name", "black", "country", "usa"]`

With a little more work, you can populate a hash with entries of this kind:

```irb
data= []
record = Hash[*line.split(/=|;/)]
data.push(record)                 #<--- Uses * to turn array into bare list to feed to Hash[]

# {"First_name"=>"David", "last_name"=>"black", "country"=>"usa"}
# [{"First_name"=>"David", "last_name"=>"black", "country"=>"usa"}]
```
If you do this for every line in a file, you'll have an array of hashes representing all the records. That array of hashes, in turn, can be used as the pivot point to a further operation-perhaps embedding the information in a report or feeding it to a library routing that can save it to a database table as a sequence of column/value pairs.

You can provide a second argument to `split`; this argument limits the number of items returned. In this example:

```irb
>> "a,b,c,d,e".split(/,/,3)
=> ["a", "b", "c,d,e"] 
```

`split` stops splitting once it has three elements to return and puts everything that's left (commas and all) in the third string. 

In addition to breaking a string into parts by scanning and splitting, you can also change parts of a string with substitution operations, as you'll see next.
