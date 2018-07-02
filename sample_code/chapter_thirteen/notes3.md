### *Per-object changes with extend* ###
`Object#extend` is a kind of homecoming in terms of topic flow. We've wandered to the outer reaches of modifying core classes-and `extend` brings us back to the central process at the heart of all such changes: changing the behavior of an individual object. It also brings us back to an earlier topic from this chapter: the mixing of a module into an object's singleton class. That's essentially what `extend` does. 

#### ADDING TO AN OBJECT'S FUNCTIONALITY WITH EXTEND ####
Have another look at the earlier section and inparticular the `Person` example where we mixed the `Secretive` module into the singleton classes of some `Person` object. As a reminder, the technique was this (where `ruby` is a `Person` instance):

```ruby
class << ruby 
  include Secretive
end
```
Here's how the `Person` example would look, using `extend` instead of explicitly opening up the singleton class of the `ruby` object. Let's also use `extend` for `david` (instead of the singleton method definition with `def`):

```ruby 
module Secretive
  def name
    "[not available]"
  end
end
class Person
  attr_accessor :name
end
david = Person.new
david.name = "David"
matz = Person.new
matz.name = "Matz"
ruby = Person.new
ruby.name = "Ruby"
david.extend(Secretive)     #<---1.
ruby.extend(Secretive)
puts "We've got one person named #{matz.name}, " + "one person named #{david.name}, " + "and one named #{ruby.name}."

# We've got one person named Matz, one person named [not available], and one named [not available].
```
Most of this program is the same as the first version, as is the output. The key difference is the use of `extend` (#1), which has the effect of adding the `Secretive` module to the lookup paths of the individual objects `david` and `ruby` by mixing into their respective singleton classes. That inclusion process happens when you extend a class object, too.

#### ADDING CLASS METHODS WITH EXTEND ####
If you write a singleton method on a class object, like so

```ruby 
class Car 
  def self.makes 
    %w{ Honda Ford Toyota Chevrolet Volvo}
  end
end
```
or like so

```ruby 
class Car 
  class << self 
    def makes 
      %w{ Honda Ford Toyota Chevrolet Volvo}
    end 
  end 
end
```

or write any of the other notational variants available, you're adding an instance method to the singleton class of the class object. It follows that you can achieve this, in addition to the other ways, by using `extend`: 

```ruby 
module Makers 
  def makes 
    %w{ Honda Ford Toyota Chevrolet Volvo }
  end 
end 
class Car
  extend Makers 
end
```
If it's more appropriate in a given situation, you can extend the class object after it already exists:

`Car.extend(Makes)`

Either way, the upshot is that the class object `Car` now has access to the `makes` method. 

As with non-class objects, extending a class object with a module means mixing the module into the class's singleton class. You can verify this with the `ancestors` method:

`p Car.singleton_class.ancestors`

The output from this snippet is

`[#<Class:Car>, Makers, #<Class:Object>, #<Class:BasicObject>, Class, Module, Object, Kernel, BasicObject]`

The odd-looking entries in the list are singleton classes. The singleton class of `Car` itself is included; so are the singleton class of `Object` (which is the superclass of the singleton class of `Car`) and the singleton class of `BasicObject` (which is the superclass of the singleton class of `Object`). The main point for our purpose is that `Makers` is included in the list.

Remember too that subclasses have access to their superclass's class methods. If you subclass `Car` and look at the ancestors of the new class's singleton class, you'll see `Makers` in the list.

Our original purpose in looking at `extend` was to explore a way to add to Ruby's core functionality. Let's turn now to that purpose.

#### MODIFYING CORE BEHAVIOR WITH EXTEND ####

### *Using refinements to affect core behavior* ###

## *BasicObject as ancestor and class* ##

### *Using BasicObject* ###

### *Implementing a subclass of BasicObject* ###
