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

#### A BASIC ROCK/PAPER/SCISSORS LOGIC IMPLEMENTATION #### 

#### USING THE RPS CLASS IN A THREADED GAME #### 

## *Issuing commands from inside Ruby programs* ## 

### *The system method and backticks* ### 

#### EXECUTING SYSTEM PROGRAMS WITH THE SYSTEM METHOD #### 

#### CALLING SYSTEM PROGRAMS WITH BACKTICKS #### 

**Some system command bells and whistles** 

### *Communicating with programs via open and popen 3* ### 

#### TALKING TO EXTERNAL PROGRAMS WITH OPEN #### 

#### TWO-WAY COMMUNICATION WITH OPEN3.POPEN3 #### 
