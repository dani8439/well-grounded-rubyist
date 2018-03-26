## **Summary of attr_* methods** ##

### Table 3.1 Summary of the `attr_*` family of getter/setter creation methods ###

|    Method Name     |   Effect      |        Example        |            Equivalent Code          |
|--------------------|-----------------------|--------------------|--------------------------------|
|`attr_reader`   | Creates a reader method | `attr_reader :venue` | `def venue`
|                 |                         |                        |  ` @venue`   |
|                 |                          |                      | `end`    |
|                 |                         |                     |                 |
| `attr_writer`  | Creates a writer method | `attr_writer :price` | `def price=(price)`|
|                 |                     |                         | ` @price = price` |
|                 |                       |                       | `end` |
| `attr_accessor` | Creates reader and writer methods | `attr_accessor :price` | `def price=(price)`|
|                 |                                   |                         | ` @price = price` |
|                 |                                   |                         | `end`            |
|                  |                      |                           |      |
|                   |                     |                           |  `def price` |
|                   |                     |                           | ` @price` |
|                   |                     |                           | `end` |
| `attr`            | Creates a reader and optionally | 1. `attr :venue` | 1. See `attr_reader` |
|                   | a writer method (if the second | 2.  `attr :price, true` | 2. See `attr_accessor` |
|                   | argument is `true`)            |                      |                       |
