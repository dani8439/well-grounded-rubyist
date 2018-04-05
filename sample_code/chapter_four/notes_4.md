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
        if m.to_s.start_with?("grade_for_")
          # return to the appropriate grade, based on parsing the method name
        else
          super
        end
      end
    end
```
Given this code, 
