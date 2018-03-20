## *Sending Messages to objects with the Send Method* ##
Suppose you want to let a user get information from the `ticket` object by entering an appropriate query term
(`venue.performer`, and so on) at the keyboard. Here's what you'd add to the existing program:

`print "Information desired: "`

`request = gets.chomp`

The second line of code gets a line of keyboard input, "chomps" off the trailing newline character, and saves the resulting string in the variable `request`.

At this point, you could test the input for one value after another by using the double equal sign comparison operator (==), which compares strings based on their content, and calling the method whose value provides a match:

`if request == "venue"`

`   puts ticket.venue`

`elsif request = "performer"`

`   puts ticket.performer`

  ...

To be thorough, though, you'd have to continue through the whole list of ticket properties. That's going to get lengthy.
There's an alternative: you can send the word directly to the `ticket` object. Instead of the previous code, you'd do the following:

`if ticket.respond_to?(request)`

`   puts ticket.send(request)`

`else`

`   puts "No such information available"`

`end`

This version uses the `send` method as an all-purpose way of getting a message to the `ticket` object. It relieves you of having to march through the whole list of possible requests. Instead, having checked that the `ticket` object knows what to do, you hand the `ticket` the message and let it do its thing.

Most of the time, you'll use the dot operator to send messages to objects. But the `send` alternative can be useful and powerful-powerful enough, and error-prone enough, that it almost always merits at least the level of safety-netting represented by a call to `respond_to?`. In some cases, `respond_to?` might even be too broad to be safe you might only `send` a message to an object if the message is included in a predetermined message "whitelist". The guiding principle is care: be careful about sending arbitrary messages to objects, especially if those messages are based on user choice or input.
