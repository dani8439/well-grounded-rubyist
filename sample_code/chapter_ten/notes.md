# *Collections central: Enumerable and Enumerator* # 
All collection objects aren't created equal-but an awful lot of them have many characteristics in common. In Ruby, common characteristics among many objects tend to reside in modules. Collections are no exception: collection objects in Ruby typically include the `Enumerable` module.

Classes that use `Enumerable` enter into a kind of contract: the class has to define an instance method called `each`, and in return, `Enumerable` endows the objects of the class with all sorts of collection-related behaviors. The methods behind these behaviors are defined in terms of `each`. In some respects, you might say the whole concept of a "collection" in Ruby is pegged to the `Enumerable` module and the methods it defines on top of `each`. 

Keep in mind that although every major collection class partakes of the `Enumerable` module, each of them has its own methods too. The methods of an array aren't identical to those of a set; those of a range aren't identical to those of a hash. And sometimes, collection classes share method names but the methods don't do exactly the same thing. They *can't* always do the same thing; the whole point is to have multiple collection classes but to extract as much common behavior as possible into a common module.

You can mix `Enumerable` into your own classes:

```ruby 
class C 
  include Enumerable
end
```
By itself, that doesn't do much. To tap into the benefits of `Enumerable`, you must define an `each` instance method in your class: 

```ruby 
class C 
  include Enumerable 
  def each 
    # relevant code here
  end
end
```

At this point, objects of class `C` will have the ability to call any instance method defined in `Enumerable`. 

In addition to the `Enumerable` module, in this chapter we'll look at a closely related class called `Enumerator`. *Enumerators* are objects that encapsulate knowledge of how to iterate through a particular collection. By packaging iteration intelligence in an object that's separate from the collection itself, enumerators add a further and powerful dimension to Ruby's already considerable collection-manipulation facilities.

## *Gaining enumerability through each* ## 
Any class that aspires to be enumerable must have an `each` method whose job is to yield items to a supplied code block, one at a time. 

Exactly what `each` does will vary from one class to another. 
