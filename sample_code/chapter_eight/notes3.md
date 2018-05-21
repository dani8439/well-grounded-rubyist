### *Symbols in practice* ###
Symbols have a number of uses, but most appearances fall into one of two categories: method arguments and hash keys.

#### SYMBOLS AS METHOD ARGUMENTS ####
A number of core Ruby methods take symbols as arguments. Many such methods can also take strings. You're already seen a couple of examples from the `attr_*` method family:

```ruby
attr_accessor :name
attr_reader :age
```
The `send` method, which sends a message to an object without the dot, can take a symbol:

`"abc".send(:upcase)`

You don't normally need `send` if you know the whole method name in advance. But the lesson here is that `send` can take a symbol, which remains true even if the symbol is stored in a variable, rather than written out, and/or determined dynamically at runtime.

At the same time, most methods that take symbols can also take strings. You can replace `:upcase` with "upcase" in the previous `send` example, and it will work. The difference is that by supplying `:upcase`, you're saving Ruby the trouble of translating the string `upcase` to a symbol internally on its way to locating the method.

It's possible to overboard. You'll occasionally see code like this:

`some_object.send(method_name.to_sym)`

An extra step is taken (the `to_sym` conversion) on the way to passing na argument to `send`. There's no point in doing this unless the method being called can only handle symbols. If it can handle strings and you've got a string, pass the string. Let the method handle the conversion if one is needed.

**Consider allowing symbols or strings as method arguments**
When you're writing a method that will take an argument that could conceivably be a string or a symbol, it's often nice to allow both, it's not necessary in cases where you're dealing with user-generated, arbitrary strings, or where text read in from a file is involved; those won't be in symbol for anyway. But if you have a method that expects, say, a method name, or perhaps a value from a finite table of tags or labels, it's polite to allow either strings or symbols. That means avoiding doing anything to the object that requires it to be one or the other and that will cause an error if it's the wrong one. You can normalize the argument with a call to `to_sym` (or `to_s`, if you want to normalize to strings) so that whatever gets passed in fits into the operations that you need to perform.

#### SYMBOLS AS HASH KEYS ####
A *hash* is a keyed data structure: you insert values into it by assigning the value to a key, and you retrieve a value by providing a reference to a key. Ruby puts no constraints on hash keys. You can use an array, a class, another hash, a string, or any other object you like as a hash key. But in most cases you're likely to use strings or symbols.

Here's the creation of a hash with symbols as keys, followed by the retrieval of one of the values:

```irb
>> d_hash = { :name => "David", :age => 55 }
=> {:name=>"David", :age=>55}
>> d_hash[:age]
=> 55
```
And here's a similar hash with string keys:

```irb
>> d_hash = { "name" => "David", "age" => 55 }
=> {"name"=>"David", "age"=>55}
>> d_hash["name"]
=> "David"
```

There's nothing terrible about using strings as hash keys, especially if you already have a collection of strings on hand and need to incorporate them into a hash. But symbols have a few advantages in the hash-key department.

First, Ruby can process symbols faster, so if you're doing a lot of hash lookups, you'll save a little time. You won't notice a difference if you're only processing small amounts of data, but if you need to tweak for efficiency, symbol hash keys are probably a good idea.

Second, symbols look good as hash keys. Looking good is, of course, not a technical characteristic, and opinion about what looks good varies widely. But symbols do have a kind of frozen, label-like look that lends itself well to cases where your hash keys are meant to be static identifiers (like `:name` and `:age`), whereas strings have a malleability that's a good fit for the representation of arbitrary values (like someone's name). Perhaps this is a case of projecting the technical basis of the two objects-strings being mutable, symbols not-onto the aesthetic plane. Be that as it may, Ruby programmers tend to use symbols more than strings as hash keys.

The third reason to use symbols rather than strings as hash keys, when possible, is that Ruby allows a special form of symbol representation int he hash-key position, with the colon after the symbol instead of before it and the hash separator arrow removed. In other words,

`hash = { :name => "David", :age => 55 }`

can also be written as

`hash = { name: "David", age: 55 }`

As it so often does, Ruby goes out of its way to let you write things in an uncluttered simple way. Of course, if you prefer the version with the standard symbol notation and the hash arrows, you can still use that form.

So far, and by design, we've looked at symbols mainly by the light of how they differ from strings. But you'll have noticed that strings enter the discussion regularly, no matter how much we try to separate the two. It's worth having centered the spotlight on symbols, but now let's widen it and look at some specific points of comparison between symbols and strings.

### *Strings and symbols in comparison* ###
Symbols have become increasingly stringlike in successive versions of Ruby. That's not to say that they've shed their salient features; they're still immutable and unique. But they present a considerably more stringlike interface than they used to.

By way of a rough demonstration of the changes, here are two list of methods. The first comes from Ruby 1.8.6:

```irb
>> Symbol.instance_methods(false).sort
=> ["===", "id2name", "inspect", "to_i", "to_int", "to_s", "to_sym"]
```

The second is from Ruby 2:

```irb
>> Symbol.instance_methods(false).sort
=> [:<=>, :==, :===, :=~, :[], :capitalize, :casecmp, :downcase, :empty?, :encoding, :id2name, :inspect, :intern, :length, :match, :next, :size, :slice, :succ, :swapcase, :to_proc, :to_s, :to_sym, :upcase]
```

Somewhere along hte line, symbols have learned to do lots of new things, mostly from the string domain. But note that there are no bang versions of the various case-changing and incrementation methods. For strings, `upcase!` means *upcase yourself in place*. Symbols, on the other hand, are immutable; the symbol `:a` can show you the symbol `:A`, but it can't be the symbol `:A`.

In general, the semantics of the stringlike symbol methods are the same as the string equivalents, including incrementation:

```irb
>> sym = :david
=> :david
>> sym.upcase
=> :DAVID
>> sym.succ
=> :davie
>> sym[2]
=> "v"                   #<-----1
>> sym.casecmp(:david)
=> 0
```
Note that indexing into a symbol returns a substring(#1), not a symbol. From the programmer's perspective, symbols acknowledge the fact that they're representations of text by giving you a number of ways to manipulate their content. But it isn't really content, `:david` doesn't contain "david" any more than `100` contains "100." It's a matter of the interface and of a characteristically Ruby-like confluence of object theory and programming practicality.

Underneath, symbols are more like integers than strings. (The symbol table is basically an integer-based hash.) They share with integers not only immutability and uniqueness, but also immediacy: a variable to  which a symbol is bound provides the actual symbol value, not a reference to it. If you're puzzled over how exactly symbols work, or over why both strings and symbols exist when they seem to be duplicating each other's efforts in representing text, think of symbols as integer-like entities dressed up in characters. It sounds odd, but explains a lot.

## *Numerical objects* ##
In Ruby, numbers are objects. You can send messages to them, just as you can any object:

```ruby
n = 99.6
m = n.round
puts m                #<--------1
x = 12
if x.zero?
  puts "x is zero"
else
  puts "x is not zero"          #<--------2
end
puts "The ASCII character equivalent of 97 is #{97.chr}"     #<--------3
```
As you'll see if you run this code, floating-point numbers know how to round themselves (#1) (up or down). Numbers in general know (#2) whether they're zero. And integers can convert themselves to the character that corresponds to their ASCII value (#3).

Numbers are objects; therefore, they have classes- a whole family tree of them

                           Numeric
                        /           \
                  Float               Integer
                                    /         \
                                Fixnum        Bignum

### *Numerical classes* ###
Several classes make up the numerical landscape. Figure above shows a slightly simplified view (mixed-in modules aren't shown) of those classes, illustrating the inheritance relations among them.

The top class in the hierarchy of numerical classes is `Numeric`; all the others descend from it. The first branch in the tree is between floating-point and integral numbers: the `Float` and `Integer` classes. Integers are broken into two-classes: `Fixnum` and `Bignum`. `Bignum`s, as you may surmise, are large integers. When you use or calculate an integer that's big enough to be a `Bignum` rather than a `Fixnum`, Ruby handles the conversion automatically for you; you don't have to worry about it.

### *Performing arithmetic operations* ###
For the most part, numbers in Ruby behave as the rules of arithmetic and the usual conventions of arithmetic notation lead you to expect. The examples in table above should be reassuring in their boringness.

Note that when you divide integers, the result is always an integer. If you want floating-point division, you have to feed Ruby floating-point numbers (even if all you're doing is adding .0 to the end of an integer)

##### Common arithmetic expressions and their evaluative results #####

|     Expression      |       Result        |               Comments                                |
|---------------------|---------------------|-------------------------------------------------------|
| `1 + 1`             | `2`                 | Addition                                              |
| `10/5 `             | `2`                 | Integer division                                      |
| `16/5 `             | `3`                 | Integer division (no automatic floating-point conversion)|
| `10/3.3`            | `3.3333333333`      | Floating-point division                               |
| `1.2 + 2.3`         | `4.6`               | Floating-point addition                               |
| `-12 - -7`          | `-5`                | Subtraction                                           |
| `10 % 3`            | `1`                 | Modulo (remainder)                                    |


Ruby also lets you manipulate numbers in nondecimal bases. Hexadecimal integers are indicated by a leading `0x`. Here are some irb evaluations of hexadecimal integer expressions:

```irb
>> 0x12
=> 18
>> 0x12 + 12          #<-----1
=> 30
```
The second 12 in the last expression (#1) is a decimal 12; the `0x` prefix applies only to the numbers it appears on.

Integers beginning with 0 are interpreted as *octal* (base 8):

```irb
>> 012
=> 10
>> 012 + 12
=> 22
>> 012 + 0x12
=> 28
```

You can also use the `to_i` method of strings to convert numbers in any base to decimal. To perform such a conversion, you need to supply the base you want to convert *from* as an argument to `to_i`. The string is then interpreted as an integer in that base, and the whole expression returns the decimal equivalent. You can try any base from 2 to 36 inclusive. Here are some examples:

```irb
>> "10".to_i(17)
=> 17
>> "12345".to_i(13)
=> 33519
>> "ruby".to_i(35)
=> 1194794
```
Keep in mind that most of the arithmetic operators you see in Ruby are *methods*. They don't look that way because of the operator-like syntactic sugar that Ruby gives them. But they are methods, and they can be called as methods:

```irb
>> 1.+(1)
=> 2
>> 12./(3)
=> 4
>> -12.-(-7)
=> -5
```
In practice, no one writes arithmetic operations that way; you'll always see the syntactic sugar equivalents (`1 + 1` and so forth). But seeing examples of the method-call form is a good reminder of the fact that they're methods-and also of the fact that if you define, say, a method called `+` in a class of your own, you can use the operator's syntactic sugar. (And if you see arithmetic operators behaving weirdly, it may be that someone has redefined their underlying methods.)

We'll turn now to the next and last category in scalar objects we'll discuss in this chapter: time and datetime objects.

## *Times and dates* ##
Ruby gives you lots of ways to manipulate times and dates. In fact, the extent and variety of classes that represent times and/or dates, and the class and instance methods available through those classes, can be bewildering. SO can the different ways in which instances of the various classes represent themselves. Want to know what the day we call April 24, 1705, would have been called in England prior to the calendar reform of 1752? Load the `date` package and then ask;

```irb
>> require 'date'
=> true
>> Date.parse("April 24, 1705").england.strftime("%B %d %Y")
=> "April 13 1705"
```
On the less exotic side, you can perform a number of useful and convenient manipulations on time and date objects.

Times and dates are manipulated through three classes: `Time`, `Date`, and `DateTime`. (For convenience, the instances of all these classes can be referred to collectively as *date/time objects.* ) To reap the benefits, you have to pull one or both of the `date` and `Time` libraries into your program or irb session:

`require 'date'`

`require 'time'`

Here, the first line provides the `Date` and `DateTime` classes, and the second line enhances the `Time` class. (Actually, even if you don't `require 'date'` you'll be able to see the `Date` class. But it can't do anything yet.) At some point in the future, all available date- and time-related functionality may be unified into one library and made available to programs by default. But for the moment, you have to do the `require` operations if you want the full functionality.

In what follows, we'll examine a large handful of date/time operations-not all of them, but most of the common ones and enough to give you a grounding for further development. Specifically, we'll look at how to instantiate date/time objects, how to query them, and how to convert them from one form or format to another.

### *Instantiating date/time objects* ###
How you instantiate a date/time object depends on exactly what object is involved.
We'll look at the `Date`, `Time`, and `DateTime` classes, in that order.

#### CREATING DATE OBJECTS ####
You can get today's date with the `Date.today` constructor:

```irb
>> Date.today
=> #<Date: 2018-05-21 ((2458260j,0s,0n),+0s,2299161j)>
```
You can get a simpler string by running `to_s` on the date, or by `puts`ing it:

```irb
>> puts Date.today
2018-05-21
=> nil
```
You can also create date objects with `Date.new` (also available as `Date.civil`). Send along a year, month, and day:

```irb
>> puts Date.new(1948,3,7)
1948-03-07
=> nil
```
If not provided, the month and day (or just dat) default to 1. If you provide no arguments, the year defaults to -4712-probably not the most useful value.

Finally, you can create a new date with the `parse` constructor, which expects a string representing a date:

```irb
>> puts Date.parse("2003/6/9")
2003-06-09     #<-------Assumes year/month/day order
=> nil     
```
By default, Ruby expands the century for you if you provide a one- or two-digit number. If the number is 69 or greater, then the offset added is 1900; if it's between 0 and 68, the offset is 200. (This distinction has to do with the beginning of the Unix "epoch" at the start of 1970.)

```irb
>> puts Date.parse("03/6/9")
2003-06-09
=> nil
>> puts Date.parse("33/6/9")
2033-06-09
=> nil
>> puts Date.parse("77/6/9")
1977-06-09
=> nil
```

`Date.parse` makes an effort to make sense of whatever you throw at it, and it's pretty good at its job:

```irb
>> puts Date.parse("November 2 2013")
2013-11-02
=> nil
>> puts Date.parse("Nov 2 2013")
2013-11-02
=> nil
>> puts Date.parse("2 Nov 2013")
2013-11-02
=> nil
>> puts Date.parse("2013/11/2")
2013-11-02
```
You can create Julian and commercial (Monday-based rather than Sunday-based day-of-week counting) `Date` objects with the methods `jd` and `commercial`, respectively. You can also scan a string against a format specification, generating a `Date` object, with `strptime`. These constructor techniques are more specialized than the others, and we won't go into them in detail here; but if your needs are similarly specialized, the `Date` class can address them.

The `Time` class, like the `Date` class has multiple constructors.

#### CREATING TIME OBJECTS ####
You can create a time object using any of several constructors: `new` (a.k.a. `now`), `at`, `local` (a.k.a. `mktime`), and `parse`. This plethora of constructors, excessive though it may seem at first, does provide a variety of functionalities, all of them useful. Here are some examples, irb-style:

```irb
>> Time.new
=> 2018-05-21 15:53:58 +0000                #<-----1.
>> Time.at(100000000)
=> 1973-03-03 09:46:40 +0000                   #<-----2.
>> Time.mktime(2007,10,3,14,3,6)
=> 2007-10-03 14:03:06 +0000                      #<-----3.
>> require 'time'
=> true                                               #<-----4.
>> Time.parse("March 22, 1985, 10:35 PM")
=> 1985-03-22 22:35:00 +0000                              #<-----5.
```
`Time.new` (or `Time.now`) creates a time object representing the current time (#1). `Time.at(seconds)` gives you a time object for the number of seconds since the epoch (midnight on January 1, 1970, GMT) represented by the `seconds` argument (#2). `Time.mktime` or (`Time.local`) expects year; month, day, hour, minute and second arguments. You don't have to provide all of them; as you drop arguments off from the right `Time.mktime` fills in with reasonable defaults (1 for month and day; 0 for hour, minute, and second) (#3).

To use `Time.parse` you have to load the `time` library (#4). Once you do, `Time.parse` makes as much sense as it can of the arguments you give it, much like `Date.parse` (#5).

#### CREATING DATE/TIME OBJECTS ####
`DateTime` is a subclass of `Date`, but its constructors are a little different thanks to some overrides. The most common constructors are `new` (also available as `civil`), `now`, and `parse`.

```irb
>> puts DateTime.new(2009, 1, 2, 3, 4, 5)
2009-01-02T03:04:05+00:00
=> nil
>> puts DateTime.now
2018-05-21T16:18:06+00:00
=> nil
>> puts DateTime.parse("October 23, 1973, 10:34 AM:)
```
`DateTime` also features the specialized `jd` (Julian date), `commercial`, and `strptime` constructors mentioned earlier in connection with the `Date` class.

Let's turn now to the various ways in which you can query date/time objects.

### *Date/time query methods* ###
In general, the time and date objects have the query methods you'd expect them to have. Time objects can be queried as to their year, month, day, hour, minute, and second, as can date/time objects. Date objects can be queried as to their year, month, and day:

```irb
>> dt = DateTime.now
=> #<DateTime: 2018-05-21T16:21:05+00:00 ((2458260j,58865s,468104470n),+0s,2299161j)>
>> dt.year
=> 2018
>> dt.hour
=> 16
>> dt.minute
=> 21
>> dt.second
=> 5
>> t = Time.now
=> 2018-05-21 16:21:16 +0000
>> t.month
=> 5
>> t.sec
=> 16
>> d = Date.today
=> #<Date: 2018-05-21 ((2458260j,0s,0n),+0s,2299161j)>
>> d.day
=> 21
```
Note that date/time objects have a `second` method, as well as `sec`. Time objects have only `sec`.

Some convenient day-of-week methods work equally for all three classes. Through them, you can determine whether the given date/time is or isn't a particular day of the week:

```irb
>> d.monday?
=> true
>> dt.friday?
=> false
```
Other available queries  include Boolean ones for leap year (`leap?`) and daylight saving time (`dst?`, for time objects only).

As you've seen, the string representations of date/time objects differ considerably, depending on exactly what you've asked for and which of the three classes you're dealing with. In practice, the default string representations aren't used much. Instead, the objects are typically formatted using methods designed for that purpose.

### *Date/time formatting methods* ###
All date/time objects have the `strftime` method, which allows you to format their fields in a flexible way using format strings, in the style of the Unix `strftime(3)` system library:

```irb
 >> t = Time.now
 => 2018-05-21 16:27:17 +0000
 >> t.strftime("%m-%d-%y")
 => "05-21-18"

```
