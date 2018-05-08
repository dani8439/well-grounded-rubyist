### *Array conversion with to_a and the * operator* ###
The `to_a` (to array) method, if defined, provides an array-like representation of objects. One of `to_a`'s most striking features is that it automatically ties in with the * operator. The * operator (pronounced "star," "unarray," or, among the whimsically inclined, "splat") does a kind of unwrapping of its operand into its components, those components being the elements of its array
representation.

You've already seen the star operator used in method parameter lists, where it denotes a parameter that sponges up the optional arguments into an array. In the more general case, the star turns any array, or any object that responds to `to_a` into the equivalent of a bare list.

The term *bare list* means several identifiers or literal objects separated by commas. Bare lists are valid syntax only in certain contexts. For example, you can put a bare list inside the literal array constructor brackets:

`[1,2,3,4,5]`

It's a subtle distinction, but the notation lying between the brackets isn't an array; it's a list, and the array is constructed from the list, thanks to the brackets.

The star has a kind of bracket-removing or unarraying effect. What starts as an array becomes a list. You can see this if you construct an array from a starred array:

```irb
>> [array}
=> [[1, 2, 3, 4, 5]]
```
Here, the list from which the new array gets constructed contains one item: the object `array`. That object hasn't been mined for its inner elements, as it was in the example within the star.

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

As you'll see if you experiment with converting strings to integer (which you can do easily in irb with expressions like "hello".to_i), the `to_i` conversion value of strings that have no reasonable integer equivalent (including `"Hello"`) is always `0`. If your string starts with digits but isn't made up entirely of digits (`"123hello"`), the nondigit parts are ignored and the conversion is performed only on the leading digits.

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
When you call methods like `to_s`, `to_i`, and `to_f`, the result is a new object (or the receiver, if you're converting it to its own class). It's not quite the same as typecasting in C and other languages. You're not using the object as a string or an integer; you're asking the object to provide a second object that corresponds to its idea of itself (so to speak) in one of those forms.

The distinction between conversion and typecasting touches on some important aspects of the heart of Ruby. In a sense, all objects are typecasting themselves constantly. Every time you call a method on an object, you're asking the object to behave as a particular type. Correspondingly, an object's "type" is really the aggregate of everything it can do at a particular time.

The closest Ruby gets to traditional typecasting (and it isn't very close), is the role=playing conversion methods described below.

### *Role-playing to_ methods* ###
It's somewhat against the grain in Ruby programming to worry much about what class an object belongs to. All that matters is what the object can do-what methods it can execute.

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

#### **ARRAY ROLE-PLAYING WITH TO_ARY** ####
Objects can masquerade as arrays if they have a `to_ary` method. If such a method is present, it's called on the object in cases where an array, and only an array, will do- for example, in an array-concatenation operation.

Here's another `Person` implementation, where the array role is played by an array containing three person attributes:

```ruby
class Person
  attr_accessor :name, :age, :email
  def to_ary
    [name, age, email]
  end
end

```

Concatenating a `Person` object to an array has the effect of adding the name, age, and email values to the target array:

```ruby
david = Person.new
david.name = "David"
david.age = 55
david.email = "david@whatever"
array = []
array.concat(david)
p array                 #<---Output: ["David", 55, "david@whatever"]
```
Like `to_str`, `to_ary` provides a way for an object to step into the role of an object of a particular core class. As is usual in Ruby, sensible usage of conventions is left up to you. It's possible to write a `to_ary` method, for example, that does something other than return an array-but you'll almost certainly get an error message when you try to use it, as Ruby looks to `to_ary` for an array. So if you're going to use the role-playing `to_*` methods, be sure to play in Ruby's ballpark.

We'll turn now to the subject of Boolean states and objects in Ruby, a topic we've dipped into already, but one that merits closer inquiry.

## *Boolean states, Boolean objects, and nil* ##
Every expression in Ruby evaluates to an object, as every object has a Boolean value of either *true* or *false*. Furthermore, `true` and `false` are objects. This idea isn't as convoluted as it sounds. If `true` and `false` weren't objects, then a pure Boolean expression like

`100 > 80`

would have no object to evaluate *to*. (And `>` is a method and therefore has to return an object.)

In many cases where you want to get at a truth/falsehood value, such as an `if` statement or a comparison between two numbers, you don't have to manipulate these special objects directly. In such situations, you can think of truth and falsehood as *states*, rather than objects.

We'll look at `true` and `false` both as states and as a special objects, along with the special object `nil`.

### *True and false as states* ###
Every expression in Ruby is either true or false, in a logical or Boolean sense. The best way to get a handle on this is to think in terms of conditional statements. For every expression *e* in Ruby, you can do this

`if e`

and Ruby can make sense of it.

For lots of expressions, a conditional test is a stretch; but it can be instructive to try it on a variety of expressions, as the following listing shows (boolean.rb)

```ruby
if (class MyClass; end)                     #<----1.
  puts "Empty class definition is true!"
else
  puts "Empty class definition is false!"
end

if (class MyClass; 1; end)                              #<----2.
  puts "Class definition with the number 1 in it is true!"
else
  puts "Class definition with the number 1 in it is false!"
end

if (def m; return false; end)              #<----3.
  puts "Method definition is true!"
else
  puts "Method definition is false!"
end

if "string"                              #<----4.
  puts "Strings appear to be true!"
else
  puts "Strings appear to be false!"
end

if 100 > 50                                #<----5.
  puts "100 is greater than 50!"
else
  puts "100 is not greater than 50!"
end
```
Here is the output from the listing (ignore the warning about using a string literal in a conditional):

```irb
boolean.rb:23: warning: string literal in condition
Empty class definition is false!
Class definition with the number 1 in it is true!
Method definition is true!
Strings appear to be true!
100 is greater than 50!
```
As you see, empty class definitions(#1) are false; nonempty class definitions evaluate to the same value as the last value they contain (#2) (in this example, the number 1); method definitions are true (#3) (even if a call *to* the method would return false); strings are true (#4) (don't worry about the string literal in condition warning); and 100 is greater than 50 (#5). You can use this simple `if` technique to explore the Boolean value of any Ruby expression.

The `if` examples show that every expression in Ruby is either true or false in the sense of either passing or not passing an `if` test. But these examples don't show what the expressions evaluate to. That's what the `if` test is testing: it evaluates an expression (such as `class MyClass; end`) and proceeds on the basis of whether the value produced by that evaluation is true.

To see what values are returned by the expressions whose truth value we've been testing, you can derive those values in irb:

```irb
2.3.1 :001 > class MyClass; end       #<---1.
 => nil
2.3.1 :002 > class MyClass; 1; end      #<---2.
 => 1
2.3.1 :003 > def m; return false; end     #<---3.
 => :m
2.3.1 :004 > "string literal!"          #<---4.
 => "string literal!"
2.3.1 :005 > 100 > 50                  #<---5.
 => true
2.3.1 :006 >
```
The empty class definition (#1) evaluates to `nil`, which is a special object (discussed further in this chapter). All you need to know for the moment about `nil` is that it has a Boolean value of false (as you can detect from the behavior of the `if` clauses that dealt with it earlier).

The class definition with the number 1 in it (#2) evaluates to the number 1, because every class definition block evaluates to the last expression contained inside of it, or `nil` if the block is empty.

The method definition evaluates to the symbol `:m` (#3), representing the name of the method that's just been defined.

The string `literal` (#4) evaluates to itself; it's a literal object and doesn't have to be calculated or processed into some other form when evaluated. Its value as an expression is itself.

Finally, the comparison expression `100 > 50` (#5) evaluates to `true`-not just to something that has the Boolean value true, but to the object `true`. The object `true` does have the Boolean value true. But along with `false`, it has a special role to play in the realm of truth and falsehood and how they're represented in Ruby.

#### *true and false as objects* ####
The Boolean objects `true` and `false` are special objects, each being the only instance of a class especially created for it: `TrueClass` and `FalseClass`, respectively. You can ask `true` and `false` to tell you their classes' names, and they will:

```ruby
puts true.class     #<--- Output: TrueClass
puts false.class    #<--- Output: FalseClass
```
The terms `true` and `false` are keywords. You can't use them as variable or method names; they're reserved for Ruby's exclusive use.

You can pass the objects `true` and `false` around, assign them to variables, and examine them like any other object. Here's an irb session that puts `true` through its paces in its capacity as a Ruby object:

```irb
2.3.1 :001 > a = true
 => true
2.3.1 :002 > a = 1 unless a
 => nil
2.3.1 :003 > a
 => true
2.3.1 :004 > b = a
 => true
```
You'll sometimes see `true` and `false` used as method arguments. For example, if you want a class to show you all of its instance methods but to exclude those defined in ancestral classes, you can provide the argument `false` to your request:

`>> String.instance_methods(false)`

The problem with Boolean arguments is that it's very hard to remember what they do. They're rather cryptic. Therefore, it's best to avoid them in your own code, unless there's a case where the true/false distinction is very clear.

Let's summarize the true/false situation in Ruby with a look at Boolean states versus Boolean values.

#### **TRUE/FALSE: STATES VS. VALUES** ####
As you now know, every Ruby expression is true or false in a Boolean sense (as indicated by the `if` test), and there are also objects called `true` and `false`. This double usage of the true/false terminology is sometimes a source of confusion: when you say that something is true, it's not always clear whether you mean it has a Boolean truth value or that it's the object `true`.

Remember that every expression has a Boolean value-including the expression `true` and the expression `false`. It may seem awkward to have to say, "The object `true` is true." But that extra step makes it possible for the model to work consistently.

Building on this point, and on some of the cases you saw in slightly different for earlier, the following table shows a mapping of some sample expressions to both the outcome of their evaluation and their Boolean value.

Not in particular that zero and empty strings (as well as empty arrays and hashes) have a Boolean value of true. The only objects that have a Boolean value of false are `false` and `nil`.

#### **Mapping sample expressions to their evaluation results and Boolean values** ####
|     Expression    | Object to which expression evaluates  |     Boolean value of expression       |
|-------------------|---------------------------------------|---------------------------------------|
| `1`               |  `1`                                  | True                                  |
| `0`               |  `0`                                  | True                                  |
| `1+1`             |  `2`                                  | True                                  |
| `true`            |  `true`                               | True                                  |
| `false`           |  `false`                              | False                                 |
| `nil`             |  `nil`                                | False                                 |
| `"string"`        |  `"string"`                           | True                                  |
| `""`              |  `""`                                 | True                                  |
| `puts "string"`   |  `nil`                                | False                                 |
| `100 > 50         |  `true`                               | True                                  |
| `x = 10`          |  `10`                                 | True                                  |
| `def x; end`      |  `:x`                                 | True                                  |
| `class C; end`    |  `nil`                                | False                                 |
| `class C; 1; end` |  `1`                                  | True                                  |

And on the subject of `nil`: it's time for us to look more closely at this unique object.

### *The special object nil* ###
