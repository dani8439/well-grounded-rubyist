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

            |----> `Float`
            |
`Numerical` |
            |                | ----> `Fixnum`
            |----> `Integer` |  
                             | ----> `Bignum`
                             
### *Numerical classes* ###
