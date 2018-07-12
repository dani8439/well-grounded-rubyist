## *Parallel execution with threads* ## 
Ruby's threads allow you to do more than one thing at once in your program, through a form of time sharing: one thread executes one or more instructions and then passes control to the next thread, and so forth. Exactly how the simultaneity of threads plays out depends on your system and you rRuby implementation. Ruby will try to use native operating-system threading facilities, but if such facilities aren't available, it will fall back on *green* threads (threads implemented completely inside the interpreter). We'll black-box the green-versus-native issue here; our concern will be principally with threading techniques and syntax.

Creating threads in Ruby is easy: you instantiate the `Thread` class. A new thread starts executing immediately, but the execution of the code around the thread doesn't stop. If the program ends while one or more threads are running, those threads are killed.

Here's a kind of inside-out example that will get you started with threads by showing you how they behave when a program ends:

```ruby
Thread.new do
  puts "Starting the thread"
  sleep 1
  puts "At the end of the thread"
end
puts "Outside the thread"
```
`Thread.new` takes a code block, which constitutes the thread's executable code. In this example, the thread prints a message, sleeps for one second, and then prints another message. But outside the thread, time marches on: the main body of the program prints a message immediately (it's not affected by the `sleep` command inside the thread), and then the program ends. Unless printing a message takes more than a second-in which case you need to get your hardware checked! The second message from the thread will never be seen. You'll only see this:

```irb 
Starting the thread
Outside the thread
```
Now, what if we want to allow the thread to finish executing? To do this, we have to use the instance method `join`. The easiest way to use `join` is to save the thread in a variable and call `join` on the variable. Here's how you can modify the previous example along these lines:

```ruby 
t = Thread.new do
  puts "Starting the thread"
  sleep 1
  puts "At the end of the thread"
end
puts "Outside the thread"
t.join
```
This version of the program produces the following output,w ith a one-second pause between the printing of the first message from the thread and the printing of the last message:

```irb 
Outside the thread
Starting the thread             #<----Pause as the program waits for thread to finish execution
At the end of the thread
```
In addition to joining a thread, you can manipulate it in a variety of other ways, including killing it, putting it to sleep, waking it up, and forcing it to pass control to the next thread scheduled for execution.

### *Killing, stopping, and starting threads* ### 
To kill a thread, you send it the message `kill`, `exit`, or `terminate`; all three are equivalent. Or, if you're inside the thread, you can `kill` (or one of its synonyms) in class-method form on `Thread` itself.

You may want to kill a thread if an exception occurs inside it. Here's an example, admittedly somewhat contrived but brief enough to illustrate the process efficiently. The idea is to read the contents of three files (part00, part01, and part02) into the string `text`. If any of the files isn't found, the thread terminates:

```ruby 
puts "Trying to read in some files..."
t = Thread.new do
  (0..2).each do |n|
    begin
      File.open("part0#{n}") do |f|
        text << f.readlines
      end
    rescue Errno::ENOENT
      puts "Message from thread: Failed on n=#{n}"
      Thread.exit
    end
  end
end
t.join
puts "Finished!"
```
The output, assuming part00 exists but part01 doesn't, is this:

```irb
Trying to read in some files...
Message from thread: Failed on n=0
Finished!
```
You can also stop and start threads and examine their state. A thread can be asleep or awake, and alive or dead. Here's an example that puts a thread through a few of its paces and illustrates some of the available techniques for examining and manipulating thread state:

```ruby 
t = Thread.new do
  puts "[Starting thread]"      #<---[Starting thread]
  Thread.stop
  puts "[Resuming thread]"
end
puts "Status of thread: #{t.status}"        #<---- Status of thread: sleep
puts "Is thread stopped? #{t.stop?}"            #<---- Is thread stopped? true
puts "Is thread alive? #{t.alive?}"                  #<---- Is thread alive? true
puts
puts "Waking up thread and joining it..."
t.wakeup
t.join                                      #<----[Resuming thread]
puts
puts "Is thread alive? #{t.alive?}"               #<----Is thread alive? false
puts "Inspect string for thread: #{t.inspect}"        #<---- Inspect string for thread: #<Thread:0x28d20 dead>

# Status of thread: run
# Is thread stopped? true
# Is thread alive? true
# [Starting thread]
# Waking up thread and joining it...
# [Resuming thread]
# Is thread alive? false
# Inspect string for thread: #<Thread:0x00000001ad95e8@thread.rb:22 dead>
``` 
**Fibers: A twist on threads** 
In addition to threads, Ruby has a `Fiber` class. Fibers are like reentrant code blocks: they can yield back and forth to their calling context multiple times. 

A fiber is created with the `Fiber.new` constructor, which takes a code block. Nothing happens until you tell the fiber to `resume`, at which point the code block starts to run. From within the block, you can suspend the fiber, returning control to the calling context with the class method `Fiber.yield`.

Here's a simple example involving a *talking* fiber that alternates control a couple of times with its calling context:

```ruby
f = Fiber.new do
  puts "Hi"
  Fiber.yield
  puts "Nice day."
  Fiber.yield
  puts "Bye!"
end
f.resume
puts "Back to the fiber:"
f.resume
puts "One last message from the fiber:"
f.resume
puts "That's all!"
```
Here's the output from this snippet:

```irb
Hi
Back to the fiber:
Nice day.
One last message from the fiber:
Bye!
That's all!
```
Among other things, fibers are the technical basis of enumerators, which use fibers to implement their own stop and start operations.

Let's continue exploring threads with a couple of networked examples: a date server and, somewhat more ambitiously, a chat server. 

### *A threaded date server* ### 
The date server we'll write depends on a RUby facility that we haven't looked at yet: `TCPServer`. `TCPServer` is a socket-based class that allows you to start up a server almost unbelievably easily: you instantiate the class and pass in a port number. Here's a simple example of `TCPServer` in action, serving the current date to the first person who connects to it:

```ruby 
require 'socket'
s = TCPServer.new(3939)
conn = s.accept
conn.puts "Hi. Here's the date."
conn.puts `date`      #<---date in backticks executes the system date command
conn.close
s.close
```
Put this example in a file called dataserver.rb, and run it from the command line. (If port 3939 isn't available, change the number to something else.) Now, from a different console, connect to the server:

`telnet localhost3939`

You'll see output similar to the following:

```irb
Trying 127.0.0.1...
Connected to localhost 
Escape character is '^]'.
Hi. Here's the date.
Sat Jan 18 07:29:11 EST 2014 
Connection closed by foreign host.
```
The server has fielded the request and responded.

What if you want the server to field multiple requests? Easy: don't close the socket, and keep accepting connections.

```ruby 
require 'socket'
s = TCPServer.new(3939)
while true 
  conn = s.accept
  conn.puts "Hi. Here's the date."
  conn.puts `date`
  conn.close
end
```
Now you can ask for the date more than once, and you'll get an answer each time.

Things get trickier when you want to send information *to* the server. Making it work for one user is straightforward; the server can accept input by calling gets:

```ruby 
require 'socket'
s = TCPServer.new(3939)
while true 
  conn = s.accept
  conn.puts "Hi. What's your name? "
  name = conn.gets.chomp                    #<---- Accepts line of keyboard input from client. 
  conn.puts "Hi, #{name}. Here's the date. "
  conn.puts `date`
  conn.close
end
```
But if a second client connects to the server while the server is still waiting for the first client's input, the second client sees nothing-not even `What's your name?`-because the server is busy.

That's where threading comes in. Here's a threaded date server that accepts input from the client. The threading prevents the entire application from blocking while it waits for a single client to provide input:

```ruby
require 'socket'
s = TCPServer.new(3939)
while (conn = s.accept)                   #<----1.
  Thread.new(conn) do |c|                      #<----2.
    c.print "Hi. What's your name? "
    name = c.gets.chomp                              #<----3.
    c.puts "Hi, #{name}. Here's the date. "
    c.puts `date`
    c.close
  end
end
```
In this version, the server listens continuously for connections (#1). Each time it gets one, it spawns a new thread (#2). The significance of the argument to `Thread.new` is that if you provide such an argument, it's yielded back to you as the block parameter. In this case, that means binding the connection to the parameter `c`. Although this technique may look odd (sending an argument to a method, only to get it back when the block is called), it ensures that each thread has a reference to its own connection rather than fighting over the variable `conn`, which lives outside any thread.

Even if a client waits for several minutes before typing in a name (#3), the server is still listening for new connections, and new threads are still spawned. The threading approach thus allows a server to scale while incorporating two-way transmission between itself and one or more clients.

The next level of complexity is the chat server. 

### *Writing a chat server using sockets and threads* ### 
We'll start code-first this time. Listing below shows the chat-server code. A lof ot what it does is similar to what the date server does. The main difference is that the chat server keeps a list (an array) of all the incoming connections and uses that list to broadcast the incoming chat messages.

```ruby 
require 'socket'                                           #<----1.
def welcome(chatter)                                          #<----2.
  chatter.print "Welcome! Please enter your name: "
  chatter.readline.chomp
end
def broadcast(message, chatters)                                #<----3.
  chatters.each do |chatter|
    chatter.puts message
  end
end
s = TCPServer.new(3939)                                           #<----4.
  chatters = []
while (chatter = s.accept)                                          #<----5.
  Thread.new(chatter) do |c|
    name = welcome(chatter)                                           #<----6.
    broadcast("#{name} has joined", chatters)
    chatters << chatter
    begin                                                             #<----7.
      loop do
        line = c.readline                                             #<----8.
        broadcast("#{name}: #{line}", chatters)
      end
    rescue EOFError                                                   #<----9.
      c.close
      chatters.delete(c)                                              #<----10.
      broadcast("#{name} has left", chatters)
    end
  end
end
```
There's a lot of code in this listing, so we'll take it in the order it executes. First comes the mandatory loading of the socket library (#1). The next several lines define some needed helper methods; we'll come back to those after we've seen what they're helping with. The real beginning of the action is the instantiation of `TCPServer` and the initialization of the array of chatters(#4).

The server goes into a `while` loop similar to the loop in the date server (#5). When a chatter connects, the server welcomes it (him or her, really, but *it* will do) (#6). The welcome process involves the `welcome` method (#2), which takes a chatter-a socket object-as its argument, prints a nice welcome message, and returns a line of client input. Now it's time to notify all the current chatters that a new chatter has arrived. This involves the `broadcast` method (#3), which is the heart of the chat functionality of the program: it's responsible for going through the array of chatters and sending a message to each one. In this case, the message states that the new client has joined the chat.

After being announced, the new chatter is added to the chatters array. That means it will be included in future message broadcasts.

Now comes the chatting part. It consists of an infinite loop wrapped in a `begin/rescue` clause (#7). The goal is to accept message from this client forever but to take action of the client socket reports end-of-file. Messages are accepted via `readline` (#8), which has the advantage over `gets`. If the chatter leaves the chat, then the next attempt to read a line from that chatter raises `EOFError`. When that happens, control goes to the `rescue` block (#9), where the departed chatter is removed from teh chatters array and an announcement is broadcast to the effect that the chatter has left (#10).

If there's no `EOFError`, the chatter's message is broadcast to all chatters (#8).

When using threads, it's important to know how the rules of variable scoping and visibility play out inside thread-and in looking at this topic, which we'll do next, you'll also find out about a special category of thread-specific variables.

### *Threads and variables* ### 
Threads run using code blocks, and code blocks can see the variables already created in their local scope. If you create a local variable and change it inside a thread's code block, the change will be permanent:

```irb 
>> a = 1
=> 1
>> Thread.new { a = 2 }
=> #<Thread:0x00000002436f00@(irb):2 run>
>> a
=> 2
```
You can see an interesting and instructive effect if you stop a thread before it changes a variable, and then run the thread:

```irb 
>> t = Thread.new { Thread.stop; a = 3 }
=> #<Thread:0x00000002422280@(irb):6 run>
>> a
=> 2
>> t.run
=> #<Thread:0x00000002422280@(irb):6 dead>
>> a
=> 3
```
Global variables remain global, for the most part, in the fact of threads. That goes for built-in globals, such as `$/` (the input record separator), as well as those you create yourself:

```irb 
>> $/
=> "\n"
>> $var = 1
=> 1
>> Thread.new { $var = 2; $/ = "\n\n" }
=> #<Thread:0x000000023a5820@(irb):12 run>
>> $/
=> "\n\n"
>> $var
=> 2
```
But some globals are *thread-like globals*-specifically, the `$1`, `$2`, ..., *$n* that are assigned the parenthetical capture values from the most recent regular expression-matching operation. You get a different does of those variables in every thread. Here's a snippet that illustrates the fact that the *$n* variables in different threads don't collide:

```ruby
/(abc)/.match("abc")
t = Thread.new do
  /(def)/.match("def")
  puts "$1 in thread: #{$1}"     #<---Output: $1 in thread: def
end.join
puts "$1 outside thread: #{$1}"     #<---Output: $1 outside thread: abc
```
The rationale for this behavior is clear: you can't have one thread's idea of `$1` overshadowing the `$1` from a different thread, or you'll get extremely odd results. The *$n* variables aren't really globals once you see them in the context of the language having threads.

In addition to having access to the usual suite of Ruby variables, threads also have their own variable stash-or, more accurately, a built-in hash that lets them associate symbols or strings with values. These thread keys can be useful.

### *Manipulating thread keys* ### 
*Thread keys* are basically a storage hash for thread-specific values. The keys must be symbols or strings. You can get at the keys by indexing the thread object directly with values in square brackets. You can also get a list of all the keys (without their values) using the *keys* method.

Here's a simple set-and-get-scenario using a thread key:

```ruby 
t = Thread.new do
  Thread.current[:message] = "Hello"
end
t.join
p t.keys
puts t[:message]
```
The output is

```irb 
[:message]
Hello
```
Threads seem to loom large in games, so let's use a game example to explore thread keys further: a threaded, networked rock/paper/scissors (RPS) game. We'll start with the (threadless) RPS logic in an `RPS` class and use the resulting RPS library as the basis for the game code.

#### A BASIC ROCK/PAPER/SCISSORS LOGIC IMPLEMENTATION #### 
The next listing show sthe `RPS` class, which is wrapped in a `Games` module (because RPS sounds like it might collide with another class name). Save this listing to a file called rps.rb. 

```ruby 
module Games
  class RPS
    include Comparable                      #<----1.
    WINS = [%w{ rock scissors },            #<----2.
            %w{ scissors paper },
            %w{ paper rock}]
    attr_accessor :move                     #<----3.
    def initialize(move)                    #<----4.
      @move = move.to_s
    end
    def <=>(other)                          #<----5.
      if move == other.move
        0
      elsif WINS.include?([move, other.move])
        1
      elsif WINS.include?([other.move, move])
        -1
      else
        raise ArgumentError, "Something's wrong"
      end
    end
    def play(other)                         #<----6.
      if self > other
        self
      elsif other > self
        other
      else
        false
      end
    end
  end
end
```
The `RPS` class includes the `Comparable` module (#1); this serves as the basis for determining, ultimately, who wins a game. The `WINS` constant contains all possible winning combinations in three arrays; the first element in each array beats the second element (#2). There's also a `move` attribute, which stores the move for this instance of `RPS` (#3). The `initialize` method (#4) stores the move as a string (in case it comes in as a symbol).

`RPS` has a spaceship operator (`<=>`) method definition (#5) that specifies what happens when this instance of `RPS` is compared to another instance. If the two have equal moves, the result is `0`-the signal that the two terms of a spaceship comparison are equal. The rest of the logic looks for winning combinations using the `WINS` array, returning `-1` or `1` depending on whether this instance or the other instance has won. If it doesn't find that either player has a win, and the result isn't a tie, it raises an exception.

Now that `RPS` objects know how to compare themselves, it's easy to play them against each other, which is what the `play` method does (#6). It's ismple: whichever player is higher is the winner, and if it's a tie, the method returns false.

We're now ready to incorporate the `RPS` class in a threaded, networked version of the game, thread keys and all.

#### USING THE RPS CLASS IN A THREADED GAME #### 
THe following listing shows the networked RPS program. It waits for two people to join, gets their moves, reports the result, and exits. Not glitzy-but a good way to see how thread keys might help you.

```ruby 
require 'socket'
require_relative 'rps'
s = TCPServer.new(3939)               #<----1.
threads = []                            #<----2.
2.times do |n|                            #<----3.
  conn = s.accept
  threads << Thread.new(conn) do |c|        #<----4.
    Thread.current[:number] = n + 1
    Thread.current[:player] = c
    c.puts "Welcome player #{n + 1}!"
    c.print "Your move? (rock, paper, scissors) "
    Thread.current[:move] = c.gets.chomp
    c.puts "Thanks... hang on."
  end
end
a,b = threads                                 #<----|
a.join                                        #<----5. Use parallel assignment syntax to assign two variables from an array
b.join                                        #<----|
rps1, rps2 = Games::RPS.new(a[:move]), Games::RPS.new(b[:move])       #<----6.
winner = rps1.play(rps2)                      #-----|
if winner                                     #-----|
  result = winner.move                        #-----|
else                                          #<----7.
  result = "TIE!"                             #-----|
end                                           #-----|
threads.each do |t|
  t[:player].puts "The winner is #{result}!"              #-----8.
end
```
This program loads and uses the `Games::RPS` class, so make sure you have the RPS code in the file rps.rb in the same directory as the program itself. 

As in the chat-server example, we start with a server (#1) along with an array in which threads are stored (#2). Rather than loop forever, though, we gather only two threads courtesy of the `2.times` loop and the server's `accept` method (#3). For each of the two connections, we create a thread (#4).

Now we store some values in the thread's keys: a number for this player (based off the `times` loop, adding 1 so that there's no player 0) and the connection. We then welcome the player and store the move in the `:move` key of the thread.

After both players have played, we grab the two threads in the convenience variables `a` and `b` and join both threads (#5). Next, we parlay the two thread objects, which have memory of the player's moves, into two `RPS` objects (#6). The winner is determined by playing one against the other. The final result of the game is either the winner or, if the game returned false, a tie (#7).

Finally, we report the results to both players (#8). You could get fancier by inputting their names or repeating the game and keeping score. But the main point of this version of the game is to illustrate the usefulness of thread keys. Even after the threads have finsihed running, they remember information, and that enables us to play an entire game as well as send further messages through the players' sockets. 

We're at the end of our look at Ruby threads. It's worth nothing that threads are an area that has undergone and continues to undergo a lot of change and development. But whatever happens, you can build on the grounding you've gotten here as you explore and use threads further.

Next on the agenda, and last for this chapter, is the topic of issuing system commands from Ruby. 

