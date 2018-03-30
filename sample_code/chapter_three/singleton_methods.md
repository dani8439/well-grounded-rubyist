## Singleton Methods ##

Here's an example. Let's say we've created our `Ticket` class. At this point, `Ticket` isn't only a class from which objects (ticket instances) can arise. `Ticket` (the class) is also an object in its own right. As we've done with other objects, let's add a singleton method to it. Our method will tell us which ticket, from a list of ticketobjects is the most expensive.

in ticket_price.rb, the `most_expensive` method is the singleton method. A singleton method defined on a class object is commonly referred to as a *class method* of the class on which it's defined.The idea of a class method is that you send a message to the object that's the class rather than to one of the class's instances. The message `most_expensive` goes to the class `Ticket`, not to a particular ticket.
