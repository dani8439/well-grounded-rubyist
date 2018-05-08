### *Array conversion with to_a and the * operator* ###
The `to_a` (to array) method, if defined, provides an array-like representation of objects. One of `to_a`'s most striking 
features is that it automatically ties in with the * operator. The * operator (pronounced "star," "unarray," or, among the whimsically 
inclined, "splat") does a kind of unwrapping of its operand into its components, those components being the elements of its array 
representation. 

You've already seen the star operator used in method parameter lists, where it denotes a parameter that sponges up the optional arguments into an arrya. In the more general case, the star turns any array, or any object that responds to `to_a` into the equivalent of a bare list. 

The term *bare list* means several identifiers or literal objects separated by commas. Bare lists are valid syntax only in certain contexts. For example, you can put a bare list inside the literal array constructor brackets:

`[1,2,3,4,5]`

It's a subtle distinction, but the notation lying between the brackets isn't an array; it's a list, and the array is constructed from the list, thanks to the brackets. 

The star has a kind of bracket-removing or unarraying effect. What starts as an array becomes a list. You can see this if you construct an array from a starred array: 

```irb 
>> [array}
=> [[1, 2, 3, 4, 5]]
```
Here, the list from which the new array gets constructed contains one item: the object `array`. That object hasn't been mined for its inner elements, as it was in the example within the stary.

One implication is that you can use the star in front of a method argument to turn it from an array into a list. You do this in cases where you have objects in an array that you need to send to a method that's expecting a broken-out list of arguments:

```ruby
def combine_names(first_name, last_name)
  first_name + " " + last_name
end
names = ["David", "Black"]
puts combine_names(*names)    #<--- Output: David Black
```
If you don't use the unarraying star, you'll send just one argument-an array-to the method, and the method won't be happy. Let's return to numbers. 

### *Numerical conversion with to_i and to_f* ###
Unlike some programming languages, such as Perl, Ruby doesn't automatically convert from strings to numbers or numbers to strings. You can't do this:

`>> 1 + "2"`   <---TypeError: String can't be coerced into a Fixnum 

because Ruby doesn't know how to add a string and an integer together. And you'll get a surprise if you do this:

```ruby 
print "Enter a number: "
n = gets.chomp 
puts n * 100
```
You'll see the string version of the number printed out 100 times. (This result also tells you that Ruby lets you multiply a string-but it's always treated as a string, even if it consists of digits.) If you want the number, you have to turn it into a number explicitly:

` n = gets.to_i`

As you'll see if you experiment wtih converting strings to integer (which you can do easily in irb with expressions like "hello".to_i), the `to_i` conversion value of strings that have no reasonable integer equivalent (including `"Hello"`) is always `0`. If your string starts with digits but isn't made up entirely of digits (`"123hello"`), the nondigit parts are ignored and the conversion is performed only on the leading digits.

The `to_f` (to float) conversion gives you, predictably, a floating-point equivalent of any integer. The rules pertaining to nonconforming characters are similar to those governing string-to-integer conversions: `"hello".to_f` is `0.0`, whereas `"1.23hello".to_f` is `1.23`. If you call `to_f` on a float, you get the same float back. Similarly, calling `to_i` on an integer returns that integer. 

If the conversion rules for strings seem a little lax to you-if you don't want strings like `"-5xyz"` to succeed in converting themselves to integers or floats-you have a couple of stricter conversion techniques available to you.

#### STRICTER CONVERSIONS WITH INTEGERS AND FLOATS #### 
Ruby provides methods called `Integer` and `Float` (and yes, they look like constants, but they're methods with names that coincide with those of the classes to which they convert). These methods are similar to `to_i` and `to_f`, respectively, but a little stricter: if you feed them anything that doesn't conform to the conversion target type, they raise an exception:

```irb 
>> "123abc".to_i
=> 123
>> Integer("123abc")
ArgumentError: invalid value for Integer(): "123abc"
>> Float("3")
=> 3.0
>> Float("-3")
=> -3.0
>> Float("-3xyz")
ArgumentError: invalid value for Float(): "-3xyz"
``` 
(Note that converting from an integer to a float is acceptable. It's the letters that cause the problem.)

If you want to be strict about what gets converted and what gets rejected, `Integer` and `Float` can help you out. 

Getting back to the `to_i*` family of converters: in addition to the straightforward object-conversion methods, Ruby gives you a couple of `to_*` methods that have a little extra intelligence about what their value is expected to do. 

**Conversion vs. typecasting** 
When you call methods like `to_s`, `to_i`, and `to_f`, the result is a new object (or the receiver, if you're converting it to its own class). It's not quite the same as typcasting in C and other languages. You're not using the object as a string or an integer; you're asking the object to provide a second object that corresponds to its idea of iteself (so to speak) in one of those forms. 

The distinction between conversion and typecasting touches on some important aspects of the heart of Ruby. In a sense, all objects are typecasting themselves constantly. Every time you call a method on an object, you're asking the object to behave as a particular type. Correspondingly, an object's "type" is really the aggregate of everything it can do at a particular time. 

The closest Ruby gets to traditional typecasting (and it isn't very close), is the role=playing conversion methods described below. 

### *Role-playing to_ methods* ### 
It's somewhat against the grain in RUby programming to worry much about what class an object belongs to. All that matters is what the object can do-what methods it can execute. 

But in a few cases involving the core classes, strict attention is paid to the class of objects. Don't think of this as a blueprint for "the Ruby way" of thinking about objects. It's more like an expediency that bootstraps you into the world of the core objects in such a way that once you get going, you can devote less thought to your objects' class memberships. 

#### **STRING ROLE-PLAYING WITH TO_STR** #### 
If you want to print an object, you can define a `to_s` method for it or use whatever `to_s` behavior it's been endowned with by its class. But what if you need an object to *be* a string?

The answer is that you define a `to_str` method for the object. An object's `to_str` representation enters the picture when you call a core method that requires that its argument be a string.

The classic example is string addition. Ruby lets you add two strings together, producing a third string: 

```irb 
>> "Hello " + "there."
=> "Hello there."
```
If you try to add a nonstring to a string, you get an error:

```irb 
>> "Hello " _ 10
TypeError: no implicit conversion of Float into String
```
This is where `to_str` comes in. If an object responds to `to_str`, its `to_str` representation will be used when the object is used as the argument to `String#+`.

Here's an example involving a simple `Person` class. The `to_str` method is a wrapper around the `name` method:

```ruby 
class Person 
  attr_accessor :name
  def to_str 
    name 
  end
end
```
If you create a `Person` object and add it to a string, `to_str` kicks in with the `name` string: 

```ruby 
david = Person.new 
david.name = "David" 
puts "david is named " + david + "."    #<--- Output: david is named David.
```
The `to_str` conversion is also used on arguments to the `<<` (append to string) method. And arrays, like strings, have a role-playing conversion method.
