# *The default object (self), scope, and visibility* #
  In describing and discussing computer programs, we often use spatial and, sometimes, human metaphors. We
talk about being "in" a class definition or returning "from" a method call. We address objects in the second person, as in `obj.respond_to?("x")` (this is, "Hey `obj`, to you respond to `x`?"). As a program runs, the question of which objects are being addressed, and where in the imaginary space of the program they stand, constantly shifts.

  The shifts aren't just metaphorical. The meanings of identifiers shift too. A few elements mean the same
thing everywhere. Integers, for example, mean what they mean wherever you see them. The same is true for keywords: you can't just use keywords like `def` and `class` as variable names, so when you see them, you can easily glean what they're doing. But most elements depend on context for their meaning. Most words and tokens-most identifiers-can mean different things at different places and times.

  Two topics focused on in this chapter: *self* and *scope*. *Self* is the "current" or "default" object,
a role typically assigned to many objects in sequence (though only one at a time) as a program runs. The self object in Ruby is like the first person or *I* of the program. As in a book with multiple first-person narrators, the *I* role can get passed around. There's always one self, but what object it is will vary. The rules of scope govern the visibility of variables (and other elements, but largely variables). It's important to know what scope you're in, so that you can tell what variables refer to and not confuse them with variables from different scopes that have the same name, nor with similarly named methods.

  Between them, self and scope are the master keys to orienting yourself in a Ruby program. If you know
what scope you're in and know what object is self, you'll be able to tell what's going on, and you'll be able to analyze errors quickly.

  The third main topic is *method access*. Ruby provides mechanisms for making distinctions among access
levels of methods. Basically, this means rules limiting the calling of methods depending on what self is. Method access is therefore a meta-topic, grounded in the study of self and scope.

  *Top-level methods* will pull several of these threads together, they are written outside of any class
or module definition.

## *Understanding self, the current/default object* ##
One of the cornerstones of Ruby programming-the backbone, in some respects-is the default object or current object, accessible to you in your program through the keyword `self`. At every point when your program is running, there's one and only one self. Being self has certain privileges, as you'll see. In this section, will look at how Ruby determines which object is self at a given point and what privileges are granted to the object that is self.

### *Who gets to be self, and where* ###
There's always one (and only one) current object or self. You can tell which object it is by following small set of rules below:

#### How the current object(self) is determined ####
|      Context        |         Example        |        Which object is self?                       |
|---------------------|------------------------|----------------------------------------------------|  
|Top level of program | Any code outside of other blocks|`main`(built-in top-level default object)  |
|Class definition     | `class C`              | The class object `C`                               |
|                     |      `self`            |                                                    |
|Module Definition    | `module M`             | The module object `M`                              |
|                     | `self`                 |                                                    |
|Method Definitions   | 1 Top level (outside any definition block):| Whatever object is self when the |
|                     |   `def method_name`    | method is called; top-level methods are available  |
|                     |   `self `              | as private methods to all objects                  |
|                     | 2 Instance-method definition in a class: | An instance of `C` responding to |
|                     |`class C`               |    `method_name`                                   |
|                     |`def method_name`       |                                                    |
|                     | `self`                 |                                                    |
|                     | 3 Instance-method definition | • Individual object extended by `M`          |
|                     | in a module:                 | • Instance of class that mixes in `M`        |
|                     | `module M`                   |                                              |
|                     | `def method_name`            |                                              |
|                     | `self`                       |                                              |
|                     | 4 Singleton method on a specific object: |        `Obj`                     |
|                     | `def obj.method_name`        |                                              |
|                     | `self`                       |                                              |

To know which object is self, you need to know what context you're in. In practice, there aren't many contexts to worry about. There's the top level (before you've entered any other context, such as class definition). There are class-definition blocks, module-definition blocks, and method-definition blacks. Aside from a few subtleties in the way these contexts interact, thats about it. As shown in table above, self is determined by which of these contexts you're in (class and module definitions are similar and closely related).

The most basic program context, and in some respects a unique one, is the top level: the context of the program before any class or module definition has been opened, or after they've all been closed.

### Figure 5.1 The determination of self in different contexts ###

```ruby
puts "Top Level"
puts "self is #{self}"  #<-- Self at top level is the "default default object," main.

class C
  puts "Class definition block:"
  puts "self is #{self}" #<-- Self inside a class definition is the class object itself.

  def self.x
  # Self inside any method is the object to which the message (the method call) was sent.
    puts "Class method C.x:"
    puts "self is #{self}" #<-- For a class method that means the class object.
  end

  def m
    puts "Instance method C#m:"
    puts "self is #{self}" #<-- For an instance method, that means an instance of the class whose instance method it is.
  end
end
```

## *The top-level self object* ##
The term *top-level* refers to program code written outside of any class- or module - definition block. If you open a brand-new file and type

`x = 1`

you've created a top level local variable `x`. If you type

```ruby
def m
end
```

you've created a top-level method. The way self shifts in class, module, and method definitions is uniform: the keyword (`class, module,` or `def`) marks a switch to a new self. But what's self when you haven't yet entered any definition block?

The answer is that Ruby provides you with a start-up self at the top level. If you ask it to identify itself with
`ruby -e 'puts self'`

it will tell you that it's called `main`.

`main` is a special term that the default self object uses to refer to itself. You can't refer to it as `main`; Ruby will interpret your use of `main` as a regular variable or method name. If you want to grab `main` for any reason, you need to assign it to a variable at the top level:

`m = self`

It's not likely that you'd need to do this, but that's how it's done. More commonly, you'll feel the need for a fairly fine-grained sense of what self is in your class, module, and method definitions where most of your programming will take place.

## *Self inside class, module, and method definitions* ##
It pays to keep a close eye on self as you write classes, modules, and methods. There aren't that many rules to learn, and they're applied consistently. But they're worth learning well up front, so you're clear on why the various techniques you use that depend on the value of self play out the way they do.

It's all about self switching from one object to another, which it does when you enter a class or module definition, an instance-method definition, or a singleton-method (including class-method) definition.

### SELF IN A CLASS AND MODULE DEFINITIONS ###
In a class or module definition, `self` is the class or module object. This innocent sounding rule is important. If you master it, you'll save yourself from several of the most common mistakes that people make when they're learning Ruby.

You can see what self is at various levels of class and/or module definition by using `puts` explicitly, as shown below:

```ruby
class C
  puts "Just started class C:"
  puts self    #<-- Output: C
  module M
    puts "Nested module C::M"
    puts self   #<-- Output: C::M
  end
  puts "Back in the outer level of C:"
  puts self    #<-- Output: C
end
```

As soon as you cross a class or module keyword boundary, the class or module whose definition block you've entered-the `Class` or `Module` object-becomes self. Above shoes two cases: entering `C`, and then entering `C::M`. When you leave `C::M` but are still in `C`, self is once again `C`.

Of course, class and module definition blocks do more than just begin and end. They also contain method definitions, which, for both instance methods and class methods, have rules determining self.

### SELF IN INSTANCE-METHOD DEFINITIONS ###
The notion of self inside an instance method definition is subtle, for the following reason: when the interpreter encounters a `def/end` block, it defines the method immediately. But the code inside the method definition isn't executed until later, when an object capable of triggering its execution receives the appropriate message.

When you're looking at a method definition on paper or on the screen, you can only know in principle that, when the method is called, self will be the object that called it (the receiver of the message). At the time the method gets defined, the most you can say is that self inside this method will be some future object that calls the method.

You can rig a method to show you self as it runs. See class_c.rb

The weird-looking item in the output (#<C:0x000000026e8f78>) is Ruby's way of saying "an instance of `C`". (The hexadecimal number after the colon is a memory-location reference. When you run the code on your system, you'll probably get a different number:) As you can see, the receiver of the "x" message, namely `c`, takes on the role of self during execution of `x`.

### SELF IN SINGLETON-METHOD AND CLASS-METHOD DEFINITIONS ###
As you might expect, when a singleton method is executed, self is the object that owns the method, as an object will readily tell you.

See Object.rb

It makes sense that if a method is written to be called by only one object, that object gets to be self. Moreover, this is a good time to remember class methods- which are, essentially, singleton methods attached to class objects. The following example reports on self from inside a class method of `C`.

see class_c.rb

Sure enough, self inside a singleton method (a class method, in this case) is the object whose singleton method it is.

### **Using self instead of hard-coded class names** ###
By way of a little programming tip, here's a variation on the last example:

```ruby
class C
  def self.x
    puts "Class method of class C"
    puts "self: #{self}"
  end
end
```

Note the use of `self.x` rather than `C.x`. This way of writing a class method takes advantage of the fact that in the class definition, self is `C`. So `def self.x` is the same as `def C.x`.

The `self.x` version offers a slight advantage: if you ever decide to rename the class, `self.x` will adjust automatically to the new name. If you hard-code `C.x`, you'll have to change `C` to your class's new name. But you do have to be careful. Remember that self inside a method is always the object on which the method was called. You can get into a situation where it feels like self should be one class object, but is actually another:

```ruby
class D < C
end
D.x
```

`D` gets to call `x`, because subclasses get to call the class methods of their superclasses. As you'll see if you run the code, the method `C.x` reports self-correctly-as being `D`, because it's `D` on which the method is called.

---

Being self at a given point in the program comes with some privileges. The chief privilege enjoyed by self is that of serving as the default receiver of messages, as we'll see next.

## *Self as the default receiver of messages* ##

Calling methods (that is sending messages to objects) usually involves the dot notation:

```ruby
obj.talk
ticket.venue
"abc".capitalize
```
That's the normal, full form of the method-calling syntax in Ruby. But a special rule governs method calls: if the receiver of the message is self, you can omit the receiver and the dot. Ruby will use `self` as the default receiver, meaning the message you send will be sent to self, as the following equivalencies show:

```ruby
talk   # <-- same as self.talk
venue  # <-- same as self.venue
capitalize # <-- same as self.capitalize
```

  ### **WARNING** ###
  You can give a method and a local variable the same name, but it's rarely if ever a good idea. If both a method and a variable of a given name exist, and you use the bare identifier (like `talk`), the variable takes precedence. To force Ruby to see the identifier as a method name, you'd have to use `self.talk` or call the method with an empty argument list: `talk()`. Because variables don't take arguments, the parentheses establish that you mean the method rather than the variable. Again, it's best to avoid these name clashes if you can.

---
Let's see this concept in action by inducing a situation where we know what self is and then testing the dotless form of method calling. In top level of a class-definition block, self is the class object. And we know how to add methods directly to class objects. So we have the ingredients to do a default receiver demo (see class_c.rb def C.no_dot, and notes below explaining what is happening in the method call, when we are referencing self, and when not).

The most common use of the dotless method call occurs when you're calling one instance method from another. Here's an example (see notes)

Upon calling `c.y`, the method `y` is executed, with self set to `c` (which is an instance of `C`). Inside `y` the bareword reference to `x` is interpreted as a message to be sent to self. That, in turn, means the method `x` is executed.

There's one situation where you can't omit the object-plus-dot part of a method call: when the method name ends with an equal sign-a *setter* method, in other words. You have to do `self.venue = "Town Hall"` rather than `venue = "Town Hall"` if you want to call the method `venue=` on self. The reason is that Ruby always interprets the sequence *identifier = value* as an assignment to a local variable. To call the method `venue=` on the current object, you need to include the explicit self. Otherwise, you end up with a variable called `venue` and no call to the setter method.

The default to self as receiver for dotless method invocations allows you to streamline your code nicely in cases where one method makes use of another. A common case is composing a whole name from its components: first, optional middle, an last. The following listing shows a technique for doing this, using attributes for the three name values and conditional logic to include the middle name, plus a trailing space, if and only if there's a middle name. (see person.rb)

The definition of `whole_name` depends on the bareword method calls to `first_name`, `middle_name`, and `last_name` being sent to self-self being the `Person` instance (`david` in the example). The variable `n` serves as a string accumulator, with the components of the name added to it one by one. The return value of the entire method is `n`, because the expression `n << last_name` (#1) has the effect of appending `last_name` to `n` and returning the result of that operation.

In addition to serving automatically as the receiver for bareword messages, self also enjoys the privilege of being the owner of instance variables.

### *Resolving instance variables through self* ###
A simple rule governs instance variables and their resolution: every instance variable you'll ever see in a Ruby program belongs to whatever object is the current object (self) at that point in the program.

Here is a classic case where this knowledge comes in handy:

```ruby
class C
  def show_var
    @v = "I am an instance variable initialized to a string."  #1
    puts @v
  end
  @v = "Instance variables can appear anywhere...."   #2
end

C.new.show_var
```

The code prints the following:

```ruby
I am an instance variable initialized to a string.
```
The trap is that you may think it will print `Instance variables can appear anywhere....` The code prints what it does because the `@v` in the method definition(#1) and the `@v` outside it (#2) are completely unrelated to each other. They're both instance variables, and both are named `@v`, but they aren't the same variable. They belong to difference objects.

Whose are they?

The first `@v` (#1) lies inside the definition block of an instance method of `C`. That fact has implications not for a single object, but for instances of `C` in general: each instance of `C` that calls this method will have its own instance variable `@v`.

The second `@v` (#2) belongs to the class object `C`. This is one of the many occasions where it pays to remember that classes are objects. Any object may have its own instance variables-its own private stash of information and object state. Class objects enjoy this privilege as much as any other object.

Again, the logic required to figure out what object owns a given instance variable is simple and consistent: every instance variable belongs to whatever object is playing the role of self at the moment the code containing the instance variable is executed.

Let's do a quick rewrite of the example, this time making it a little chattier about what's going on:

```ruby
class C
  puts "Just inside class definition block. Here's self:"
  p self
  @v = "I am an instance variable at the top level of a class body."
  puts "And here's the instance variable @v, belonging to #{self}:"
  p @v
  def show_var
    puts "Inside an instance method definition block. Here's self:"
    p self
    puts "And here's the instance variable @v, belonging to #{self}:"
    p @v
  end
end
c = C.new
c.show_var
```

The output from this version is as follows:

```ruby
Just inside class definition block. Here's self:
C
And here's the instance variable @v, belonging to C:
"I am an instance variable at the top level of a class body."
Inside an instance method definition block. Here's self:
#<C:0x000000021dbd50>
And here's the instance variable @v, belonging to #<C:0x000000021dbd50>:
nil
```

Sure enough, each of these two different objects (the class object `C` and the instance of `C`, `c`) has its own instance variable `@v`. The fact that the instance's `@v` is `nil` demonstrates that the assignment to the class's `@v` had nothing to do with the instance's `@v`.

Understanding self-both the basic fact that such a role is being played by some object at every point in a program and knowing how to tell which object is self-is one of the most vital aspects of understanding Ruby. Another equally vital aspect is understanding scope, to which we'll now turn.
