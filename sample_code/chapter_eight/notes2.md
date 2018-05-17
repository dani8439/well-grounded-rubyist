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

