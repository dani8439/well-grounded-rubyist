### *File enumerability* ###
Thanks to the fact that `Enumerable` is among the ancestors of `File`, you can replace the `while` idiom in the previous example with `each`:

```ruby
File.open("records.txt") do |f|
  f.each do |record|
    name, nationality, instrument, dates = record.chomp.split('|')
    puts "#{name} (#{dates}), who was #{nationality}, played #{instrument}."
  end
end
```
Ruby gracefully stops iterating when it hits the end of the file. 

As enumerables, `File` objects can perform many of the same functions that arrays, hashes, and other collections do. Understanding how file enumeration works requires a slightly different mental model: whereas an array exists already and walks through its elements in the course of iteration, `File` objects have to manage line-by-line reading behind the scenes when you iterate through them. But the similarity of the idioms-the common use of the methods from `Enumerable`-means you don't have to think in much detail about hte file-reading process when you iterate through a file. 

Most important, don't forget that you can iterate through files and address them as enumerables. It's tempting to read a whole file into an array and then process the array. But why not just iterate on the file and avoid wasting the space required to hold the file's contents in memory?

You could, for example, read in an entire file of plain-text records and then perform an inject oepration on the resulting array to get the average of a particular field:

```ruby
# Sample record in members.txt:
# David Black male 55
count = 0
total_ages = File.readlines("members.txt").inject(0) do |total,line|
  count += 1 
  fields = lines.split 
  age = fields[3].to_i
  total + age 
end
puts "Average age of group: #{total_ages / count}."
```
But you can also perform the inject oepration directly on the `File` object:

```ruby
count = 0
total_ages = File.open("members.txt") do |f|
  f.inject(0) do |total,line|
    
    count += 1
    fields = line.split
    age = fields[3].to_i
    total + age
  end
end
```
With this approach, no intermediate array is created. The `File` object does its own work.

One way or another, you'll definitely run into cases where something goes wrong with your file operations. Ruby will leave you in no doubt that there's a problem, but it's helpful to see in avance what some of the possible problems are and how they're reported.

### *File I/O exceptions and errors* ### 
When something goes wrong with file operations, Ruby raises an exception. Most of the errors you'll get in the course of working with files can be found in `Errno` namespace: `Errno:EACCES` (permission denied), `Errno:ENOENT` (no such entity-a file or directory), `Errno:EISDIR` (is a directory-an error you get when you try to open a directory as if it were a file), and others. You'll always get a message along with the exception:

```irb
>> File.open("no_file_with_this_name")
Errno::ENOENT: No such file or directory @ rb_sysopen - no_file_with_this_name
        from (irb):1:in `initialize'
        from (irb):1:in `open'
        from (irb):1
        from /usr/local/rvm/rubies/ruby-2.3.1/bin/irb:11:in `<main>'
>> f = File.open("/tmp")
=> #<File:/tmp>
>> f.gets
Errno::EISDIR: Is a directory @ io_fillbuf - fd:10 /tmp
        from (irb):3:in `gets'
        from (irb):3
        from /usr/local/rvm/rubies/ruby-2.3.1/bin/irb:11:in `<main>'
>> File.open("/var/root")
Errno::EACCES: Permission denied - /var/root
```
The `Errno` family of errors includes not only file-related errors but also other system errors. The underlying system typically maps errors to integers (for example, on Linux, the "not a directory" error is represented by the C macro `ENTODIR`, which is defined as the number 20). Ruby's `Errno` class wraps these error-to-number mappings in a bundle of exception classes. 

Each `Errno` class contains knowledge of the integer to which its corresponding system error maps. You can get these numbers via the `Errno` constant of each `Errno` class-and if that sounds obscure, an example will make it clearer:

```irb
>> Errno::ENOTDIR::Errno
=> 20
```
You'll rarely, if ever, have to concern yourself with the mapping of Ruby's `Errno` exception classes to the integers to which your operating system maps errors. But you should be aware that any `Errno` exception is basically a system error percolating up through Ruby. These aren't Ruby specific errors, like syntax errors or missing method errors; they involve things going wrong at the system level. In these situations, Ruby is just the messanger.

Let's go back to what you can do when things go right. We'll look next at some ways in which you can ask `IO` and `File` objects for information about themselves and their state.

## *Querying IO and File objects* ##
`IO` and `File` objects can be queried on numerous criteria. The `IO` class includes some wuery methods; the `File` class adds more. 

One class and one module closely related to `File` also get into the act: `File::Stat` and `FileTest`. `File::Stat` returns objects whose attributes correspond to the fields of the stat structure defined by the C library call `stat(2)`. Some of these fields are system specific and not meaningful on all platforms. The `FileTest` module offers numerous methods for getting status information about files.

The `File` class also has some query methods. In some cases, you can get the same information about a file several ways:

```irb 
>> File.size("code/ticket2.rb")
=> 219
>> FileTest.size("code/ticket2.rb")
=> 2019
>> File::Stat.new("code/ticket2.rb").size 
=> 219
```
In what follows, we'll look at a large selection of query methods. In some cases, they're available in more than one way.

### *Getting information from the File class and the FileTest module* ###
`File` and `FileTest` offer numerous query methods that can give you lost of information about a file. These are the main categories of query: *What is it? What can it do? How big is it?*

The methods available as class methods of `File` and `FileTest` are almost identical; they're mostly aliases of each other. The examples will only use `FileTest`, but you can use `File` too. 

Here are some questions you might want to ask about a given file, along with the techniques for asking them. All of these methods return either true or false except `size`, which returns an integer. Keep in mind that these file-testing methods are happy to take directories, links, and other filelike entities as their arguments. They're not restricted to regular files:

• *Does a file exist?* 

`FileTest.exist?("/usr/local/src/ruby/README")`

• *Is the file a directory? A regular file? A symbolic link? 

```irb 
File.test.directory?("/home/users/dblack/info")
FileTest.file?("/home/users/dblack/info")
FileTest.symlink?("/home/users/dblack/info")
```
This family of query methods also includes `blockdev?`, `pipe?`, `chardev?`, and `socket?`. 

• *Is a file readable? Writable? Executable?

```irb 
FileTest.readable?("/tmp")
FileTest.writable?("/tmp")
FileTest.executable?("/home/users/dblack/setup")
```
This family of query methods includes `world_readable?` and `world_writable?`, which test for more permissive permissions. It also includes variants of the basic three methods with `_real` appended. These test the permissions of the scrip's actual runtime ID as opposed to its effective user ID. 

• *What is the size of this file? Is the file empty (zero bytes)?* 

```irb 
FileTest.size("/home/users/dblack/setup")
FileTest.zero?("/tmp/tempfile")
```

**Getting file information with Kernel#test** 
Among the top-level methods at your disposal (that is, private methods of the `Kernel` module, which you can call anywhere without a receiver, like `puts`) is a method called `test`. You use `test` by passing it two arguments; the first represents the test, and the second is a file or directory. The choice of test is indicated by a character. Yuo can represent the value using the `?c` notation, where `c` is the character, or as a one-character string. 

Here's an example that finds out whether `/tmp` exists:

`test ?e, "/tmp"`

Other common test characters include `?d` (the test is true if the second argument is a directory), `?f` (true of the second argument is a regular file), and `?z` (true if the second argument is a zero-length file). For every test available through `Kernel#test`, there's usually a way to get the result by calling a method of one of the classes discussed in this section. But `Kernel#test` notation is shorter and can be handy for that reason.

---

In addition to the query and Boolean methods available through `FileTest` (and `File`), you can also consult objects of the `File::Stat` class for file information.

### *Deriving file information with File::Stat* ### 
`File::Stat` objects have attributes corresponding to the stat structure in the standard C library. You can create a `File::Stat` object in either of two ways: with the `new` method or with the `stat` method on an existing `File` object:

```irb 
>> File::Stat.new("code/ticket2.rb")
=> #<File::Stat dev=0x1000002, ino=11531534, mode=0100644, nlink=1, uid=501, gid=20, rdev=0x0, size=219, blksize=4096, blocks=8, atime=2014-03-23 08:31:49 -0400, mtime=2014-02-25 06:24:43 -0500, ctime=2014-02-25 06:24:43 -0500>
>> File.open("code/ticket2.rb") {|f| f.stat } #<--- Same output
```
The screen output from the `File::Stat.new` method shows you the attributes of the object, including its times of creating (`ctime`), last modification (`mtime`), and last access (`atime`). 

**TIP** The code block given to `File.open` in the example, `{|f| f.stat }`, evaluates to the last expression inside it. Because the last (indeed, only) expression is `f.stat`, the value of the block is a `File::Stat` object. In general, when you use `File.open` with a code block, the call to `File.open` returns the last value from the block. Called without a block, `File.open` (like `File.new`) returns the newly created `File` object. 

--
Much of the information available from `File::Stat` is built off of UNIX-like metrics, such as inode number, access mode (permissions), and user and group ID. The relevance of this information depends upon your operating system. We won't go into details here because it's not cross-platform; but whatever information your system maintains about files is available if you need it.

Manipulating and querying files often involves doing likewise to directories. Ruby provides facilities for directory operations in the `Dir` class. You'll also see such operation in some of the standard library tools we'll discuss a little later. First let's look at `Dir`.

## *Directory manipulation with the Dir class* ##
Like `File`, the `Dir` class provides useful class and instance methods. To create a `Dir` instance, you pass a directory path to `new`:

```irb 
>> d = Dir.new("/usr/local/src/ruby/lib/minitest")      #<---Adjust path as needed for your system.
=> #<Dir:/usr/local/src/ruby/lib/minitest> 
```
The most common and useful `Dir`-related technique is iteration through the entires (files, links, other directories) in a directory.

### *Reading a directory's entries* ### 
You can get hold of the entries in one of two ways: using the `entries` method or using the `glob` technique. The main difference is that *globbing* the directory doesn't return hidden entires, which on many operating systems (including all UNIX-like systems) means entires whose names start with a period. Globbing also allows for wildcard matching and for recursive matching in subdirectories. 

#### THE ENTRIES METHODS #### 
Both the `Dir` class itself and instances of the `Dir` class can give you a directory's entires. Given the instance of `Dir` created earlier, you can do this:

```irb 
>> d.entries
=> [".", "..", ".document", "autorun.rb", "benchmark.rb", "hell.rb", "mock.rb", "parallel_each.rb", "pride.rb", "README.txt", "spec.rb", "unit.rb"]
```
Or you can use the class-method approach:

```irb 
>> Dir.entries("/usr/local/src/ruby/lib/minitest") 
=> [".", "..", ".document", "autorun.rb", "benchmark.rb", "hell.rb", "mock.rb", "parallel_each.rb", "pride.rb", "README.txt", "spec.rb", "unit.rb"]
>> Dir.entries("/home/dani8439/temporary")
=> ["..", "sandbox", "."]
```
Note that the single- and double-dot entries (current directory and parent directory, respectively) are present, as is the hidden `.document` entry. If you want to iterate through the entries, only processing files, you need to make sure you filter out the names starting with dots.

Let's say we want to add up the sizes of all non-hidden regular files in a directory. Here's a first iteration (we'll develop a shorter one later):

```irb
>> d = Dir.new("/home/dani8439/temporary")
=> #<Dir:/home/dani8439/temporary>
>> entries = d.entries
=> ["..", "sandbox", "."]
>> entries.delete_if {|entry| entry =~ /*\./ }
SyntaxError: (irb):4: target of repeat operator is not specified: /*\./
        from /usr/local/rvm/rubies/ruby-2.3.1/bin/irb:11:in `<main>'
>> entries.map! {|entry| File.join(d.path, entry) }
=> ["/home/dani8439/temporary/..", "/home/dani8439/temporary/sandbox", "/home/dani8439/temporary/."]
>> entries.delete_if {|entry| !File.file?(entry) }
=> ["/home/dani8439/temporary/sandbox"]
>> print "Total bytes: "
Total bytes: => nil
>> puts entries.inject(0) {|total, entry| total + File.size(entry) }
403
=> nil
```
First, we create a `Dir` object for the target directory and grab its entries. NExt comes a sequence of manipulations on the array of entries. Using the `delete_if` array method, we remove all that begin with a dot. Then, we do an in-place mapping of the entry array so that each entry includes the full path to the file. This is accomplished wtih two useful methods: the instance method `Dir#path`, which returns the original directory path underlying this particular `Dir` instance (/home/dani8439/temporary); and `File.join` which joins the path to the filename with the correct separator (usually/, but it's somewhat system-dependent).

Now that the entries have been massaged to represent full pathnames, we do another `delete_if` operation to delete all entries that aren't regular files, as measured by the `File.file?` test method. The entries array now contains full pathnames of all the regular files in the original directory. THe last step is to add up their sizes, a task for which `inject` is perfectly suited.

Among other ways to shorten this code, you can use directory globbing instead of the `entries` method. 

#### DIRECTORY GLOBBING #### 
Globbing in Ruby takes its semantics largely from shell globbing, the syntax that lets you do things like this in the shell:

```irb 
$ ls * .rb
$ rm *.?xt
$ for f in [A-Z]*   #etc
```
The details differ from one shell to another, of course; but the point is that this whole family of name-expansion techniques is where Ruby gets its globbing syntax. An asterisk represents a wildcard match on any number of characters; a question mark represents one wildcard character. Regexp-style character classes are available for matching. 

To glob a directory you can use the `Dir.glob` method on `Dir.[]` (square brackets). The square-bracket version of the method allows you to use index-style syntax as you would with the square-bracket method on an array or hash. You get back an array containing the result set:

```irb
>> Dir["/usr/local/src/ruby/onclude/ruby/r*.h"]
=> ["/usr/local/src/ruby/include/ruby/re.h", "/usr/local/src/ruby/include/ruby/regex.h", "/usr/local/src/ruby/include/ruby/ruby.h"]
```
The `glob` method is largely equivalent to the [] method but a little more versatile: you can give it not only a glob pattern but also one or more flag arguments that control its behavior. For example, if you want to do a case-insensitive glob, you can pass the `File::FNM_CASEFOLD` flag:

```irb
Dir.glob("info*")     #[]
Dir.glob("info", File::FNM_CASEFOLD     #["Info", "INFORMATION"]
```
Another useful flag is `FNM_DONMATCH`, which includes hidden dot files in the results.

If you want to use two flags, you combine them with the bitwise OR operator, which consists of a single pipe character. In this example, progressively more files are found as the more permissive flags are added:

```irb 
>> Dir.glob("*info*")
=> []
>> Dir.glob("*info*", File::FNM_DOTMATCH)
=> [".information:]
>> Dir.glob("*info*", File::FNM_DOTMATCH | File::FNM_CASEFOLD)
=> [".information", ".INFO", "Info"]
```
The flags are, literally, numbers. The value of `File_FNM_DOTMATCH`, for example, is 4. The specific numbers don't matter (they derive ultimately from the flags in the systen library function `fnmatch`). What does matter is the fact that they're exponents of two accounts for the use of the OR operation to combine them. 

**NOTE** As you can see from teh first two lines of the previous example, a `glob` operation on a directory can find nothing and still not complain. If gives you an empty array. Not finding anything isn't considered a failure when you're globbing.

--

Globbing with square brackets is the same as globbing without providing any flags. In other words, doing this:

`Dir["*info*"]`

is like doing this

`Dir.glob["*info*", 0]` 

which, because the default is that none of the flags is in effect, is like doing this:

`Dir.glob("*info*")`

The square-bracket method of `Dir` gives you a kind of shorthand for the most common case. If you need more granularity, use `Dir.glob`.

By default, globbing doesn't include filenames that start with dots. Also, as you can see, globbing returns full pathnames, not just filenames. Together, these facts let us trim down the file-size totaling example:

```irb 
dir = "/usr/local/src/ruby/lib/minitest"
entries = Dir["#{dir}/*"].select {|entry| File.file?(entry) }
print "Total bytes: "
puts entries.inject(0) {|total, entry| total + File.size(entry) }
```
With their exclusion of dot files and their inclusion of full paths, glob results often correspond more closely than `Dir.entries` results to the ways that many of us deal with files and directories on a day-to-day basis.

There's more to directory management than just seeing what's there. We'll look next at some techniques that let you go more deeply into the process. 

### *Directory manipulation and querying* ### 
The `Dir` class includes several query methods for getting information about a directory or about the current directory, as well as methods for creating and removing directories. These methods are, like so many, best illustrated by example.

Here, we'll create a new directory (`mkdir`), navigate to it (`chdir`), add and examine a file, and delete the directory (`rmdir`):

```irb 
>> newdir = "/temporary/newdir"           #<---- 1.
=> "/temporary/newdir"
>> newfile = "newfile"
=> "newfile"
>> Dir.mkdir(newdir)
>> Dir.chdir(newdir) do                       #<---- 2.
>>  File.open(newfile, "w") do |f|
>>    f.puts "Sample file in new directory"        #<---- 3.
>>  end
>>  puts "Current directory: #{Dir.pwd}"                #<---- 4.
>>  puts "Directory listing: "
>>  p Dir.entries(".")
>>  File.unlink(newfile)                            #<---- 5.
>> end
>> Dir.rmdir(newdir)                           #<---- 6.
>> print "Does #{newdir} still exist?"
Does /temporary/newdir still exist?=> nil
>> if File.exist?(newdir)                 #<---- 7.
>>  puts "Yes"
>> else
>>  puts "No"
>> end
No
```
After initializing a couple of convenience variables (#1), we create the new directory with `mkdir`. With `Dir.chdir`, we change to that direcory; also, using a block with `chdir` means that after the block exits, we're back in the previous directory (#2). (Using `chdir` without a block changes the current directory until it's explicitly changed back.)

As a kind of token directory-populating step, we create a single file iwth a single line in it (#3). We then examine the current directory name using `Dir.pwd` and look at a listing of the entries in the directory (#4). Next, we unlink (delete) the recently created file (#5), at which point the `chdir` block is finished.

Back in whatever directory we started in, we remove the sample directory using `Dir.rmdir` (also callable as `unlink` or `delete`) (#6). Finally, we test for the existence of `newdir`, fully expecting an answer of `No` (because `rmdir` would have raised a fatal error if it hadn't found the directory and successfully removed it) (#7).

As promised in the introduction to the chapter, we'll now look at some standard library facilities for manipulating and handling files.

## *File tools from the standard library* ##


### *The FileUtils module* ### 


#### COPYING, MOVING, AND DELETING FILES ####


#### THE DRYRUN AND NOWRITE MODULES #### 


### *The Pathname class* ### 


### *The StringIO class* ###


**Testing using real files**


### *The open-uri library* ###
