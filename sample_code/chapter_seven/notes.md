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
| Bitwise operators | OR defined below|                  |                     |                      |
|                   | `&` (AND) | `def & (x)`            | `obj.&(x)`          | `obj & x`            |
|                   | `^` (XOR) | `def ^ (x)`            | `obj.^(x)`          | `obj ^ x`            |

OR: `|` OR    `def | (x)`             `obj.|(x)`           `obj | x`            

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

## *Bang (!) methods and "danger"* ##
Ruby methods can end with an exclamation point (`!`), or bang. The bang has no significance to Ruby internally; bang methods are called and executed just like any other methods. But by convention, the bang labels a method as "dangerous"-specifically, as the dangerous equivalent of a method with the same name but without the bang.

*Dangerous* can mean whatever the person writing the method wants it to mean. In the case of the built-in classes, it usually means *this method, unlike its nonbang equivalent, permanently modifies its receiver.* It doesn't always, though,: `exit!` is a dangerous alternative to `exit`, in the sense that it doesn't run any finalizers on the way out of the program. The danger in `sub!` (a method that substitutes a replacement string for a matched pattern for a string) is partly that it changes its receiver and partly that it returns `nil`, if not change has taken place-unlike `sub`, which always returns a copy of the original string with the replacement (or no replacement) made.

If "danger" is too melodramatic for you, you can think of the `!` in method names as a kind of `Heads up!` And, with very few, very specialized exceptions, every bang method should occur in a pair with a nonbang equivalent. We'll return to the questions of best method-naming practice after we've looked at some bang methods in action.

### *Destructive (receiver-changing) effects as danger* ###
No doubt most of the bang methods you've come across in the core Ruby language have the bang on them because they're destructive: they change the object on which they're called. Calling `upcase` on a string gives you a new string consisting of the original string in uppercase: but `upcase!` turns the original string into its own uppercase equivalent, in place:

```irb
>> str = "Hello"
=> "Hello"
>> str.upcase
=> "HELLO"
>> str
=> "Hello"           <----- 1.
>> str.upcase!
=> "HELLO"
>> str
=> "HELLO"          <------- 2.
```

Examining the original string after converting it to uppercase shows that the uppercase version was a copy; the original string is unchanged (#1). But the bang operation has changed the content of `str` itself (#2.)

Ruby's core classes are full of destructive (receiver-changing) bang methods paired with their nondestructive counterparts: `sort/sort!` for arrays, `strip/strip!` (strip leading and trailing whitespace) for strings, `reverse/reverse!` for strings, and arrays, and many more. In each new case, if you call the nonbang version of the method on the object, you get a new object. If you call the bang version, you operate in-place on the same object to which you sent the message.

You should always be aware of whether the method you're calling changes its receiver. Neither option is always right or wrong: which is best depends on what you're doing. One consideration, weighing in on the side of modifying objects instead of creating new ones, is efficiency: creating new objects (like a second string that's identical to the first except for one letter) is expensive in terms of memory and processing. This doesn't matter if you're dealing with a small number of objects. But when you get into, say, handling data from large files and using loops and iterators to do so, creating new objects can be a drain on resources.

On the other hand, you need to be cautious about modifying objects in place, because other parts of the program may depend on those objects not to change. For example, let's say you have a database of names. You read the names out of the database into an array. At some point, you need to process the names for printed output-all in capital letters. You may do something like this:

```ruby
names.each do |name|
  capped = name.upcase
  # ...code that does something with capped...
end
```
In this example, `capped` is a new object-an uppercase duplicate of `name`. When you go through the same array later, in a situation where you *do not* want the names in uppercase, such as saving them back to the database, the names will be the way they were originally.

By creating a new string (`capped`) to represent the uppercase version of each name, you avoid the side effect of changing the names permanently. The operation you perform on the names achieves its goals without changing the basic state of the data. Sometimes you'll want to change an object permanently, and sometimes you won't want to. There's nothing wrong with that, as long as you know which you're doing and why.

Furthermore, don't assume a direct correlation between bang methods and destructive methods. They often coincide, but they're not the same thing.

### *Destructiveness and "danger" vary independently* ###
What follows here is some commentary on conventions and best practices. Ruby doesn't care; Ruby is happy to execute methods whose names end in `!` whether they're dangerous, safe, paired with a nonbang method, not paired-whatever. The value of the `!` notation as a token of communication between a method author and a user of that method resides entirely in conventions. It's worth gaining a solid understanding of those conventions and why they make sense.

The best advice on when to use bang-terminated method names is...

#### **DON'T USE ! EXCEPT IN M/M! METHOD PAIRS** ####
The `!` notation for a method name should only be used when there's a method of the same name without the `!`, when the relation between those two methods is that they both do substantially the same thing, and when the bang version also has side effects, a different return value, or some other behavior that diverges from its nonbang counterpart.

Don't use the `!` just because you think your method is dangerous in some vague, abstract way. All methods do something: that in itself isn't dangerous. The `!` is a warning that there may be more going on than the name suggests-and that, in turn, makes sense only if the name is in use for a method that doesn't have the dangerous behavior.

Don't name a method `save!` just because it writes to a file. Call that method `save` and then, if you have another method that writes to a file but (say) doesn't back up the original file (assuming that `save` does so), go ahead and call that one `save!`.

If you find yourself writing one method to write to the file, and you put a `!` at the end because you're worried the method is too powerful or too unsafe, you should reconsider your method naming. Any experienced Rubyist who sees a `save!` method documented is going to want to know how it differs from `save`. The exclamation point doesn't mean anything in isolation; it only makes sense at the end of one of a pair of otherwise identical method names.

#### **DON'T EQUATE ! NOTATION WITH DESTRUCTIVE BEHAVIOR, OR VICE-VERSA** ####
Danger in the bang sense usually means object-changing or "destructive" behavior. It's therefore not uncommon to hear people assert that the `!` means destructive. From there, it's not much of a leap to start wondering why some destructive methods' names don't end with `!`.

This line of thinking is problematic from the start. The bang doesn't mean destructive; it means dangerous, possibly unexpected behavior. If you have a method called `upcase` and you want to write a destructive version of it, you're free to call it `destructive_upcase`; no rule says you have to add a `!` to the original name. It's just a convention, but it's an expressive one.

Destructive methods do not always end with `!`, nor would that make sense. Many nonbang methods have names that lead you to *expect* the receiver to change. These methods have no nondestructive counterparts. (What would it mean to have a nondestructive version of `String#clear`, which removes all the characters from a string and leaves it equal to `""`? If you're not changing the string in place, why wouldn't you just write `""` in the first place?) If a method name without a bang already suggests in-place modification or any other kind of "dangerous behavior", then it's not a dangerous method.

You'll almost certainly find that the conventional usage of the `!` notation is the most elegant and logical usage. It's best not to slap bangs on names unless you're playing along with those conventions.

Leaving danger behind us, we'll look next at the facilities Ruby provides for converting one object to another.

## Built-in and custom to_* (conversion) methods ##
Ruby offers a number of built-in methods whose names consist of `to_` plus an indicator of a class *to* which the method converts an object: `to_s` (to string), `to_sym` (to symbol), `to_a` (to array), `to_i` (to integer), and `to_f` (to float). Not all objects respond to all of these methods, But many objects respond to a lot of them, and the principle is consistent enough to warrant looking at them collectively.

### *String conversions: to_s* ###
The most commonly used `to_` method is probably `to_s`. Every Ruby object-except instances of `BasicObject`-responds to `to_s`, and thus has a way of displaying itself as a string. What `to_s` does, as the following irb excerpts show, ranges from nothing more than return its own receiver, when the object is already a string

```irb
>> "I am already a string!".to_s
=> "I am already a string!"
```
to returning a string containing a codelike representation of an object

```irb
>> ["one", "two", "three", 4, 5, 6].to_s
=> "[\"one\", \"two\", \"three\", 4, 5, 6]"
```
(where the blackslash-escaped quotation marks mean there's a literal quotation mark inside the string) to returning an informative, if cryptic, descriptive string about an object:

```irb
>> Object.new.to_s
=> "#<Object:0x000001030389b0>"
```
The salient point about 'to_s' is that it's used by certain methods and in certain syntactic contexts to provide a canonical string representation of an object. The `puts` method for example, calls `to_s` on its arguments. If you write your own `to_s` for a class or override it on an object, your `to_s` will surface when you give your object to `puts`. You can see this clearly, if a bit nonsensically, using a generic object:

```irb
2.3.1 :001 > obj = Object.new
 => #<Object:0x0000000187e118>                   <---#1.
2.3.1 :002 > puts obj
#<Object:0x0000000187e118>                     <---#2.
 => nil
2.3.1 :003 > def obj.to_s                   <---#3.
2.3.1 :004?>   "I'm an object!"
2.3.1 :005?>   end
 => :to_s                                 <---#4.
2.3.1 :006 > puts obj                   <---#5.
I'm an object!
 => nil
```
The object's default string representation is the usual class and memory-location screen dump (#1). When you call `puts` on the object, that's what you see (#2). But if you define a custom `to_s` method on the object (#3), subsequent calls to `puts` reflect the new definition (#5). (Note that the method definition itself evaluates to a symbol `:to_s`, representing the name of the method (#4).)

You also get the output of `to_s` when you use an object in string interpolation:

```irb
>> "My object says: #{obj}"
=> "My object says: I'm an object!"
```

Don't forget, too, that you can call `to_s` explicitly. You don't have to wait for Ruby to go looking for it. But a large percentage of calls `to_s` are automatic, behind-the-scenes calls on behalf of `puts` or the interpolation mechanism.

While we're looking a string representations of objects, let's examine a few related methods. We're drifting a bit from the `to_*` category, perhaps, but these are all methods that generate strings from objects, and a consideration of them is therefore timely.

**NOTE**
When it comes to generating string representations of their instances, arrays do things a little differently from the norm. If you call `puts` on an array, you get a cyclical representation based on calling `to_s` on each of the elements in the array and outputting one per line. That's a special behavior; it doesn't correspond to what you get when you call `to_s` on an array-namely-a string representation of the array in square brackets.

#### **BORN TO BE OVERRIDDEN: INSPECT** ###
Every Ruby object-once again, with the exception of instances of `BasicObject`-has an `inspect` method. By default-unless a given class overrides `inspect`-the `inspect` string is a mini-screen dump of the objects's memory location:

```irb 
>> Object.new.inspect 
=> "#<Object:0x007fe24a292b68>"
```
Actually, irb uses `inspect` on every value it prints out, so you can see the `inspect` strings of various objects without even explicitly calling `inspect`" 

```irb 
>> Object.new 
=> #<Object:0x007f91c2a8d1e8>
>> "abc"
=> "abc"
>> [1,2,3]
=> [1, 2, 3]
>> /a regular expression/
=> /a regular expression/
```
If you want a useful `inspect` string for your classes, you need to define `inspect` explicitly: 
```ruby 
class Person 
  def initialize(name)
    @name = name 
  end
  def inspect 
    @name
  end
end

david = Person.new("David")
puts david.inspect              # Output: David
```
(Note that overriding `to_s` and overriding `inspect` are two different things. Prior to Ruby 2, `inspect` piggybacked on `to_s`, so you could override both by overriding one. That's no longer the case.)

Another, less frequently used, method generates and displays a string representation of an object: `display`.

#### **USING DISPLAY** #### 
You won't see `display` much. It occurs only once, at last count, in all the Ruby program files in the entire standard library. (`inspect` occurs 160 times.) It's a specialized output method. 

`display` takes an argument: a writable output stream, in the form of a Ruby I/O object. By default, it uses `STDOUT`, the standard output stream: 

```irb 
>> "Hello".display
Hello=> nil
```
Note that `display` unlike `puts` but like `print`, doesn't automatically insert a newline character. That's why `=> nil` is run together on one line with the output. 

You can redirect the output of `display` by providing, for example, an open file handle as an argument: 

```irb 
>> fh = File.open("/tmp/display.out", "w")
=> #<File:/tmp/display.out>
>> "Hello".display(fh)                            #<----1.
=> nil
>> fh.close
=> nil
>> puts(File.read("/tmp/display.out"))                 #<----2.
Hello
```
The string `"Hello"` is "displayed" directly to the file (#1.), as we confirm by reading the contents of the file and printing them out (#2.). 

Let's leave string territory at this point and look at how conversion techniques play out in the case of the `Array` class. 
