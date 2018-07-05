# *Callable and runnable objects* #

## *Basic anonymous functions: The Proc class* ## 

**NOTE** 

### *Proc objects* ###

**The proc method** 

### *Procs and blocks and how they differ* ### 

#### SYNTAX (BLOCKS) AND OBJECTS (PROCS) ####

### *Block-proc conversions* ### 

#### CAPTURING A CODE BLOCK AS A PROC* ####

#### USING PROCS FOR BLOCKS ####

#### GENERALIZING TO_PROC ####

### *Using Symbol#to_proc for conciseness* ### 

#### IMPLEMENTING SYMBOL#TO_PROC #### 

### *Procs as closures* ###

### *Proc parameters and arguments* ### 

## *Creating functions with lambda and ->* ## 

**WARNING** 

#### THE "STABBY LAMBDA" CONSTRUCTOR, -> #### 

## *Methods as objects* ## 

### *Capturing Method objects* ### 

### *The rationale for methods as objects* ### 

**Alternative techniques for calling callable objects** 

## *The eval family of methods* ## 

### *Executing arbitrary strings as code with eval* ### 

**The Binding class and eval-ing code with a binding** 

### *The dangers of eval* ### 

### *The instance_eval method* ### 

**The instance_exec method** 

### *Using class_eval(a.k.a. module_eval)* ### 

## *Parallel execution with threads* ## 

### *Killing, stopping, and starting threads* ### 

**Fibers: A twist on threads** 

### *A threaded date server* ### 

### *Writing a chat server using sockets and threads* ### 

### *Threads and variables* ### 

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
