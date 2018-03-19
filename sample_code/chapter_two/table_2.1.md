## **The Return Value of a Method** ##

### Examples of Ruby Expressions and the values to which they evaluate ###
|      Expression     |         Value          |                     Comments                       |
|---------------------|------------------------|----------------------------------------------------|  
|`2+2`                | `4`                    | Arithmetic expression evaluate to their results.   |
|`"Hello"`            | `"Hello"`              | A simple, literal string (in quotation marks)      |
|                     |                        | evaluates to itself                                |
|`"Hello" + "there"`  | `"Hello there"`        | Strings can be "added" to each other (concatenated)|
|                     |                        | with the plus sign                                 |
|`c = 100`            | `100`                  | When you assign to a variable, the whole assignment|
|                     |                        | evaluates to the value you've assigned.            |
|`c * 9/5 + 32`       | `212`                  | The usual rules of precedence apply; multiplication|
|                     |                        | and division bind more tightly than addition and are|
|                     |                        | performed first.                                    |
|`obj.c2f(100)`       |`212`                   |A method call is an expression                       |
