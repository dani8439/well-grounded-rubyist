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


#### COPYING, MOVING, AND DELETING FILES ####


#### THE DRYRUN AND NOWRITE MODULES #### 


### *The Pathname class* ### 


### *The StringIO class* ###


**Testing using real files**


### *The open-uri library* ###
