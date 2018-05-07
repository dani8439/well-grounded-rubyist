• *Literal Constructors*-ways to create certain objects with syntax, rather than with a call to `new`.

• *Syntactic Sugar*-things Ruby lets you do to make your code look nicer.

•*"Dangerous" and/or destructive methods*-Methods that alter their receivers permanently; and other "danger" considerations.

•*The `to_` family of conversion methods*-Methods that produce a conversion from an object to an object of a different class, and the syntactic features that hook into those methods.

•*Boolean states and objects, and `nil`*-A close look at `true` and `false` and related concepts in Ruby.

•*Object-comparison techniques*-Ruby-wide techniques, both default and customizable, for object-to-object comparison.

•*Runtime inspection of objects' capabilities*-An important set of techniques for runtime reflection on the capabilities of an object.

## *Ruby's literal constructors* ##
Ruby has a lot of built-in classes. Most of them can be instantiated using `new`.

```ruby
str = String.new
arr = Array.new
```
Some can't; for example, you can't create a new instance of the class `Integer`. But for the most part, you can create new instances of the built-in classes.

In addition, a lucky, select few built-in classes enjoy the privilege of having *literal constructors*. That means you can use special notation instead of a call to `new`, to create a new object of that class.

The classes with literal constructors are shown in the table below. When you use one of these literal constructors, you bring a new object into existence. (Although, it's not obvious from the table, it's worth nothing that there's no `new` constructor for `Symbol` objects. The only way to generate a `Symbol` object is with the literal constructor.)

Literal constructors are never the only way to instantiate an object of a given class, but they're very commonly used.

#### **Built-In Ruby Classes with literal constructors** ####
|       Class       |         Literal Constructor         |               Example(s)                  |
|-------------------|-------------------------------------|-------------------------------------------|
|   `String`        | Quotation marks                     | `"new string"`           `'new string'`   |
| `Symbol`          | Leading colon                       | `:symbol`         `:"symbol with spaces"` |
|   `Array`         | Square brackets                     | `[1,2,3,4,5]`                             |
| `Hash`            | Curly brackets                      | `{"New York" => "NY", "Oregon" => "OR"}`  |
| `Range`           | Two or three dots                   | `0..9` or `0...10`                        |
| `Regexp`          | Forward slashes                     | `/([a-z]+)/`                              |
| `Proc (lambda)`   | Dash, arrow, parentheses, braces    | `-> (x,y) { x * y }`                      |

**Literal constructor characters with more than one meaning**
Some of the notation used for literal constructors has more than one meaning in Ruby. Many objects have a method called `[]` that looks like a literal array constructor but isn't. Code blocks, as we've seen, can be delimited with curly braces-but they're still code blocks, not hash literals. This kind of overloading of notation is a consequence of the finite number of symbols on the keyboard. You can also tell what the notation means by its context, and there are few enough contexts that, with a little practice, it will be easy to differentiate.

## Recurrent syntactic sugar ##
Ruby sometimes let you use sugary notation in place of the usual `object.method(args)` method-calling syntax. This lets you do nice-looking things, such as using a plus sign between two numbers like an operator

`x = 1 + 2`

instead of the odd-looking method-style equivalent:

`x = 1.+(2)`

As you delve more deeply into Ruby and its built-in methods, be aware that certain methods always get this treatment. The consequence is that you can define how your objects behave in code like this

`my_object + my_other_object`

simply by defining the `+` method. You've seen this process at work, particularly in connection with case equality and defining the `===` method. But now let's look more extensively at this elegant technique.

### *Defining operators by defining methods* ###
If you define a `+` method for your class, then objects of your class can use the sugared syntax for addition. Moreover; there's no such thing as defining the meaning of that syntax separately from defining the method. The operator is the method. It just looks nicer as an operator.

Remember; too, that the semantics of methods like `+` are entirely based on convention. Ruby doesn't know that `+` means addition. Nothing (other than good judgment) stops you from writing completely nonaddition-like `+` methods:

```ruby
obj = Object.new
def obj.+(other_obj)
  "Trying to add something to me, eh?"
end
puts obj + 100    #<--- No addition, just output : Trying to add something to me, eh?
```
The plus sign in the `puts` statement is a call to the `+` method of `obj` with the integer `100` as the single (ignored) argument.

Layered on top of the operator-style sugar is the shortcut sugar: `x += 1` for `x = x + 1`. Once again, you automatically reap the sugar harvest if you define the relevant method(s). Here's an example-a bank account class with `+` and `-` methods:

```ruby
class Account
  attr_accessor :balance
  def initialize(amount=0)
    self.balance = amount
  end
  def +(x)
    self.balance += x
  end
  def -(x)    #<---- 1.
    self.balance -= x
  end
  def to_s
    balance.to_s
  end
end
acc = Account.new(20)
acc -= 5       #<----- 2.
puts acc       #<---- Output 15
```
By defining the `-` instance method(#1.) we gain the `-=` shortcut, and can subtract from the account using that notation (#2). This is a simple but instructive example of the fact that Ruby encourages you to take advantage of the very same "wiring" that the language itself uses, so as to integrate your programs as smoothly as possible into the underlying technology.

Automatically sugared methods collected below:

#### Methods with operator-style syntactic sugar-calling notation ####
|     Category      |   Name    |   Definition example   |   Calling example   |   Sugared Notation   |
|-------------------|-----------|------------------------|---------------------|----------------------|
| Arithmetic method/ operators | `+`  | `def + (x)`      | `obj.+(x)`          | `obj + x`            |
|                   | `-`       | `def - (x)`            | `obj.-(x)`          | `obj - x`            |
|                   | `*`       | `def * (x)`            | `obj.*(x)`          | `obj * x`            |
|                   | `/`       | `def / (x)`            | `obj./(x)`          | `obj / x`            |
|                   | `%` modulo | `def % (x)`           | `obj.%(x)`          | `obj % x`            |
|                   | `**` exponent | `def ** (x)`       | `obj.%(x)`          | `obj % x`            |
| Get/set/append data | `[]`    | `def [](x)`            | `obj.[](x)`         | `obj[x]`             |
|                   | `[]=`     | `def []=(x,y)`         | `obj.[]=(x,y)`      | `obj[x] = y`         |
|                   | `<<`      | `def << (x)`           | `obj.<<(x)`         | `obj << x`           |
|Comparison method/operators| `<=>` |`def <=> (x)`       | `obj.<=>(x)`        | `obj <=> x`          |
|                   | `==`      | `def == (x)`           | `obj.==(x)`         | `obj == x`           |
|                   | `>`       | `def > (x)`            | `obj.>(x)`          | `obj > x`            |
|                   | `<`       | `def < (x)`            | `obj.<(x)`          | `obj < x`            |
|                   | `>=`      | `def >= (x)`           | `obj.>=(x)`         | `obj >= x`           |
|                   | `<=`      | `def <= (x)`           | `obj.<=(x)`         | `obj <= x`           |
|Case equality operator | `===` | `def === (x)`          | `obj.===(x)`        | `obj === x`          |
| Bitwise operators | `|` (OR)  | `def | (x)`            | `obj.|(x)`          | `obj | x`            |
|                   | `&` (AND) | `def & (x)`            | `obj.&(x)`          | `obj & x`            |
|                   | `^` (XOR) | `def ^ (x)`            | `obj.^(x)`          | `obj ^ x`            |

Remembering which methods get the sugar treatment isn't difficult. They fall into several distinct categories (as shown in table above). These categories are for the convenience of learning and reference only; Ruby doesn't categorize the methods, and the responsibility for implementing meaningful semantics lies with you. The category names indicate how these method names are used in Ruby's built-in classes and how they're most often used, by convention, when programmers implement them in new classes.

(Don't forget, too, the conditional assignment operator `||=`, as well as its rarely spotted cousin `&&=`, both of which provide the same kind of shortcut as the pseudo-operator methods but are based on operators, namely `||` and `&&`, that you can't override.)

The extensive use of this kind of syntactic sugar-where something *looks like* an operator but *is* a method call-tells you a lot about the philosophy behind Ruby as a programming language. The fact that you can define and even redefine elements like the plus sign, minus sign, and square brackets means that Ruby has a great deal of flexibility. But there are limits to what you can redefine in Ruby. You can't redefine any of the literal object constructors: `{}` is always a hash literal (or a code block, if it appears in that context). `""` will always delimit a string, and so forth.

But there's plenty that you can do. You can even define some unary operators via methods definitions.

### *Customizing unary operators* ###
The unary operators `+` and `-` occur most frequently as signs for numbers, as in `-1`. But they can be defined; you can specify the behavior of the expressions `+obj` and `-obj` for your own objects and classes. You do so by defining the methods `+@` and `-@`.

Let's say that you want `+` and `-` to mean uppercase and lowercase for a stringlike object. Here's how you define the appropriate unary operator behavior, using a `Banner` class as an example:

```ruby
class Banner
  def initialize(text)
    @text = text
  end

  def to_s   #<---1.
    @text
  end

  def +@
    @text.upcase
  end

  def -@
    @text.downcase
  end
end
```
Now create a banner, and manipulate its case using the unary `+` and `-` operators:

```ruby
banner = Banner.new("Eat at David's!")
puts banner      #<---- Output: Eat at David's!
puts +banner     #<---- Output: EAT AT DAVID'S!
puts -banner     #<---- Output: eat at david's!
```
The basic string output for the banner text, unchanged, is provided by the `to_s` conversion method(#1), which we'll see up close later on.

You can also define the `!` (logical *not*) operator, by defining the `!` method. In fact, defining the `!` method gives you both the unary `!` and the keyword `not`. Let's add a definition to `Banner:`

```ruby
class Banner
  def !
    reverse
    #In code example, this does not work, nor does self.reverse, have to add reverse method onto instance variable @text.reverse. Otherwise get undefined local variable or method for 'reverse'
  end
end
```
Now examine the banner, "negated." We'll need to use parentheses around the `not` version to clarify the precedence of expressions (otherwise `puts` things we're trying to print `not`):

```ruby
puts !banner          #Output: !s'divaD ta taE
puts (not banner)     #Output: !s'divaD ta taE
```
As it so often does, Ruby gives you an object-oriented, method-based way to customize what you might at first think are hardwired syntactic features-even unary operators like `!`. Unary negation isn't the only use Ruby makes of the exclamation point.
