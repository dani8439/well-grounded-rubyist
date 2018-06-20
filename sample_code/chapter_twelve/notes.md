# *File and I/O operations* #

## *How Ruby's I/O system is put together* ## 

### *The IO class* ### 

### *IO objects as enumerables* ###

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
