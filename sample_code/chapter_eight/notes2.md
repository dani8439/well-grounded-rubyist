### *String comparison and ordering* ###
The `String` class mixes in the `Comparable` module and defines a `<=>` method. Strings are therefore good to go when it comes to comparisons based on character code (ASCII or otherwise) order:

```irb
>> "a" <=> "b"
=> -1
>> "b" > "a"
=> true
>> "a" > "A"
=> true
>> "." > ","
=> true
```
Remember that the spaceship method/operator returns `-1` if the right object is greater, `1`if the left object is greater, and `0` if the two objects are equal. In the first case in the previous sequence, it returns `-1` becuase the string `"b"` is greater than the string `"a"`. But `"a"` is greater than `"A"`, because the order is done by character value and the character values for `"a"` and `"A"` are 97 and 65 respectively, in Ruby's default encoding of UTF-8. Similarly, the string `"."` is greater than `","` becuase the value for a period is 46 and that for a comma is 44.

Like Ruby objects in general, strings have several methods for testing equality.

#### COMPARING TWO STRINGS FOR EQUALITY ####
The most common string comparison method is `==`, which tests for equality of string content:

```irb
>> "string" == "string"
=>  true
>> "string" == "house"
=> false
```
The two literal `"string"` objects are different objects, but they have the same content. Therefore, they pass the `==` test. The string `"house"` has different content and is therefore not considered equal, based on `==` with `"string"`.

Another equality-test method, `String#eql?` tests two strings for identical content. In practice, it usually returns the same result as `==`. (There are subtle diffferences in the implementations of these two methods, but you can use either. You'll find that `==` is more common.) A third method, `String#equal?`, behaves like `equal?` usually does: it tests whether two strings are the same object-or for that matter, whether a string and any other object are the same object:

```irb
>> "a" == "a"
=> true
>> "a".equal?("a")
=> false
>> "a".equal?(100)
=> false
```
The first test succeeds because the two strings have the same contents. The second test fails becuase the first string isn't the same object as the second string. (And of course nos tring is the same object as the integer `100` so that test fails too.) This is a good reminder of the fact that strings that appear identical to the eye may, to Ruby, have different object identities.

The next two sections present string *transformations* and *conversions*, the difference beting that a transformation involves applying some kind of algorithm or procedure to the content of a string, whereas a conversion means deriving a second, unrelated object-usually not even a string-from the string.

### *String transformation* ###
String transformations in Ruby fall informally into three categories: case, formatting, and content transformations.

#### CASE TRANSFORMATIONS ####
Strings let you raise, lower, and swap their case. All of the case-changing methods have receiver-modifying bang equivalents:

```irb
>> string = "David A. Black"
=> "David A. Black"
>> string.upcase
=> "DAVID A. BLACK"
>> string.downcase
=> "david a. black"
>> string.swapcase
=> "dAVID a. bLACK"
```
There's also a nice refinement that lets you capitalize the string:
```irb
>> string = "david"
=> "david"
>> string.capitalize
=> "David"
```
Like other transformers, `capitalize` has an in-place equivalent, `capitalize!`

You can perform a number of transformations on the format of a string, most of which are designed to help you make your strings look nicer.

#### FORMATTING TRANSFORMATIONS ####
Strictly speaking, format transformations are a subset of content transformations; if the sequence of characters represented by the string didn't change, it wouldn't be much of a transformation. We'll group under the formatting heading some transformations whose main purpose is the enhance the presentation of strings.

The `rjust` and `ljust` methods expand the size of your string to the length you provide in the first argument, padding with blank spaces as necessary:

```irb
>> string = "David A. Black"
=> "David A. Black"
>> string.rjust(25)
=> "           David A. Black"
>> string.ljust(25)
=> "David A. Black           "
```
If you supply a second argument, it's used as padding. This second argument can be more than one character long:

```irb
>> string.rjust(25, '.')
=> "...........David A. Black"
>> string.rjust(25, '><')
=> "><><><><><>David A. Black"
```
The padding pattern is repeated as many times as it will fit, truncating the last placement if necessary.

And to round things out in the justification realm, there's a `center` method, which behaves like `rjust` and `ljust` but puts the characters of the string in the center:

```irb
>> "The middle".center(21, "*")
=> "*****The middle*****"
```
Odd-numbered padding spots are rendered right-heavy:

```irb
>> "The middle".center(20, "*")
=> "*****The middle******"
```
Finally, you can prettify your strings by stripping whitespace from either or both sides, using the `strip`, `lstrip` and `rstrip` methods:

```irb
>> string = "   David A. Black    "
=> "    David A. Black    "
>> string.strip
=> "David A. Black"
>> string.lstrip
=> "David A. Black    "
>> string.rstrip
=> "    David A. Black"
```
All three of the string-stripping methods have `!` versions that change the string permanently in place.

#### CONTENT TRANSFORMATIONS ####
The `chop` and `chomp` methods are both in the business of removing characters from the ends of strings-but they go about it differently. The main difference is that `chop` removes a character unconditionally, whereas `chomp` removes a target substring if it finds that substring at the end of the string. By default, `chomp`'s target substring is the newline character, `\n`. You can override the target by providing `chomp` with an argument.

```irb
>> "David A. Black".chop
=> "David A. Blac"
>> "David A. Black\n".chomp
=> "David A. Black"
>> "David A Black".chomp('ck')
=> "David A. Bla"
```
By far, the most common use of either `chop` or `chomp` is the use of `chomp` to remove newlines from the ends of strings, usually strings that come to the program in the form of lines of a file or keyboard input.

Both `chop` and `chomp` have bang equivalents that change the string in place.

On the more radical end of character removal stands the `clear` method, which empties a string of all its characters, leaving the string empty:

```irb
>> string = "David A. Black"
=> "David A. Black"
>> string.clear
=> ""
>> string
=> ""
```
`String#clear` is a great example of a method that changes its receiver but doesn't end with the `!` character. The name `clear` makes it clear, so to speak, that something is happening to the string. There would be no point in having a `clear` method that didn't change the string in place; it would just be a long-winded way to say `""` (the empty string).

If you want to swap out all your characters without necessarily leaving your string bereft of content, you can use `replace`, which takes a string argument and replaces the current content of the string with the content of that argument:

```irb
>> string = "(to be named later)"
=> "(to be named later)"
>> string.replace("David A. Black")
=> "David A. Black"
```
As with `clear`, the `replace` method permanently changes the string-as suggested, once again, by the name.

You can target certain characters for removal from a string with `delete`. The arguments to `delete` follow the same rules as the arguments to `count`.

```irb
>> "David A. Black".delete("abc")
=> "Dvid A. Blk"
>> "David A. Black".delete("^abc")
=> "aac"
>> "David A. Black".delete("a-e", "^c")
=> "Dvid A. Blck"
```
Another specialized string transformation is `crypt`, which performs a Data Encryption Standard (DES) encryption on the string, similar to the UNIX `crypt(3)` library function. The single argument to `crypt` is a two-character salt string:

```irb
>> "David A. Black".crypt("34")
=> "347OEY. 7YRmio"
```
Make sure you read up on the robustness of any encryption techniques you use, including `crypt`.

The last transformations technique we'll look at is string incrementation. You can get the next-highest string with the `succ` method (also available under the name `next`). The ordering of strings is engineered to make sense, even at the expense of string character-code order: `"a"` comes after `"``"` (the backtick character) as it does in ASCII, but after `"z"` comes `"aa"`, not `"{"`. Incrementation continues, odometer-stype throughout the alphabet:

```irb
>> "a".succ
=> "b"
>> "abc".succ
=> "abd"
>> "azz".succ
=> "baa"
```
The ability to increment strings comes in handy in cases where you need batch-generated unique strings, perhaps to use as filenames.

As you've already seen, strings (like other objects) can convert themselves with methods in the `to_*` family. We'll look next at some further details of string conversion.

#### *String conversions* ####
The `to_i` method is one of the conversion methods available to strings. This method offers an additional feature: if you give it a positive integer argument in the range 2-36, the string you're converting is interpreted as representing a number in the base corresponding to the argument.

For example, if you want to interpret 100 as a base 17 number, you can do so like this:
```irb
>> "100".to_i(17)
=> 289
```
The output is the decimal equivalent of 100, base 17.

Base 8 and base 16 are considered special cases and have dedicated methods so you don't have to go the `to_i` route. These methods are `oct` and `hex`, respectively:

```irb
>> "100".oct
=> 64
>> "100".hex
=> 256
```
Other conversion methods available to strings include `to_f` (to float), `to_s` (to string; it returns its receiver), and `to_sym` or `intern`, which converts the string to a `Symbol` object. None of these hold any particular surprises:

```irb
>> "1.2345".to_f
=> 1.2345
>> "Hello".to_s
=> "Hello"
>> "abcde".to_sym
=> "abcde
>> "1.2345and some words".to_f
=> 1.2345
>> "just some words".to_i
=> 0
```
Every string consists of a sequence of bytes. The bytes map to characters. Exactly *how* they map to characters-how many bytes make up a character, and what those characters are-is a matter of *encoding*, which we'll now take a brief look at.

#### *String encoding: a brief introduction* ####
The subject of character encoding is interesting but vast. Encodings are many, and there's far from a global consensus on a single best one. Ruby 1.9 added a great deal of encoding intelligence and functionality to strings. The big change in Ruby 2 was the use of UTF-8, rather than US-ASCII, as the default encoding for Ruby scripts. Encoding in Ruby continues to be an area of ongoing discussion and development. We'll just explore some important encoding-related techniques.

#### SETTING THE ENCODING OF THE SOURCE FILE ####
To start with, your source code uses a certain encoding. By default, Ruby source files use UTF-8 encoding. You can determine this by asking Ruby to display the value `__ENCODING__`. Put this line in a file, and run it:

`puts __ENCODING__`   <---- Output: UTF-8

You need to put the line in a file because you may get different results if you run the command directly from the command line. The reason for the difference is that a fileless Ruby run takes its encoding from the current locale setting. You can verify this by observing the effect of running the same command with the `LANG` environment variable set to a different value:

`LANG=en_US.iso885915 ruby -e 'puts __ENCODING__'`   <---- Output: US-ASCII

To change the encoding of a source file, you need to use a *magic comment* at the top of the file. The magic comment takes the form:

`# encoding: *encoding*`

Where *encoding* is an identifier for an encoding. For example, to encode a source file in US-ASCII, you put this line at the top of the file:

`# encoding: ASCII`

This line (which can use the word *coding* rather than the word *encoding*, if you prefer) is sometimes referred to as a "magic comment".

In addition to your source file, you can also query and set the encoding of individual strings.

#### ENCODING OF INDIVIDUAL STRINGS ####
Strings will tell you their encoding:

```irb
>> str = "Test string"
=> "Test string"
>> str.encoding
=> #<Encoding:US-ASCII>
```
You can encode a string with a different encoding, as long as the conversion from the original encoding to the new one--the *transcoding*--is permitted (which depends on the capability of the string with the new encoding):

```irb
>> str.encode("US-ASCII")
=> "Test string"
```
If you need to, you can force an encoding with the `force_encoding` method, which bypasses the table of "permitted" encodings and encodes the bytes of the string with the encoding you specify, unconditionally.

The bang version of `encode` changes the encoding of the string permanently:

```irb
>> str.encode!("US-ASCII")
=> "Test string"
>> str.encoding
=> #<Encoding:US-ASCII>
```
The encoding of a string is also affected by the presence of certain characters in a string and/or by the amending of the string with certain characters. You can represent arbitrary characters in a string using either the `\x` escape sequence for a two-digit hexadecimal number representing a byte, or the `\u` escape sequence, which is followed by a UTF-8 code, and inserts the corresponding character.

The effect on the string's encoding depends on the character. Given an encoding of US-ASCII, adding an escaped character in the range 0-127 (0x00-ox7F in hexadecimal) leaves the encoding unchanged. If the character is in the range 128-155 (0xA00xFF), the encoding switches to UTF-8. If you add a UTF-8 character in the range 0x0000-0x007F, the ASCII string's encoding is unaffected. UTF-8 codes higher than 0x007F cause the string's encoding to switch to UTF-8. Here's an example:

```irb
>> str = "Test string"
=> "Test string"
>> str.encode!("US-ASCII")
=> "Test string"
>> str << ". Euro symbol: \u20AC"    #<----1.
=> "Test string. Euro symbol: €"
>> str.encoding
=> #<Encoding:UTF-8>
```
The `\u` escape sequence (#1.) lets you insert any UTF-8 character, whether you can type it directly or not. (Didn't actually work in my irb)

There's a great deal more to the topic of character and string encoding, but you've seen enough at this point to know the kinds of operations that are available. How deeply you end up exploring encoding will depend on your needs as a Ruby developer. Again, be aware that encoding has tended to be the focus of particularly intense discussion and development in Ruby (and elsewhere).

At this point, we'll wrap up our survey of string methods and turn to a class with some string affinities with the `String` class but also some interesting differences: the `Symbol` class.

## *Symbols and their uses* ##
*Symbols* are instances of the built-in Ruby class `Symbol`. They have a literal constructor: the leading colon. You can always recognize a symbol literal (and distinguish it form a string, a variable name, a method name, or anything else) by this token:

```ruby
:a
:book
:"Here's how to make a symbol with spaces in it."
```
You can also create a symbol programmatically by calling the `to_sym` method (also known by the synonym `intern`) on a string, as you saw in the last section:

```irb
>> "a".to_sym
=> :a
>> "Converting string to symbol with intern....".intern
=> :"Converting string to symbol with intern...."
```

Note the telltale leading colons on the evaluation results returned by irb.

You can easily convert a symbol to a string:

```irb
>> :a.to_s
=> "a
```
That's just the beginning though. Symbols differ from strings in important ways. Let's look at symbols on their own terms and then come back to a comparative look at symbols and strings.

### *Chief characteristics of symbols* ###
Symbols are a hard nut to crack for many people learning Ruby. They're not quite like anything else, and they don't correspond exactly to data types most people have come across previously. In some respects they're rather stringlike, but at the same time, they have a lot in common with integers. It's definitely worth a close look at their chief characteristics: immutability and uniqueness.

#### IMMUTABILITY ####
Symbols are immutable. There's no such thing as appending characters to a symbol; once the symbol exists, that's it. You'll never see `:abc << :d` or anything of that kind.

That's not to say that there's no symbol `:abcd`. Like an integer, a symbol can't be changed. When you want to refer to `5`, you don't change the object `4` by adding `1` to it. You can add `1` to `4` by calling `4.+(1)` (or `4 + 1`), but you can't cause the object `4` to be object `5`. Similarly, although you can use a symbol as a hint to Ruby for the generation of another symbol, you can't alter a given symbol.

#### UNIQUENESS ###
Symbols are unique. Whenever you see `:abc` you're seeing a representation of the same object. Again, symbols are more like integers than strings in this respect. When you see the notation `"abc"` in two places, you're looking at two different representations of two different string objects; the literal constructor `""` creates a new string. But `:abc` is always the same `Symbol` object, just as `100` is always the same object.

You can see the different between strings and symbols in the matter of uniqueness by querying objects as to their `object_id`, which is unique for every separate object:

```irb
>> "abc".object_id
=> 10615980
>> "abc".object_id
=> 10612200
>> :abc.object_id
=> 1181788
>> :abc.object_id
=> 1181788
```
The `"abc"` notation creates a new string each time, as you can see from the fact that each such string has a different object ID. But the `:abc` notation always represents the same object, `:abc` identifies itself with the same ID number no matter how many times you ask it.

Because symbols are unique, there's no point having a constructor for them; Ruby has no `Symbol#new` method. You can't create a symbol any more than you can create a new integer. In both cases, you can only refer to them.

The word *symbol* has broad connotations; it sounds like it might refer to any identifier or token. It's important to get a handle on the relation between symbol objects and symbols in a more generic sense. 
