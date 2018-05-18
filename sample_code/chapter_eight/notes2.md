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
To start with, your source code uses a certain encoding. By default, Ruby source files use UTF-8 encoding. You can determine this by asking Ruby to display the value `__ENCODING__`. 
