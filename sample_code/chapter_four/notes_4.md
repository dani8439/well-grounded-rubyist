## *The missing_method method* ##
The `Kernel` module provides an instance method called `method_missing`. This method is executed whenever an object receives a message that it doesn't know how to respond to-that is, a message that doesn't match a method anywhere in the objects method-lookup path:

`>> o = Object.new`

`=> #<Object:0x00000010141bb0>`

`>> o.blah`

`NoMethodError: undefined method 'blah' for #<Object:0x00000010141bb0>`

It's easy to intercept calls to missing methods. You override `method_missing`, either on a singleton basis for the object you're calling the method on, or in the object's class or one of that class's ancestors:

`>> def o.method_missing(m, *args)`

`>>   puts "You can't call #{m} on this object; please try again."`

`>> end`

`=> nil`

`>> o.blah`

`You can't call blah on this object; please try again.`

When you override `method_missing` (in def), you need to imitate the method signature of the original. The first argument is the name of the missing method-the message that you sent the object and that it didn't understand. The `*args` parameter sponges up any remaining arguments. (You can also add a special argument to bind to a code block, but let's not worry about that until we've looked at code blocks in more detail). The first argument comes to you in the form of a symbol object. If you want to examine or parse it, you need to convert it to a string.
  Even if you override `method_missing`, the previous definition is still available to you via `super`.


### *Combining method_missing and super* ###
It's common to want to intercept an unrecognized message and decide, on the spot, whether to handle it or pass it along to the original `method_missing` (or possibly an intermediate version, if another one is defined). You can do this easily by using `super`.
Here's an example of the typical pattern:

``` class Student
      def method_missing(m, *args)
        if m.to_s.start_with?("grade_for_")   #convert symbol to string with to_s, before testing
          # return to the appropriate grade, based on parsing the method name
        else
          super
        end
      end
    end
```

Given this code, a call to, say `grade_for_english` on an instance of `student` leads to the true branch of the `if` test. If the missing method name doesn't start with `grade_for_`, the `false` branch is taken, resulting in a call to `super`. That call will take you to whatever the next `method_missing` implementation is along the object's method-lookup path. If you haven't overridden `method_missing` anywhere else along the line, super will find `Kernel`'s `method_missing` and execute that.
  Let's look at a more extensive example of these techniques. We'll write a `Person` class. Let's start at
the top with some code that exemplifies how we want the class to be used. We'll then implement the class in such a way that the code works.

```ruby
j = Person.new("John")
p = Person.new("Paul")
g = Person.new("George")
r = Person.new("Ringo")
j.has_friend(p)
j.has_friend(g)
g.has_friend(p)
r.has_hobby("rings")
Person.all_with_friends(p).each do |person|
  puts "#{person.name} is friends with #{p.name}"
end
Person.all_with_hobbies("rings").each do |person|
  puts "#{person.name} is into rings"
end
```

We'd like the output of this code to be:

`John is friends with Paul`

`George is friends with Paul`

`Ringo is into rings`


The overall idea is that a person can have friends and/or hobbies. Furthermore, the `Person` class lets us look up all the people who have a given friend, or all people who have a given hobby. The searches area accomplished with the `all_with_friends` and `all_with_hobbies` class methods.
  The `all_with_*` method-name formula looks like a good candidate for handling via `method_missing`.
Although we're using only two variants of it (friends and hobbies) it's the kind of pattern that we could extend to any number of method names. Let's intercept `method_missing` in the `Person` class.
  In this case, the `method_missing` we're dealing with is the class method: we need to intercept missing
methods called on `Person`. Somewhere along the line, therefore, we need a definition like this:

```ruby
class Person
  def self.method_missing(m, *args)
    # ^ Define method directly onto self, which is the Person class object
    # code here
  end
end
```


The method name, `m`, may or may not start with the substring `all_with_`. If it does, we want it; if it doesn't, we toss it back-or up-courtesy of `super`, and let `Kernel #method_missing` handle it. (Remember: classes are objects, so the class object `Person` has access to all of `Kernel`'s instance methods, including `method_missing`).
  Here's a slightly more elaborate (but still schematic) view of `method_missing`:

  ```ruby
  class Person
    def self.method_missing(m, *args)
      method = m.to_s #1.
      if method.start_with?("all_with_") #2
        # Handle request here
      else
        super #3
      end
    end
  end
  ```

The reason for the call to `to_s`(#1), is that the method name (the message) gets handed off to `method_missing` in the form of a symbol. Symbols don't have a `start_with?` method, so we have to convert the symbol to a string before testing its contents.
  The conditional logic(#2) branches on whether we're handling an `all_with_*` message. If we are, we
handle it. If not, we punt with super(#3).
  With at least a blueprint of `method_missing` in place, let's develop the rest of the `Person` class. A
few requirements are clear from the top-level calling code listed earlier:

  • `Person` objects keep track of their friends and hobbies.

  • The `Person` class keeps track of all existing people.

  • Every person has a name.

The second point is implied by the fact that we've already been asking the `Person` class for lists of
people who have certain hobbies and/or certain friends.
  The following listing contains an implementation of the parts of the `Person` class that pertain to
these requirements.

```ruby
class Person
  PEOPLE = [] #1
  attr_reader :name, :hobbies, :friends #2
  def initialize(name)
    @name = name #3
    @hobbies = [] #3
    @friends = [] #3
    PEOPLE << self #4
  end
  def has_hobby(hobby)
    @hobbies << hobby #5
  end
  def has_friend(friend)
    @friends << friend #5
  end
```

We stash all existing people in an array, held in the constant `PEOPLE`(#1). When a new person is instantiated, that person is added to the people array, courtesy of the array append method `<<` (#4). Meanwhile, we need some reader attributes: `name`, `hobbies`, and `friends`. (#2). Providing these attributes lets the outside world see important aspects of the `Person` objects: `hobbies` and `friends` will also come in handy in the full implementation of `method_missing`.
  The `initialize` method takes a name as its sole argument and saves it to `@name`. It also initializes
the `hobbies` and `friends` arrays (#3). These arrays come back into play in the `has_hobby` and `has_friend` methods (#5), which are really just user-friendly wrappers around those arrays.
  Now that we have enough code to finish the implementation of `Person.method_missing`. This is what it
should look like (including the final `end` delimiter for the whole class). We use a convenient built-in query method, `public_method_defined?`, which tells us whether `Person` (represented in the method by the keyword `self`) has a method with the same name as the one at the end of the `all_with_`string.

```ruby
  def self.method_missing(m, *args)
    method = m.to_s
    if method.start_with?("all_with_") #1
      attr = method[9..-1] #2
      if self.public_method_defined?(attr) #3
        PEOPLE.find_all do |person| #4
          person.send(attr).include?(args[0]) #4
        end
      else
        raise ArgumentError, "Can't find #{attr}" #5
      end
    else
      super
    end
  end
end
```

If we have an `all_with_` message(#1), we want to ignore that part and capture the rest of the string, which we can do by taking the substring that lies in the ninth through last character positions; that's what indexing the string with `9..-1` achieves(#2). (This means starting at the tenth character, because string indexing starts at zero). Now we want to know whether the resulting substring corresponds to one of `Person`'s instance methods-specifically `hobbies` or `friends`. Rather than hard-code those two names, we keep things flexible and scalable by checking whether the `Person` class defines a method with our substring as its name(#3).

  What happens next depends on whether the search for the symbol succeeds. To start with the second
branch first, if the requested attribute doesn't exist, we raise an error with an appropriate message(#5). If it does success-which it will if the message is `friends` or `hobbies` or any other attribute we added later-we get to the heart of the matter.

  In addition to the `all_with*` method name, the method call includes an argument containing the thing
we're looking for (the name of a friend or hobby, for example). That argument is found in `args[0]`, the first element of the argument "sponge" array designated as `*args` in the argument list; the business end of the whole `method_missing` method is to find all people whose `attr` includes `args[0]`(#4). That formula translates into, say, all people whose hobbies include music, or all people whose friends include some particular friend.

  Note that this version of `method_missing` includes two conditional structures. That's because two
things can go wrong: first, we may be handling a message that doesn't conform to the `all_with_*` pattern ("`blah`", for example); and second, we may have an `all_with_*` request where the * part doesn't correspond to anything that the `Person` class knows about (`all_with_children`, for example). We treat the second as a fatal condition and raise an error(#5). If the first condition fails, it means this particular message isn't what this particular `method_missing` is looking for. We hand control upward to the next-highest definition of a `method_missing` by calling `super`(#6). Called with no arguments, `super` automatically gets all the arguments that came to the current method; thus the bare call to `super` is, in this case, equivalent to `super(m, *args)` (but shorter and more convenient).

  ## **Note** ## Will look at `method_missing` further later on, it's probably the most commonly used member of the callback family, and one that you're likely to see and hear discussed sooner rather than later in your Ruby explorations.

You now have a good grasp of both classes and modules, as well as how individual objects, on receiving messages, look for a matching method by traversing their class/module family tree, and how they handle lookup failure. Next, we'll look at what we can do with this system-specifically the kinds of decisions you can an should make as to the design and naming of your classes and modules, in the interest of writing clear and comprehensible programs.
