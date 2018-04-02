module Stacklike
  def stack
    @stack ||=[]
    # the or-equals oeprator. The effect of this operator is to set the variable to the specified value-which in this case
    # is a new, empty array-if and only if the variable isn't already set to something other than nil or false. In practical
    # terms, this means that the first time stack is called, it will set @stack(and instance variable) to an empty array,
    # whereas on subsequent calls it will see that @stack already has a value and will simply return that value (the array).
  end
  def add_to_stack(obj)
    stack.push(obj)
    # When an object is added to the stack, the operation is handled by pushing the object onto the @stack array - that is,
    # adding it to the end. (@stack is accessed through a call to the stack method, which ensures that it will be initialized
    # to an empty array the first time an object is added)
  end
  def take_from_stack
    stack.pop
    # Removing an object from the stack involves popping an element from the array - that is removing it from the end (push and
    # pop are instance methods of the Array class)
  end
end
