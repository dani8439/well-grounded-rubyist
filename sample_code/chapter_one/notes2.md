# *Anatomy of the Ruby Installation* # 
Having Ruby installed on your system means havingseveral disk directories' worth of Ruby-language libraries and support files. Most of the time, Ruby knows how to find what it needs without being prompted. But knowing your way around teh RUby installation is part of a good Ruby grounding. 

**Looking at the Ruby source code**
In addition to the Ruby installation directory tree, you may also have the Ruby source code tree on your machine; if not, you can download it from the Ruby homepage. 

# **_Interpreter Command Line-Switches_** #

#### Table 1.6 Summary of Commonly used Ruby command-line switches
|    Switch       |        Description                       |         Example                  |
|-----------------|------------------------------------------|----------------------------------|
| `-c`            |     Check the syntax of a program without|      `ruby -c c2f.rb`            |
|                 |    executing the program                 |                                  |
| `-w`            |     Give warning messages during program |       `ruby -w c2f.rb`             |
|                 |     execution                            |                                  |
| `-e`              |   Execute the code provided in quotation |     `ruby -e 'puts "Code Demo!"'`  |
|                 |     marks on the command line            |                                  |
| `-l`              |   Line mode: print a newline after every |    `ruby -le 'print "+ newline!"'` |
|                 |     line of output                       |                                  |
| `-rname`          |      Require the named feature           |       `ruby -rprofile`             |
| `-v`              | Show Ruby version information and execute|    `ruby -v`                       |
|                 |     the program in verbose mode          |                                  |
| `--version`       |      Show Ruby version information       |           `ruby --version`         |
| `-h`              |  Show information about all command-line |    `ruby -h`                       |
|                 |     switches for the interpreter         |                                  |

## Examples: ##


### **Check Syntax(-C)** ###

The `c` switch tells Ruby to check the code in one or more files for syntactical accuracy without executing the code. It's usually used in conjunction with the `-w` flag.

### **Turn On Warnings(-W)** ###
`-w` causes the interpreter to run in warning mode. This means you see more warnings printed to the screen than you otherwise would, drawing your attention to places in your program that, although not syntax errors, are stylistically or logically suspect. It's Ruby's way of saying, "What you've done is syntactically correct, but it's weird. Are you sure you mean to do that?" Even without this switch, Ruby issues certain warnings, but fewer than it does in full warning mode.

### **Execute Literal Scripts(-E)** ###
The  `-e` switch tells the interpreter that the command line includes Ruby code in quotation marks, and that it should execute that actual code rather than execute the code contained in a file. Can be handy for quick scripting jobs.

`ruby -e 'puts "David A. Black".reverse'`

What lies inside the single quotation marks is an entire (although short) Ruby program.
If you want to feed a program with more than one line to the -e switch, you can use literal line
breaks (press Enter) inside the mini program:

`ruby -e 'print "Enter a name: "`
`puts gets.reverse'`

`kcalB .A divaD`

Or you can separate the lines with semicolons:
`ruby -e 'print "Enter a name: "; print gets.reverse'`

**Note** There is a blank line between the program code and the output in the two-line `reverse` example because
the line you enter on the keyboard ends with a new line character, so when you reverse the input, the new string
starts with a newline!

### **Run In Line Mode(-L)** ###
The `-l` switch produces the effect that every string output by the program is placed on a line of its own, even if it normally wouldn't be. Usually this means that lines are output using `print`, rather than `puts`, and that therefore don't automatically end with a newline character, now end with a newline.

We made use of the `print` vs `puts` distinction to ensure that the temperature converter programs didn't insert extra newlines in the middle of their output. You can use the `-l` switch to reverse the effect; it causes even `printed` lines to appear on a line of their own. Here's the difference:

```
$ ruby c2f-2.rb
The result is 212

$ ruby -l c2f-2.rb
The result is
212
.
```

The result with `-l` is, in this case, exactly what you don't want. But the example illustrates the effect of the switch.
*If a line ends with a newline character already running it through `-l` adds another newline.* In general, the `-l` switch isn't commonly used or seen, largely because of the availability of `puts` to achieve the "add a newline only if needed" behavior, but it's good to know `-l` is there and be able to recognize it.

### **Require Named File or Extension (-RNAME)** ###
The `-r` switch calls `require` on its argument; `ruby -rscanf` will require `scanf` when the interpreter starts up. You can put more than one `-r` switch on a single command line.

`>> "David Black".scanf("%s%s")`

`["David", "Black"]`

`.scanf` is asking for two consecutive strings to be extracted from the original string, with whitespace as an implied separator.

### **Run in Verbose Mode (-V, --VERBOSE)** ###
Running with `-v` does two things: it prints out information about the version of Ruby you're using, and then it turns on the same warning mechanism as the `-w` flag. The most common use of the `-v` is to find out the Ruby version number:

```
$ ruby -v
ruby 2.1.0p0 (2013-12-25 revision 444422) [x86_64-darwin12.0]
```

In this case, we're using Ruby 2.1.0 (patchlevel 0), released on December 25, 2013, and compiled for an i686-based machine running Mac OS X. Because there's no program or code to run, Ruby exits as soon as it has printed the version information.

### **Print Ruby Version(--VERSION)** ###
This flag causes Ruby to print a version information string and then exit. It doesn't execute any code, even if you provide code or a filename. You'll recall that `-v` prints version information and then runs your code (if any) in verbose mode. You might say that `-v` is slyly standing for both *version* and *verbose*, whereas `--version` is just *version*.

### **Print Some Help Information(-H, --HELP)** ###
These switches give you a table listing all the command-line switches available to you, and summarizing what they do.

In addition to using single switches, you can also combine two or more in a single invocation of Ruby.

### **Combining Switches (-CW)** ###
You've already seen the `-cw` combination, which checks the syntax of the file without executing it, while also giving you warnings:

`$ ruby -cw filename`

Another combination of switches you'll often see is `-v` and `-e`, which shows you the version of Ruby you're running and then runs the code provided in quotation marks. You'll see this combination a lot in discussions of Ruby, on mailing lists, and elsewhere; people use it to demonstrate how the same code might work differently in different versions of Ruby. For example, if you want to show clearly that a string method called `start_with?` wasn't present in Ruby 1.8.6 but is present in Ruby 2.1.0, you can run a sample program using first one version of Ruby and then the other:

```
$ ruby-1.8.6-p399 -ve "puts 'abc'.start_with?('a')"
ruby 1.8.6 (2010-02-05 patchlevel 399) [x86_64-linux]
-e:1: undefined method 'start_with?' for "abc":String (NoMethodError)
$ ruby-2.1.0p0 -ve "puts 'abc'.start_with?('a')"
ruby 2.1.0p0 (2013-12-25 revision 44422) [x86_64-linux]
true
```

The `undefined method 'start_with?'` message on the first run means that you've tried to perform a nonesitent named operation. But when you run the same Ruby snipped using Ruby 2.1.0 it works. Ruby prints `true`. This is a convenient way to share information and formulate questions about changes in Ruby's behavior from one release to another.

## **Specifying Switches** ##
You can feed Ruby the switches separately, like this:

`$ ruby -c -w`

Or

`ruby -v -e "puts 'abc'.start_with?('a')" `

But it's common to type them together, as in the examples in the main text.
