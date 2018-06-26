## *File tools from the standard library* ##
File handling is an area where the standard library's offerings are particularly rich. Accordingly, we'll delve into those 
offerings more deeply here than anywhere else in the book. This isn't to say that the rest of the standard library isn't worth 
getting to know, but that hte extensions available for the file manipulation are so central to how most people do file manipulation 
in Ruby that you can't get a firm grounding in the process without them.

We'll look at the versatile `FileUtils` package first and then at the more specialized but useful `Pathname` class. Next you'll meet 
`StringIO`, a class whose objects are, essentially, strings with an I/O interface; you can `rewind` them, `seek` through them, `getc` 
from them, and so forth. Finally, we'll explore `open-uri`, a package that lets you "open" URIs and read them into strings as easily 
as if they were local files.

### *The FileUtils module* ### 
The `FileUtils` module provides some practical and convenient methods that make it easy to manipulate files from Ruby in a concise manner in ways that correspond to familiar system commands. The method's names will be particularly familiar to users of UNIX and UNIX-like operating systems. They can be easily learned by those who don't know them already.

Many of the methods in `FileUtils` are named in honor of system commands with particular command-line options. For example, `FileUtils.rm_rf` emulates the `rm -rf` command (force unconditional recursive removal of a file or directory). You can create a symbolic linke from *filename* to *linkname* with `FileUtils.ln_s(filename, linkname)`, as much in the manner of the `ln -s` command.

As you can see, some of the methods in `FileUtils` are operating-system specific. If your system doesn't support symbolic links, then `ln_s` won't work. But the majority of the module's methods are portable. We'll look here at examples of some of the most useful ones.

#### COPYING, MOVING, AND DELETING FILES ####
`FileUtil` provides several concise, high-level methods for these operations. The `cp` method emulates the traditional UNIX method of the same name. You can `cp` one file to another or several files to a directory:

```irb 
>> require 'fileutils'
=> true
>> FileUtils.cp("baker.rb", "baker.bak")
=> nil
>> FileUtils.mkdir("backup")                        #<------1.
=> ["backup"]
>> FileUtils.cp(["ensure.rb", "super.rb"], "backup"]
=> ["ensure.rb", "super.rb"]
>> Dir["backup/*"]                                  #<------2.
=> ["backup/ensure.rb", "backup/super.rb"]
```
This example also illustrates the `mkdir` method (#1), as well as the use of `Dir#[]` (#2) to verify the presence of the copied files in the new backup directory.

Just as you can copy files, you can also move them, individually, or severally:

```irb 
>> FileUtils.mv("backer.rb.back", "backup")
=> 0
>> Dir["backup/*"]
=> ["backup/baker.rb.bak", "backup/ensure.rb", "backup/super.rb"]
```
And you can remove files and directories easily:

```irb
>> File.exist?("backup.super.rb")
=> true
>> FileUtils.rm("./backup/super.rb")
=> ["./backup/super.rb"]
>> File.exist?("backup/super.rb")
=> false
```
The `rm_rf` method recursively and unconditionally removes a directory:

```irb 
>> FileUtils.rm_rf("backup")
=> ["backup"]
>> File.exist?("backup")
=> false
```
`FileUtils` gives you a useful toolkit for quick and easy file maintenance. But it goes further, it lets you try commands without executing them.

#### THE DRYRUN AND NOWRITE MODULES #### 
If you want to see what would happen if you were to run a particular `FileUtils` command, you can send the command to `FileUtils::DryRun`. The output of the method you call is a representation of a UNIX-style system command, equivalent to what you'd get if you called the same method on `FileUtils`:

```irb 
>> FileUtils::DryRun.rm_rf("backup")
rm -rf backup
=> nil
>> FileUtils::DryRun.ln_s("backup", "backup_link")
ln -s backup backup_link
=> nil
```
If you want to make sure you don't accidentally delete, overwrite, or move files, you can give your commands to `FileUtils::NoWrite`, which has the same interface as `FileUtils` but doesn't perform any disk-writing operations:

```irb 
>> FileUtils::NoWrite.rm("backup/super.rb")
=> nil
>> File.exist?("backup/super.rb")
=> false
```
You'll almost certainly find `FileUtils` useful in many situations. Even if you're not familiar wtih the UNIX-style commands on which many of `FileUtils`'s method names are based, you'll learn them quickly, and it will save you having to dig deeper into the lower-level I/O and file libraries to get your tasks done.

Next we'll look at another file-related offering form the standard library: the pathname extension.

### *The Pathname class* ### 
The `Pathname` class lets you create `Pathname` objects and query and manipulate them so you can determine, for example, the basename and extension of a pathname, or iterate through the path as it ascends the directory structure.

`Pathnam` objects also have a large number of methods that are proxied from `File`, `Dir`, and `IO`, and other classes. We won't look at those methods here; we'll stick to the ones that are uniquely `Pathname`'s. 

First, start with a `Pathname` object:

```irb 
>> require 'pathname'
=> true
>> path = Pathname.new("/Users/dblack/hacking/test1.rb")
=> #<Pathname:/Users/dblack/hacking/test1.rb>
```
When you call methods on a `Pathname` object, you often get back another `Pathname` object. But the new object always has its string representation visible in its own `inspect` string. If you want to see the string on its own, you can use `to_s` or do a `puts` on teh pathname. 

Here are two ways to examine the basename of the path:

```irb 
>> path.basename
=> #<Pathname:test1.rb>
>> puts path.basename
test1.rb
=> nil
```
You can also examine the directory that contains the file or directory represented by the pathname:

```irb 
>> path.dirname
=> #<Pathname:/Users/dblack/hacking>
```
If the last segment of the path has an extension, you can get the extension from the `Pathname` object:

```irb 
>> path.extname
=> ".rb"
```
The `Pathname` object can also walk up its file and directory structure, truncating itself from the right on each iteration, using the `ascend` method and a code block:

```irb
>> path.ascend do |dir|
>>    puts "Next level up: #{dir}"
>> end
```
Here's the output:

```irb
Next level up: /Users/dblack/hacking/test1.rb
Next level up: /Users/dblack/hacking
Next level up: /Users/dblack
Next level up: /Users
Next level up: /
=> nil
```
The key behavioral trait of `Pathname` objects is that they return other `Pathname` objects. That means you can extend the logic of your pathname operations without having to convert back and forth from pure strings. By way of illustration, here's the last example again, but altered to take advantage of the fact that what's coming through in the block parameter `dir` on each iteration isn't a string (even though it prints out like one) but a `Pathname` object:

```irb 
>> path = Pathname.new("/Users/dblack/hacking/test1.rb")
=> #<Pathname:/Users/dblack/hacking/test1.rb>
>> path.ascend do |dir|
>>    puts "Ascended to #{dir.basename}"
>> end
```
The output is:

```irb 
Ascended to test1.rb
Ascended to hacking
Ascended to dblack
Ascended to Users
Ascended to /
=> nil
```
The fact that `dir` is always a `Pathname` object means that it's possible to call the `basename` method on it. It's true that you can always call `File.basename(string)` on any string. But the `Pathname` class pinpoints the particular knowledge that a path might be assumed to encapsulate about itself and makes it available to you via simple method calls.

We'll look next at a different and powerful standard library class: `StringIO`.

### *The StringIO class* ###
The `StringIO` class allows you to treat strings like `IO` objects. You can seek through them, rewind them, and so forth.

The advantage conferred by `StringIO` is that you can write methods that use an `IO` object API, and those methods will be able to handle strings. That can be useful for testing, as well as in a number of real runtime situations.

Let's say, for example, that you have a module that decomments a file: it reads from one file and writes everything that isn't a comment to another file. Here's what such a module might look like:

```ruby
module DeCommenter
  def self.decomment(infile, outfile, comment_re = /\A\s*#/)
    infile.each do |inline|
      outfile.print inline unless inline =~ comment_re
    end
  end
end
```
The `Decommenter.decomment` method expects two open file handles: one it can read from and one it can write to. It also takes a regular expression, which has a default value. That regular expression determines whether each line in the input is a comment. Every line that does *not* match the regular expression is printed to the output file.

A typical use case for the `DeCommenter` module would look like this:

```ruby
File.open("myprogram.rb") do |inf| 
  File.open("myprogram.rb.out", "w") do |outf|
    Decommenter.decomment(inf, outf)
  end 
end 
```
In this example, we're taking the comments out of the hypothetical program file myprogram.rb 

What if you want to write a test for the `DeCommenter` module? Testing file transformations can be difficult because you need to maintain the input file as part of the test and also make sure you can write to the output file-which you then have to read back in. `StringIO` makes it easier by allowing all of the code to stay in one place without the need to read or write actual files.

**Testing using real files**
If you want to run tests on file input and output using real files, Ruby's `tempfile` class can help you. It's a standard-library feature, so you have to `require 'tempfile'`. Then, you create temporary files with the constructor, passing in a name that Ruby munges into a unique filename. For example:

`cf = Tempfile.new("my_temp_file")`

You can then write to and read from the file using the `File` object `tf`.

--- 

To use the decommenter with `StringIO`, save the module to decommenter.rb. Then, create a second file, decomment-demo.rb, in the same directory with the following contents:

```ruby
require 'stringio'                                  
require_relative 'decommenter'                    #<----1.
string = << EOM
# This is a comment.  
This isnt a comment.                                   #<----2.
# This is.
  # So is this.
This is also not a comment.
EOM
infile = StringIO.new(string)                               #<----3.
outfile = StringIO.new("")                                   
DeCommenter.decomment(infile, outfile)                          #<----4.
puts "Test succeed" if outfile.string == << EOM                      #<----5.
This isnt a comment.
This is also not a comment
EOM
```
After loading both the `stringio` library and the decommenter code (#1), the program sets `string` to a five-line string (created using a here-document) containing a mix of comment lines and non-comment lines (#2). Next, two `StringIO` objects are created: one that uses the contents of `string` as its contents, and one that's empty (#3). The empty one represents the output file.

Next comes the call to `DeCommenter.decomment` (#4). The module treats its two arguments as `File` or `IO` objects, reading from one and printing to the other. `StringIO` objects happily behave like `IO` objects, and the filtering takes place between them. When the filtering is done, you can check explicitly to make sure that what was written to the output "file" is what you expected (#5). The original and changed contents are both physically present in the same file, which makes it easier to see what the test  is doing and also easier to change it.

Another useful standard library feature is the `open-uri` library.

### *The open-uri library* ###
The `open-uri` standard library package lets you retrieve information from the network using the HTTP and HTTPS protocols as easily as if you were reading local files. All you do is require the library (`require 'open-uri'`) and use the `Kernel#open` method with a URI as the argument. You get back a `StringIO` object containing the results of your request:

```ruby
require 'open-uri'
rubypage = open("http://rubycentral.org")
puts rubypage.gets
```
You get the `doctype` declaration from Ruby Central homepage-not the most scintillating reading, but it demonstrates the ease with which `open-uri` lets you import networked materials. 
