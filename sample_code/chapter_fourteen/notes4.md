## *Issuing commands from inside Ruby programs* ## 
You can issue system commands in several ways in Ruby. We'll look primarily at two of them; the `system` method and the `(backticks)` technique. The other ways to communicate with system programs involve somewhat lower-level programming and are more system-dependent and therefore somewhat outside the scope of this book. We'll take a brief look at them nonetheless, and if they seem to be something you need, you can explore them further.

### *The system method and backticks* ### 
The `system` method calls a system program. Backticks (`''` --> not actual backticks, can't write them without throwing MD doc out of whack) call a system program and return its output. The choice depends on what you want to do.

#### EXECUTING SYSTEM PROGRAMS WITH THE SYSTEM METHOD #### 
To use `system`, send it the name of the program you want to run, with any arguments. The program uses the current `STDIN`, `STDOUT`, and `STDERR`. Here are three simle examples, `cat` and `grep` require pressing Ctrl-d (or whatever the "end-of-file" key is on your system) to terminate them and return control to irb. For clarity, Ruby's output is in bold and user input is in regular font:

```irb
>> system("date")
Fri Jul 13 19:53:35 UTC 2018
=> true
>> system("cat")
I'm typing on the screen for the cat command.
I'm typing on the screen for the cat command.
>> system('grep "D"')
one
two
David
David
```
When you use `system`, the global variable `$?` is set to a `Process::Status` object that contains information abou tthe call: specifically, the process ID of the process you just ran and its exit status. Here's a call to `date` and one to `cat`, the latter terminated with Ctrl-c. Each is followed by examination of `$?`:

```irb 
>> system("date")
Fri Jul 13 19:58:18 UTC 2018
=> true
>> $?
=> #<Process::Status: pid 418 exit 0>
>> system("cat")
^C=> false
>> $?
=> #<Process::Status: pid 28026 SIGINT (signal 2)>
```
And here's a call to a nonexistent program:

```irb
>> system("dates")
=> nil
>> $?
=> #<Process::Status: pid 420 exit 127>
```
The `$?` variable is thread-local: if you call a program in one thread, its return value affects only the `$?` in that thread:

```irb 
>> system("date")
Fri Jul 13 20:00:50 UTC 2018
=> true
>> $?
=> #<Process::Status: pid 426 exit 0>             #<----1.
>> Thread.new { system("datee"); p $? }.join      #<----2.
#<Process::Status: pid 428 exit 127>              #<----3.
=> #<Thread:0x000000016e4dc0@(irb):3 dead>
>> $?
=> #<Process::Status: pid 426 exit 0>             #<----4.
```
The `Process::Status` object reporting on the call to `date` is stored in `$?` in the main thread (#1). The new thread makes a call to a nonexistent program (#2), and that thread's version of `$?` reflects the problem (#3). But the main thread's `$?` is unchanged (#4). The thread-local global variable behavior works much like it does in the case of the *$n* regular-expression capture variables-and for similar reasons. In both cases, you don't want one thread reacting to an error condition that it didn't cause and that doesn't reflect its actual program flow.

The backtick technique is a close relative of `system`.

#### CALLING SYSTEM PROGRAMS WITH BACKTICKS #### 
To issue a system command with backticks, put the command between backticks. The main difference between `system` and backticks is that the return value of the backtick call is the output of the program you run:

```irb 
>> d = `date`
=> "Fri Jul 13 20:06:56 UTC 2018\n"
>> puts d
Fri Jul 13 20:06:56 UTC 2018
=> nil
>> output = `cat`
I'm typing into cat. Since I'm using backticks,
I won't see each line echoed back as I type it.
Instead, cat's output is going into the 
variable output.
=> "I'm typing into cat. Since I'm using backticks,\nI won't etc.
>> puts output
I'm typing into cat. Since I'm using backticks,
I won't see each line echoed back as I type it.
Instead, cat's output is going into the 
variable output.
```
The backticks set `$?` just as `system` does. A call to a nonexistent method with backticks raises a fatal error:

```irb 
>> `dates`
Errno::ENOENT: No such file or directory - dates
        from (irb):1:in ``'
        from (irb):1
        from /usr/local/rvm/rubies/ruby-2.3.1/bin/irb:11:in `<main>'
>> $?
=> #<Process::Status: pid 441 exit 127>
>> `date`
=> "Fri Jul 13 20:09:28 UTC 2018\n"
>> $?
=> #<Process::Status: pid 442 exit 0>
```

**Some system command bells and whistles** 
There's yet another way to execute system commands from within Ruby: the `%x` operator. `%x{date}`, for example, will execute the date command. Like the backticks, `%x` returns the string output of the command. Like its relatives `%w` and `%q` (among others), `%x` allows any delimiter, as long as bracket-style delimiters match: `%x{date}`, `%x-date-`, and `%x(date)` are all synonyms.

Both the backticks and `%x` allow string interpolation:

```irb 
command = "date"
%x(#{command})
```
This can be convenient, although the occasions on which it's a good idea to call dynamically evaluate strings as system commands are, arguably, few.

--

Backticks are extremely useful for capturing external programming output, but they aren't the only way to do it. This brings us to the third way of running programs from within a Ruby program: `open` and `Open.popen3`.

### *Communicating with programs via open and popen 3* ### 
Using the `open` family of methods to call external programs is a lot more complex than using `system` and backticks. We'll look at a few simple examples, but we won't plumb the depths of the topic. These Ruby methods map directly to the underlying system-library calls that support them, and their exact behavior may vary from one system to another more than most Ruby behavior does. 

Still-let's have a look. We'll discuss two methods: `open` and the class method `Open.popen3`. 

#### TALKING TO EXTERNAL PROGRAMS WITH OPEN #### 
You can use the top-level `open` method to do two-way communication with an external program. Here's the old standby example of `cat`:

```irb 
>> d = open("|cat", "w+")                #<----1.
=> #<IO:fd 12>
>> d.puts "Hello to cat"                 #<----2.
=> nil
>> d.gets                                #<----3.
=> "Hello to cat\n"
>> d.close                               #<----4.
=> nil
```
The call to `open` is generic; it could be any I/O stream, but in this case it's a two-way connection to a system command (#1). The pipe in front of the word `cat` indicates that we're looking to talk to a program and not open a file. The handle on the external program works much like an I/O socket or file handle. It's open for reading and writing (the `w+` mode), so we can write to it (#2) and read from it (#3). Finally, we close it (#4).

It's also possible to take advantage of the block form of `open` and save the last step:

```irb
>>  open("|cat", "w+") {|p| p.puts("hi"); p.gets }
=> "hi\n"
```

A somewhat more elaborate and powerful way to perform two-way communcation between your Ruby program and an external program is the `Open3.popen3` method. 

#### TWO-WAY COMMUNICATION WITH OPEN3.POPEN3 #### 
The `Open3.popen3` method opens communication with an external program and gives you handles on the external program's standard input, standard output, and standard error streams. You can thus write to and read from those handles separately from teh analogous streams in your pgoram.

Here's a simple `cat`-based example of `Open.popen3`:

```irb
>> require 'open3'                                           #<----1.
=> true
>> stdin, stdout, stderr = Open3.popen3("cat")                   #<----2.
=> [#<IO:fd 11>, #<IO:fd 12>, #<IO:fd 14>, #<Process::Waiter:0x00000000f14b68 run>]           #<----3.
>> stdin.puts("Hi.\nBye")                                                        #<----4.
=> nil
>> stdout.gets                                                            #<----5.
=> "Hi.\n"      
>> stdout.gets
=> "Bye\n"
```
After loading the `open3` library (#1), we make the call to `Open3.popen3`, passing it the name of the external program (#2). We get back three I/O handles and a thread (#3). (You can ignore the thread). These I/O handles go into and out of the external program. Thus we can write to the `STDIN` handle (#4) and read lines from the `STDOUT` handle (#5). These handles aren't the same as the `STDIN` and `STDOUT` streams of the irb session itself.

The next example shows a slightly more elaborate use of `Open.popen3`. Be warned: in itself, it's trivial. It's purpose is to illustrate some of the basic mechanics of the technique-and it uses threads, so it reillustrates some thread techniques too. The following listing shows the code.

```irb
require 'open3'
stdin, stdout, stderr = Open3.popen3("cat")
t = Thread.new do                                       #<----1.
  loop { stdin.puts gets }
end
u = Thread.new do                                       #<----2.
  n = 0 
  str = ""
  loop do
    str << stdout.gets
    n += 1
    if n % 3 == 0                                       #<----3.
      puts "--------\n"
      puts str
      puts "--------\n"
      str = ""
    end
  end
end
t.join
u.join
```
The program opens a two-way pipe to `cat` and uses two threads to talk and listen to that pipe. The first thread, `t` (#1) loops forever, listening to `STDIN`-your `STDIN`, not `cat`'s=and writing each line to the `STDIN` handle on the `cat` process. The second thread, `u` (#2), maintains a counter (`n`) and a string accumulator (`str`). When the counter hits a multiple of 3, as indicated by the `modulo` test (#3), the `u` thread prints out a horizontal line, the three text lines it's accumulated so far, and another horizontal line. It then resets the strign accumulator to a blank string and goes back to listening.

If you run this program, remember that it loops forever, so you'll have to interrupt it with Ctrl-c (or whatever your system uses for an interrupt signal). The output is, predictably, somewhat unexciting, but it gives you a good, direct sense of how the threads are interacting with the in and out I/O handles and with each other. In this output, the lines entered by the user are in italics:

*One*
*Two*
*Three*
--------
One
Two
Three
--------
*Four*
*Five*
*Six*
--------
Four
Five
Six
--------

As state, we're not going to go into all the details of `Open.popen3`. But you can and should keep it in mind for situations where you need the most flexibility in reading from and wriitng to an external program.
