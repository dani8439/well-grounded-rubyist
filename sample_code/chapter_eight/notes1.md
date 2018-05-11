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
