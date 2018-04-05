## *What you can't do in argument lists* ##

Parameters have a pecking order. REquired ones get priority, whether they occur at the left or at the right of the list. All the optional ones have to occur in the middle. The middle may be the middle of nothing:

`def all_optional(*args)` *<--Zero left, or right-sided required arguments*

And you can have required arguments on the left only, or on the right only - or both.

What you can't do is put the argument sponge to the left of any default-valued arguments. If you do this,

```
  def broken_args(x,*y,z=1)
   end
  ```

it's a syntax error, because there's no way it could be correct. Once you've given x its argument and sponged up all the remaining arguments in the array y, nothing can ever be left for z. And if z gets the right-handed argument, leaving the rest for y, it makes no sense to describe z as "optional" or "default-valued." The situation gets even thornier if you try to do something like the equally illegal
`(x, *y, z=1, a, b)`. Fortunately, Ruby doesn't allow for more than one sponge argument in a parameter list. Make-sure you order your arguments sensibly, and hwen possible, keep your argument lists reasonably simple.

### Table 2.2 Sample method signatures with required, optional, and default-valued arguments ###

|    Argument type(s)|   Method Signature    |   Sample Call(s)   |       Variable assignments     |
|--------------------|-----------------------|--------------------|--------------------------------|
| Required (R)       | `def m(a,b,c)`        | `m(1,2,3)`         | `a = 1, b = 2, c = 3`          |
| Optional (O)       | `def m(*a)`           | `m(1,2,3)`         | `a = [1, 2 ,3]`                |
| Default-valued (D) | `def m(a=1)`          |  `m`               | `a = 1`                        |
|                    |                       | `m(2)`             | `a = 2`                        |
| R/O                | `def m(a, *b)`        | `m(1)`             | `a = 1, b = []`                |
| R/D                | `def m(a, b=1)`       | `m(2)`             | `a = 2, b = 1`                 |
|                    |                       | `m(2,3)`           | `a = 2, b = 3`                 |
| D/O                | `def m(a=1, *b)`      | `m`                | `a = 1, b = []`                |
|                    |                       | `m(2)`             | `a = 2, b = []`                |
| R/D/O              | `def m(a,b=2, *c)`    | `m(1)`             | `a = 1, b = 2, c = []`         |
|                    |                       | `m(1,3)`           | `a = 1, b = 3, c = []`         |
|                    |                       | `m(1,3,5,7)`       | `a = 1, b = 3, c = [5,7]`      |
| R/D/O/R            | `def m(a,b=2,*c,d)`   | `m(1,3)`           | `a = 1, b = 2, c = [], d = 3`  |
|                    |                       |`m(1,3,5)`          |`a = 1, b = 3, c =[], d = 5`    |
|                    |                       | `m(1,3,5,7)`       |`a = 1, b = 3, c = [5], d = 7`  |
|                    |                       |`m(1,3,5,7,9)`      |`a = 1, b = 3, c = [5,7], d = 9`|

The arguments you send to methods are assigned to variables - specifically, local variables, visible and usable for the duration of the method. Assignment of local variables through method argument binding is just one case of the general process of local variable assigment.
