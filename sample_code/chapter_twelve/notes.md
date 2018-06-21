# *File and I/O operations* #
Ruby keeps even file and I/O object oriented. Input and output streams, like the standard input stream or, for that matter, any file handle, are objects. Some I/O-related commands are more procedural: `puts` for example, or the `system` method that lets you execute a system command. But `puts` is only procedural when it's operating on the standard output stream. When you `puts` a line to a file, you explicitly send the message "puts" to a `File` object.

The memory space of a Ruby program is a kind of idealized space, where objects come into existence and talk to each other. Given the fact that I/O and system command execution involve stepping outside this idealized space, Ruby does a lot to keep objects in the mix. 

The file-handling facilities in the standard library-highlighed by the `FileUtils`, `Pathname`, and `StringIO` packages-are so powerful and so versatile that they've achieved a kind of quasi-core status. Odds are, if you do any kind of file-intensive Ruby programming, you'll get to the point where you load these packages without thinking about it. 

## *How Ruby's I/O system is put together* ## 
The `IO` class handles all input and output streams either by itself or via its descendant classes, particularly `File`. To a large extent, `IO`'s API consists of wrappers around system library calls, with some enhancements and modifications. The more familiar you are with the C standard library, the more at home you'll feel with methods like `seek`, `getc`, and `eof?`. Likewise, if you've used another high-level language that also has a fairly close-fitting wrapper API around those library methods, you'll recognize their equivalent in Ruby. But even if you're not a systems or C programmer, you'll get the hang of it quickly.

### *The IO class* ### 
`IO` objects represent readable and/or writable connections to disk files, keyboards, screens, and other devices. You treat an `IO` object like any other object: you send it messages, and it executes methods and returns the results.

When a Ruby program starts up, it's aware of the standard input, output, and error streams. All three are encapsulated in instances of `IO`. You can use them to get a sense of how a simple `IO` object works:

```irb 
>> STDERR.class                   #<-----1.
=> IO
>> STDERR.puts("Problem!")        #<-----2.
Problem!
=> nil
>> STDERR.write("Problem!\n")     #<-----3.
Problem!
=> 9
```
The constants `STDERR`, `STDIN`, and `STDOUT` (all of which will be covered in detail later on in this chapter) are automatically set when the program starts. `STDERR` is an `IO` object (#1). If an `IO` object is open for writing (which `STDERR` is, because the whole point is to output status and error messages to it), you can call `puts` on it, and whatever you `puts` will be written to that `IO` object's output stream (#2). In the case of `STDERR`-at least, in the default startup situation-that's a fancy way of saying that it will be written to the screen.

In addition to `puts`, `IO` objects have the `print` method and a `write` method. If you `write` to an `IO` object, there's no automatic newline output (`write` is like `print` rather than `puts` in that respect), and the return value is the number of bytes written (#3).

`IO` is a Ruby class, and as a class it's entitled to mix in modules. And so it does. In particular, `IO` objects are enumerable.

### *IO objects as enumerables* ###
An enumerable, as you know, must have an `each` method so that it can iterate. `IO` objects iterate based on the global input record separator, which, as you say in connection with strings and their `each_line` method in chapter 10, is stored in the global variable `$/`.

In the following examples, Ruby's output is indicated by **bold** type; regular indicates keyboard input. The code performs an iteration on `STDIN`, the standard input stream. (We'll look more closely at `STDIN` and friends in the next section.) At first, `STDIN` treats the newline character as the signal that one iteration has finished; it thus prints each line as you enter it:

```irb
>> STDIN.each {|line| p line }
This is line 1
**"This is line 1\n"**
This is line 2
**"This is line 2\n"**
All separated by $/, which is a newline character
**"All separated by $/, which is a newline character\n"**
```
But if you change the value of `$/`, `STDIN`'s idea of what constitutes an iteration also changes. Terminate the first iteration with Ctrl-d (or Ctrl-c, if necessary!), and try this example:

```irb
>> $/ = "NEXT"
**=> "NEXT"**
>> STDIN.each {|line| p line }
First line
NEXT
**"First line\nNEXT"**
Next line
where "line" really means
until we see...NEXT
**"\nNext line\nwhere \"line\" really means\nuntil we see...NEXT"**
```
Here, Ruby accepts keyboard input until it hits the string `"NEXT"`, at which point it considers the entry of the record to be complete.

So `$/` determines an `IO` object's sense of "each." And because `IO` objects are enumerable, you can perform the usual enumerable operations on them. (You can assume that `$/` has been returned to its original value in these examples.) The `^D` notation indicates that the typist entered Ctrl-d at that point:

```irb
>> STDIN.select {|line| line =~ /\A[A-Z]/ }
We're only interested in
lines that begin with
Uppercase letters
**=> ["We're only interested in\n", "Uppercase letters\n"]**
>> STDIN.map {|line| line.reverse }
senil esehT
terces a niatnoc
.egassem
**=> ["\nThese lines", "\ncontain a secret", "\nmessage."]**
```
We'll come back to the enumerable behaviors of `IO` objects in the context of file handling later on. Meanwhile, the three basic `IO` objects-`STDIN`, `STDOUT`, and `STDERR`-are worth a closer look.

### *STDIN, STDOUT, STDERR* ### 
If you've written programs and/or shell scripts that used any kind of I/O piping, then you're probably familiar with the concept of the *standard* input, output, and error streams. They're basically defaults: unless told otherwise, Ruby assumes that all input will come from the keyboard, and all normal output will go to the terminal. *Assuming,* in this context, means that the unadorned, procedural I/O methods, like `puts` and `gets`, operate on `STDOUT` and `STDIN` respectively.

Error messages and `STDERR` are a little more involved. Nothing goes to `STDERR` unless someone tells it to. So if you want to use `STDERR` for outpu, you have to name it explicitly:

```ruby 
if broken?
  STDERR.puts "There's a problem!"
end
```
In addition to the three constants, Ruby also gives you three global variables: `$stdin`, `$stdout`, and `$stderr`.

#### THE STANDARD I/O GLOBAL VARIABLES #### 
The main difference between `STDIN` and `$stdin` (and the other pairs likewise) is that you're not supposed to reassign to the constant but you can reassign to the variable. The variables give you a way to modify default standard I/O stream behaviors without losing the original streams.

For example, perhaps you want all output going to a file, including standard out and standard error. You can achieve this with some assignments to the global variables. Save this code in outputs.rb:

```ruby
record = File.open("/tmp/record", "w")
old_stdout = $stdout
$stdout = record
$stderr = $stdout
puts "This is a record"
z = 10/0
```
The first step is to open the file to which you want to write. (If you don't have a /tmp directory on your system, you can change the filename so that it points to a different path, as long as you have write permission to it.) Next, save the current `$stdout` to a variable, in case you want to switch back to it later.

Now comes the little dance of the I/O handles. First, `$stdout` is redefined as the output handle `record`. Next, `$stderr` is set equivalent to `$stdout`. At this point, any plain old `puts` statement results in output being written to the file /tmp/record, because plain `puts` statements output to `$stdout`-and that's where `$stdout` is now pointing. `$stderr` output (like the error message resulting from a division by zero) also goes to the file, because `$stderr`, too, has been reassigned that file handle. 

The result is that when you run the program, you see nothing on your screen; but /tmp/record looks like this:

```
This is a record
outputs.rb:6:in `/': divided by 0 (ZeroDivisionError)
  from outputs.rb:6:in `<main>'
```
Of course, you can also send standard output to one file and standard error ot another. The global variables let you manipulate the streams any way you need to.

We'll move on to files soon, but while we're talking about I/O in general and the standard streams in particular, let's look more closely at the keyboard.

### *A litte more about keyboard input* ###
Keyboard input is accomplished, for the most part, with `gets` and `getc`. As you've seen, `gets` returns a single line of input, `getc` returns one character.

One difference between these two methods is that in the case of `getc`, you need to name your input stream explicitly:

```ruby
line = gets
char = STDIN.getc
```
In both cases, input is buffered: you have to press Enter before anything happens. It's possible to make `getc` behave in an unbuffered manner so that it takes its input as soon as the character i struck, but there's no portable way to do this across Ruby platforms. (On UNIX-ish platforms, you can set the terminal to "raw" mode with the `stty` command. You need to use the `system` method, described in chapt 14, to do this from inside Ruby.)

If for some reason you've got `$stdin` set to osmething other than the keyboard, you can still read keyboard input by using `STDIN` explicitly as the receiver of `gets`:

`line = STDIN.gets` 

Assuming you've followed the advice in the previous section and done all your standard I/O stream juggling through the use of global variables rather than the constants, `STDIN` will still be the keyboard input stream, even if `$stdin` isn't.

At this point, we're going to turn to Ruby's facilities for reading, writing, and manipulating files.

## *Basic file operations* ## 
THe built-in class `File` provides the facilities for manipulating files in Ruby. `File` is a subclass of `IO`, so `File` objects share certain properties with `IO` objects, although the `File` class adds and changes certain behaviors.

We'll look first at basic file operations, including opening, reading, writing, and closing files in various modes. Then, we'll look at a  more "Rubyish" way to handle file reading and writing: with code blocks. After that, we'll go more deeply into the enumerability of files, and then end the section with an overview of osme of the common exceptions and error messages you may get in the course of manipulating files. 

### *The basics of reading from files* ###
Reading from a file can be performed one byte at a time, a specified number of bytes at a time, or one line at a time (where *line* is defined by the `$/` delimiter). You can also change the position of the next read operation in the file by moving forward or backward a certain number of bytes or by advancing the `File` object's internal pointer to a specified byte offset in the file.

All of these operations are performed courtesy of `File` objects. So, the first step is to create a `File` object. The simplest way to do this is with `File.new`. Pass a filename to this constructor, and assuming the file exists, you'll get back a file handle opened for reading. The following examples involve a file called ticket2.rb that contains the code from chapter 3, and that's stored in a directory called code:

```irb 
>> f = File.new("code/ticket2.rb")
=> #<File:code/ticket2.rb>
```
(If the file doesn't exist, an exception will be raised.) At this point, you can use the file instance to read from the file. A number of methods are at your disposal. The absolute simplest is the `read` method; it reads in the entire file as a single string:

```irb 
>> file.read
=> "class Ticket\n def initialized(venue, date)\n
          @venue - venue\n    @date = date\n  end\n\n etc.
```
Although using `read` is tempting in many situations and appropriate in some, it can be inefficient and a bit sledgehammer-like when you need more granularity in your data reading and processing.

We'll look here at a large selection of Ruby's file-reading methods, handling them in groups: first line-based read methods and hten byte-based read methods.

**Close your file handles** 
When you've finished reading and/or writing to a file, you need to close it. `File` objects have a `close` method (for example, `f.close`) for this purpose. You'll learn about a way to open files so that Ruby handles the file closing for you, by scoping the whole file operation to a code block. But if you're doing it the old-fashioned way, as in the examples involving `File.new` in this part of the chapter, you should close your files explicitly. (They'll get closed when you exit irb too, but it's good practice to close the ones you've opened.)

### *Line-based file reading* ###
The easiest way to read the next line from a file is with `gets`:

```irb
>> f.gets
=> "class Ticket\n
>> f.gets 
=> "  def initialize(venue, date)\n"
>> f.gets 
=> "    @venue = venue\n"
```
The `readline` method does much of what `gets` does: it reads one line from the file. The difference lies in how the two methods behave when you try to read beyond the end of a file: `gets` returns `nil`, and `readline` raises a fatal error. You can see the difference if you do a `read` on a `File` object to get to the end of the file and then try the two methods on the object:

```irb 
```

### *Byte- and character-based file reading* ### 

### *Seeking and querying file position* ###

### *Reading files with File class methods* ### 

**Low-level I/O methods** 

### *Writing to files* ###

### *Using blocks to scope file operations* ### 
Using `File.new` to create a `File` object has the disadvantage that you end up having toc lose the file yourself. Ruby provides an alternate way to open files that puts the housekeeping task of closing the file in the hands of Ruby: `File.open` with a code block.

If you call `File.open` with a code block, the block receives the `File` object as its single argument. You use that `File` object inside the block. When the block ends, the `File` object is automatically closed.

Here is an example in which a file is opened and read in line by line for processing. First, create a file called records.txt containing one word per line: 

```txt
Pablo Casals|Catalan|cello|1876-1973
Jascha Heifetz|Russian-American|violin|1901-1988
Emanuel Feuermann|Austrian-American|cello|1902-1942
```

Now write the code that will read the file, line by line, and report on what it finds. It uses the block-based version of `File.open`.

```ruby
File.open("records.txt") do |f|
  while record = f.gets 
  name, nationality, instrument, dates = record.chomp.split('|')
  puts "#{name} (#{dates}), who was #{nationality}, played #{instrument}."
  end
end
```
The program consists entirely of a call to `File.open` along with its code block. (If you call `File.open` without a block, it acts like `File.new.`) The block parameter, `f`, received the `File` object. Inside the block, the file is read one line at a time using `f`. The `while` test succeeds as long as lines are coming in from the file. When the program hits the end of the input file, `gets` returns `nil`, and the `while` condition fails.

Inside the `while` loop, the current line is chomped so as to remove the final newline character, if any, and split on the pipe character. The resulting values are stored in the four local variables on the left, and those variables are then interpolated into a pretty-looking report for output:

```irb 
Pablo Casals (1876-1973), who was Catalan, played cello.
Jascha Heifetz (1901-1988), who was Russian-American, played violin.
Emanuel Feuermann (1902-1942), who was Austrian-American, played cello.
```
The use of a code block to scope a `File.open` operation is commong. It sometimes leads to misunderstandings , though. In particular, remember that the block that provides you with the `File` object doesn't do anything else. There's no implicit loop. If you want to read what's in the file, you still have to do something like a `while` loop using the `File` object. It's just nice that you get to do it inside a code block and that you don't have to worry about closing the `File` object afterward.

And don't forget that `File` objects are enumerable. 

### *File enumerability* ###

### *File I/O exceptions and errors* ### 

## *Querying IO and File objects* ##

### *Getting information from the File class and the FileTest module* ###

**Getting file information with Kernel#test** 

### *Deriving file information with File::Stat* ### 

## *Directory manipulation with the Dir class* ##

### *Reading a directory's entries* ### 

#### THE ENTRIES METHODS #### 

#### DIRECTORY GLOBBING #### 

**NOTE** 

### *Directory manipulation and querying* ### 

## *File tools from the standard library* ##

### *The FileUtils module* ### 

#### COPYING, MOVING, AND DELETING FILES ####

#### THE DRYRUN AND NOWRITE MODULES #### 

### *The Pathname class* ### 

### *The StringIO class* ###

**Testing using real files**

### *The open-uri library* ###
