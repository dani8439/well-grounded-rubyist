# ## *Constants Up Close* ##
# Many classes consist principally of instance methods and/or class methods. But constants are an important and common third ingredient in many classes. You've already seen constants used as the names of classes. Constants can also be used to set and preserve important data values in classes.
#   For now, we'll focus on the basics of how to use them-and the question of how constant these constants
# really are.
#
# ### *Basic use of constants* ###
# The name of every constant begins with a capital letter. You assign to constants much as you do to variables.
#   Let's say we decide to establish a list of predefined venues for the `Ticket` class-a list that every
# ticket object can refer to and select from. We can assign the list to a constant. Constant definitions
#usually go at or near the top of the class definition.



class Ticket
  # VENUES = ["Convention Center", "Fairgrounds", "Town Hall"]

  #A constant defined in a class can be referred to from inside the class's instance or class methods. Let's say
  #you wanted to make sure that every ticket was for a legitimate venue. You could rewrite the initialize method like this:

  def initialize(venue, date)
    if VENUES.include?(venue)  #<-- Is this one of the known venues?
      @venue = venue
    else
      raise ArgumentError, "Unknown venue #{venue}"   #<-- Raise an exception - fatal error
    end
    @date = date
  end

end

#It's also possible to refer to a constant from outside the class definition entirely, using a special constant
#lookup notation: a double colon (::). Here's an example of setting a constant inside a class and then referring to
#that constant from outside the class:

class Ticket
  VENUES = ["Convention Center", "Fairgrounds", "Town Hall"]
end

puts "We've closed the class definition."
puts "So we have to use the path notation to reach the constant."
puts "The venues are:"
puts Ticket::VENUES

#The double-colon notation pinpoints the constant VENUES inside the class known by the constant Ticket, and the list of venues is printed out.
  #Ruby will come with some predefined constants that you can access this way and that you may find useful.
  #Ex: In irb session, type Math::PI Math is a module. The constant PI is defined in the Math module.
#Many of the predefined constants you can examine when you start up Ruby (or irb) are the names of the built-in classes:
#String, Array, Symbol, and so forth. Some are informational.

#Reassigning vs Modifying Constants
#It's possible to perform an assignment on a constant to which you've already assigned something - that is, to reassign the constant.
#But you get a warning if you do this.
#The fact that constant names are reusable while the practice of reusing them is a warnable offense represents a compromise.
#On one hand, it's useful for the language to have a separate category for constants, as a way of storing data that remains visible
#over a longer stretch of the program than a regular variable. On the other hand, Ruby is a dynamic language, in the sense that anything
#can change during runtime. Engineering constants to be an exception to this would theoretically be possible, but would introduce an anomoly
#in the language.
#In addition, bc you can reload program files 
