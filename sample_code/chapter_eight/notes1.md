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
You can even use a here-doc in a literal object constructor. Here's an example where a string gets put into an array, creating the string as a here-doc:

```ruby 
array = [1,2,3, <<EOM, 4]
This is the here-doc!
It becomes array[3].
EOM
p array

[1, 2, 3, "This is the here-doc!\nIt becomes array[3].\n", 4]
```
As you can use the `<<EOM` notation as a method argument; the argument becomes the here-doc that follows the line on which the method call occurs. This can be useful if you want to avoid cramming too much text into your argument list: 

```ruby 
do_something_with_args(a, b, <<EOM)
http://some_very_long_url_or_other_text_best_put_on_its_own_line 
EOM
```
In addition to creatin strings, you need to know what you can do with them. You can do a lot, and we'll look at much of it in detail, starting with the basics of string manipulation.

### *Basic String manipulation* ### 
*Basic* in this context means manipulating the object at the lowest levels: retrieving and setting substrings, and combining strings with each other. From Ruby's perspective, these techniques aren't any more basic than those that come later in our survey of strings; but conceptually, they're closer to the string metal, so to speak.

### GETTING AND SETTING SUBSTRINGS ### 
To retrieve the *n*th character in a string, you use the `[]` operator/method, giving it the index, on a zero-origin basis, for the the character you want. Negative numbers index from the end of the string:

```irb
>> string = "Ruby is a cool language."
=> "Ruby is a cool language."
>> string[5]
=> "i"
>> string[-12]
=> "o"
```
If you provide a second integer argument, *m*, you'll get a substring of *m* characters, starting at the index you've specified.

```irb
>> string[5,10]
=> "is a cool "
```
You can also provide a single *range* object as the argument. We'll look at ranges in more depth later; for now, you can think of *n..m* as all of the values between *n* and *m*, inclusive (or exclusive of *m*, if you use the three dots instead of two). The range can use negative numbers, which count from the end of the string backward, but the second index always has to be closer to the end of the string than the first index; the index logic only goes from left to right:

```irb 
>> string[7..14]
=> " a cool "
>> string[-12..-3]
=> "ol languag"
>> string[-12..20]
=> "ol langua"
>> string[15..-1]
=> "language."
```
You can also grab substrings based on an explicit substring search. If the substring is found it's returned; if not, the return value is `nil`.

```irb 
>> string["cool lang"]
=> "cool lang"
>> string["very cool lang"]
=> nil
```
It's also possible to search for a pattern match using the `[]` technique with a regular expression--`[]` is a method, and what's inside it are the arguments, so it can do whatever it's programmed to do:

```irb 
>> string[/c[ol ]+/]
=> "cool l"
```
We'll look at regular expressions later on, at which point you'll get a sense of the possibilities of this way of looking for substrings. 

The `[]` method is also available under the name `slice`. Furthermore, a receiver-changing version of `slice`, namely `slice!`, removes the character(s) from the string permanently:

```irb 
>> string.slice!("cool ")
=> "cool "
>> string
=> "Ruby is a language."
```
To set part of a string to a new value, you use the `[]=` method. It takes the same kinds of indexing arguments as `[]` but changes the value to what you specify. Putting the preceding little string through its paces, here are some substring-setting examples, with an examination of the changed string after each one:

```irb
>> string = "Ruby is a cool language."
=> "Ruby is a cool language."
>> string["cool"] = "great"
=> "great"
>> string 
=> "Ruby is a great language."
>> string[-1] = "!"
=> "!"
>> string
=> "Ruby is a great language!"
>> string[-9..-1] = "thing to learn!"
=> "thing to learn!"
>> string
=> "Ruby is a great thing to learn!"
```
Integers, ranges, strings, and regular expression can thus all work as index or substring specifiers. If you try to set part of the string that doesn't exist-that is, a too-high or too-low numerical index, or a string or regular expression that doesn't match the string-you get a fatal error.

In addition to changing individual strings, you can also combine strings with each other.

### COMBINING STRINGS ###
There are several techniques for combining strings. These techniques differ as to whether the second string is permanently added to the first or whether a new, third string is created out of the first two-in other words, whether the operation changes the receiver.

To create a new string consisting of two or more strings, you can use the `+` method/operator to run the original strings together. Here's what irb has to say about adding strings:

```irb 
>> "a" + "b"
=> "ab"
>> "a" + "b" + "c"
=> "abc"
```
The string you get back from `+` is always a new string. Yuo can test this by assigning a string to a variable, using it in a `+` operation, and checking to see what its value is after the operation:

```irb 
>> str = "Hi "
=> "Hi "
>> stri + "there."
=> "Hi there."          #<----1.
>> str
=> "Hi "                    #<----2.
```
The expression `str + "there."` (which is syntactic sugar for the method call `str.+("there")`) evaluates to the new string `"Hi there."` (#1.) but leaves `str` unchanged (#2). 

To add (append) a second string permanently to an existing string, use the `<<` method, which also has a syntactic sugar, pseudo-operator form:

```irb
>> str = "Hi "
=> "Hi "
>> str << "there."
=> "Hi there."
>> str
=> "Hi there."        #<----1.
```
In this example, the original string `str` has had the new string appended to it, as you can see from the evaluation of `str` at the end (#1). 

String interpolation is (among other things) another way to combine strings. You've seen it in action already, but let's take the opportunity to look at a couple of details of how it works. 

### STRING COMBINATION VIA INTERPOLATION ###
At its simplest, string interpolation involves dropping one existing string into another:

```irb 
>> str = "Hi "
=> "Hi "
>> "#{str} there"
=> "Hi there."
```
The result is a new string: `"Hi there."` However, it's good to keep in mind that the interpolation can involve any Ruby expression:

```irb 
>> "The sum is #{2 + 2}."
=> "The sum is 4."
```
The code inside the curly braces can be anything. (THey do have to be curly braces; it's not like `%q{}`, where you can choose your own delimiter.) It's unusual to make the code terribly complex, because that detracts from the structure and readability of the program-but Ruby is happy with any interpolated code and will obligingly place a string representation of the value of the code in yuor string:

```irb 
>> "My name is #{ class Person
                    attr_accessor :name
                  end
                  d = Person.new 
                  d.name = "David"
                  d.name
                  }."
=> "My name is David."
```
You really, *really* don't want to do this, but it's important to understand that you can interpolate any code you want. Ruby patiently waits for it all to run and then snags the final value of the whole thing (`d.name`, in this case, because that's the last expression inside the interpolation block) and interpolates it.

There's a much nicer way to accomplish something similar. Ruby interpolates by calling `to_s` on the object to which the interpolation code evaluates. You can take advantage of this to streamline string construction, by defining your own `to_s` methods appropriately:

```irb 
>> class Person
>>    attr_accessor :name
>>    def to_s
>>      name
>>    end
>> end
=> :to_s
>> david = Person.new
=> #<Person:0x00000101a73cb0>
>> david.name = "David"
=> "David"
>> "Hello, #{david}!"
=> "Hello, David!"
```
Here the object `david` serves as the interpolated code, and produces the result of its `to_s` operation, which is defined as a wrapper around the `name` getter method. Using the `to_s` hook is a useful way to control your objects' behavior in interpolated strings. Remember, though, that you can also say (in the preceeding example) `david.name`. So, if you have a broader use for a class's `to_s` than a very specific interpolation scenario, you can usually accomodate it.

After you've created and possibly altered a string, you can ask it for a considerable amount of information about itself. We'll look into how you query strings now.

## *Querying strings* ##
String queries come in a couple of flavors. SOme give you a Boolean (true or false) response, and some give you a kind of status report on the current state of the string. 

### BOOLEAN STRING QUERIES### 
You can ask a string whether it includes a given substring, using `include?`. Given the string used earlier (`"Ruby is a cool language."`), inclusion queries might look like this:

```irb 
>> string.include?("Ruby")
=> true
>> string.include?("English")
=> false
```
You can test for a given start or end to a string with `start_with?` and `end_with?`:

```irb
>> string.start_with?("Ruby")
=> true
>> string.end_with?("!!!")
=> false
```
And you can test for the absence of content--that is, for the presence of any characters at all-with the `empty?` method:

```irb 
>> string.empty?
=> false
>> "".empty?
=> true
```
Keep in mind that whitespace counts as characters; the string `" "` isn't empty. 

### CONTENT QUERIES ### 
The `size` and `length` methods (they're synonyms for the same method) do what their names suggest they do:

```irb 
>> string.size
=> 24
```
If you want to know how many times a given letter or set of letters occurs in a string, use `count`. To count occurrences of one letter, provide that one letter as the argument. Still using the string `"Ruby is a cool language."`, there are three occurrences of `"a"`:

```irb 
>> string.count("a")
=> 3
```

To count how many of a range of letters there are, you can use a hyphen-separated range:

```irb 
>> string.count("g-m")
=> 5
```
Character specifications are case-sensitive:

```irb 
>> string.count("A-Z")
=> 1
```
You can also provide a written-out set of characters you want to count:

```irb
>> string.count("aey. ")      #<----Three letters plus period and space character.
=> 10 
```
To negate the search-that is, to count the number of characters that don't match the ones you specify-put a `^` (caret) at the beginning of your specification:

```irb
>> string.count("^aey. ")
=> 14
>> string.count("^g-m")
=> 19
```
(If you're familiar with regular expressions, you'll recognize the caret technique as a close cousin of regular expression character class negation.) You can combine the specification syntaxes and even provide more than one argument:

```irb
>> string.count("ag-m")
=> 8
>> string.count("ag-m", "^l")    #<------Count "a" and "g-m" except for "l".
=> 6
```
Another way to query strings as to their content is with the `index` method. `index` is sort of the inverse of using `[]` with a numerical index: instead of looking up a substring at a particular index, it returns the index at which a given substring occurs. The first occurrence from the left is returnced. If you want the first occurrence from the right, use `rindex`:

```irb 
>> string.index("cool")
=> 10
>> string.index("l")
=> 13
>> string.rindex("l")
=> 15
```
Although strings are made up of characters, Ruby has no separate character class. One-character strings can tell you their ordinal code, courtesy of the `ord` method:

```irb 
>> "a".ord
=> 97
```
If you take the `ord` of a longer string, you get the code for the first character:

```irb 
>> "abc".ord
=> 97
```
The reverse operation is available as the `chr` method on integers:

```irb
>> 97.chr
=> "a"
```
Asking a number that doesn't correspond to any character for its `chr` equivalent causes a fatal error.

In addition to providing information about themselves, strings can compare themselves with other strings, to test for equality and order. 

