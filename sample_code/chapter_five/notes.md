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

### SELF IN INSTANCE-METHOD DEFINITIONS##
The notion of self inside an instance method definition is subtle, for the following reason: when the interpreter encounters a `def/end` block, it defines the method immediately. But the code inside the method definition isn't executed until later, when an object capable of triggering its execution receives the appropriate message.

When you're looking at a method definition on paper or on the screen, you can only know in principle that, when the method is called, self will be the object that called it (the receiver of the message). At the time the method gets defined, the most you can say is that self inside this method will be some future object that calls the method.

You can rig a method to show you self as it runs. See class_c.rb

The weird-looking item in the output (#<C:0x000000026e8f78>) is Ruby's way of saying "an instance of `C`". (The hexadecimal number after the colon is a memory-location reference. When you run the code on your system, you'll probably get a different number:) As you can see, the receiver of the "x" message, namely `c`, takes on the role of self during execution of `x`.

### SELF IN SINGLETON-METHOD AND CLASS-METHOD DEFINITIONS ###
As you might expect, when a singleton method is executed, self is the object that owns the method, as an object will readily tell you.

See Object.rb

It makes sense that if a method is written to be called by only one object, that object gets to be self. Moreover, this is a good time to remember class methods-
