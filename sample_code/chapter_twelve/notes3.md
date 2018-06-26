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


**Testing using real files**


### *The open-uri library* ###
