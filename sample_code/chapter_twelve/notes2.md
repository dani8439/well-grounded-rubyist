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
