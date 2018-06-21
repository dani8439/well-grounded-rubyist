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

`IO` is a RUby class, and as a class it's entitled to mix in modules. And so it does. In particular, `IO` objects are enumerable.

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

#### THE STANDARD I/O GLOBAL VARIABLES #### 

### *A litte more about keyboard input* ###

## *Basic file operations* ## 

### *The basics of reading from files* ###

**Close your file handles** 

### *Line-based file reading* ###

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
