## *Fine-tuning regular expressions with quantifiers, anchors, and modifiers* ## 
*Quantifiers* let you specify how many times in a row you want something to match. *Anchors* let you stipulate that the match occur at a certain structural point in a string (beginning of string, end of line, at a word boundary, and so on). *Modifiers* are like switches you can flip to change the behavior of the regexp engine; for example, by making it case-sensitive or altering how it handles whitespace.

We'll look at quantifiers, anchors, and modifiers here, in that order.

### *Constraining matches with quantifiers* ###
Regexp syntax gives you ways to specify not only what you want but also how many; exactly one of a particular character, 5-10 repetitions of a subpattern and so forth.

All the quantifiers operate either on a single character (which may be represented by a character class) or a parenthetical group. When you specify that you want to match, say, three consecutive occurrences of a pattern subpattern, that subpattern can thus be just one character, or it can be a longer subpattern placed inside parentheses.

#### ZERO OR ONE ####
You've already seen a zero-or-one quantifier example. Let's review it and go a little more deeply into it.

You want to match either "Mr" or "Mrs"-and, just to make it more interesting, you want to accommodate both the American versions, which end with periods, and the British versions, which don't. You might describe the pattern as follows:

```irb
the character M, followed by the character r, followed by
*zero* or *one* of the character s, followed by
*zero* or *one* of the character '.'
```
Regexp notation has a special character to represent the zero-or-one situation: the question mark (`?`). The pattern just described would be expressed in regexp notation as follows:

`/Mrs?\.?/`

The question mark after the *s* means that a string with an *s* in that position will match the pattern, and so will a string without an *s*. The same principle applies to the literal period (not the blackslash, indicating that this is an actual period, not a special wildcard dot) followed by a question mark. The whole pattern, then, will match "Mr," "Mrs," "Mr.," or "Mrs." (It will also match "ABCMr." and "Mrs!", but you'll see further on how to delimit a match more precisely when we look at anchors)

The question mark is often used with character classes to indicate zero or one of any of a number of characters. If you're looking for either one or two digits in a row, for example, you might express that part of your pattern like this:

`\d\d?`

This sequence will match "1," "55," "03," and so forth.

Along with the zero-or-one, there's a zero-or-more quantifier.

#### ZERO OR MORE ####
A fairly common case is one in which a string you want to match contains whitespace, but you're not sure how much. Let's say you're trying to match closing `</poem>` tags in an XML document. Such a tag may or may not contain whitespace. All of these are equivalent:

```
</poem>
< /poem>
</    poem>
</poem
>
```

In order to match the gat, you have to allow for unpredictable amounts of whitespace in your pattern-including none.

This is a case for the *zero-or-more* quantifier-the asterisk or star (`*`):

`/<\s*\/s*poem\s*>/`

Each time it appears, the sequence `\s*` means the string being matched is allowed to contain zero or more whitespace characters at this point in the match. (Note the necessity of escaping the forward slash in the pattern with a backslash. Otherwise, it would be interpreted as the slash signaling the end of the regexp.)

Regular expressions, it should be noted, can't do everything. In particular, it's a commonplace and correct observation that you can't parse arbitrary XML with regular expressions, for reasons having to do with the nesting of elements and the ways in which character data is represented. Still, if you're scanning a document because you want to get a rough count of how many poems are in it, and you match and count poem tags, the likelihood that you'll get the information you're looking for is high.

Next among the quantifiers is one or more.

#### ONE OR MORE ####
The one-or-more quantifier is the plus sign (`+`) placed after the character or parenthetical grouping you wish to match one or more of. The match succeeds if the string contains at least one occurrence of the specified subpattern at the appropriate point.

For example, the pattern:

`/\d+/`

matches any sequence of one or more consecutive digits:

```ruby
/\d+/.match("There's a digit in here somewh3re...")  #<--Succeeds #<MatchData "3">
/\d+/.match("No digits here. Move along.")  #<---Fails nil
/\d+/.match("Digits-R-US 2345") #<---- Succeeds #<MatchData "2345">
```
Of course, if you throw in parentheses, you can find out what got matched:

```ruby
/(\d+)/.match("Digits-R-US 2345")
puts $1
```
The output here is:

```irb 
=> #<MatchData "2345" 1:"2345">
2345
=> nil
```
Here's a question, though. The job of the pattern `\d+` is to match one or more digits. That means as soon as the regexp engine (the part of the interpreter that's doing all this pattern matching) sees that the string has the digit 2 in it, it has enough information to conclude that yes, there's a match. Yet it clearly keeps going; it doesn't stop matching the string until it gets all the way up to 5. You can deduce this from the value of `$1`: the fact that `$1` is `2345` means that the subexpression `\d+`, which is what's in the first set of parentheses, is considered to have matched that substring of four digits.

But why match four digits when all you need to prove you're right is one digit? The answer, as so often is in the life as well as regexp analysis, is greed.

### *Greedy (and non-greedy) quantifiers* ###
The `*` (zero-or-more) and `+` (one-or-more) quantifiers are *greedy.* This means they match as many characters as possible, consistent with allowing the rest of the pattern to match.

Look at what `.*` matches in this snippet:

```ruby
string = "abc!def!ghi!"
match = /.+!/.match(string)
puts match[0]  

# Output: abc!def!ghi!
```
We've asked for one or more characters (using the wildcard dot) followed by an exclamation point. You might expect to get back the substring `"abc!"`, which fits that description.

Instead we get `"abc!def!ghi!"`. The `+` quantifier greedily eats up as much of the string as it can and only stops at the *last* exclamation point, not the first.

We can make `+` as well as `*` into non-greedy quantifiers by putting a question mark after them. Watch what happens when we do that with the last example:

```ruby
string = "abc!def!ghi!"
match = /.+?!/.match(string)
puts match[0]
# Output: abc!
```
This version says, "Give me one or more wildcard characters, but only as many as you see up to the *first* exclamation point, which should also be included." Sure enough, this time we get `"abc!"`.

If we add the question mark to the quantifier in the digits example, it will stop after it sees the `2`:

```ruby
/(\d+?)/.match("Digits-R-Us 2345")
puts $1
# Output: 2
```
In this case, the output is `2`.

What does it mean to say that greedy quantifiers give you as many characters as they can, "consistent with allowing the rest of the pattern to match"?

Consider this match:

`/\d+5/.match("Digits-R-US 2345")`

If the one-or-more quantifier's greediness were absolute, the `\d+` would match all four digits-and then the `5` in the pattern wouldn't match anything, so the whole match would fail. But greediness always subordinates itself to ensuring a successful match. What happens, in this case, is that after the match fails, the regexp engine backtracks: it unmatches the `5` and tries the pattern again. This time, it succeeds: it has satisfied both the `\d+` requirement (with `234`) and hte requirement that `5` follow the digits that `\d+` matched.

Once again, you can get an informative X-ray of the proceedings by capturing parts of the matched string and examining what you've captured. Let's let irb and the `MatchData` object show us the relevant captures:

```ruby
>> /(\d+)(5)/.match("Digits-R-Us 2345")
=> #<MatchData "2345" 1:"234" 2:"5">
```
The first capture is `"234"` and the second is `"5"`. The one-or-more quantifier, although greedy, has settled for getting only three digits, instead of four, in the interest of allowing the regexp engine to find a way to make the whole pattern match the string.

In addition to using the zero-/one-or-more-style modifiers, you can also require an exact number or number range of repetitions of a given subpattern.

#### SPECIFIC NUMBERS OF REPETITIONS ####
To specify exactly how many repetitions of a part of your pattern you want unmatched, put the number in curly braces (`{}`) right after the relevant subexpressions, as this example shoes:

`/\d{3}-\d{4}/`

This example matches exactly three digits, a hyphen, and then four digits: 555-1212 and other phone number-like sequences.

You can also specify a range inside the braces:

`/\d{1,10}/`

This example matches any string containing 1-10 consecutive digits. A single number followed by a comma is interpreted as a minimum (*n* or more repetitions). You can therefore match "three or more digits" like this:

`/\d{3,}/`

Ruby's regexp engine is smart enough to let you know if your range is impossible; you'll get a fatal error if you try to match, say, `{10,2}` (at least 10 but no more than 2) occurrences of a subpattern.

You can specify that a repetition count not only for the single characters or character classes but also for any regexp *atom*-the more technical term for "part of your pattern." Atoms include parenthetical subpatterns and character classes as well as individual characters. Thus you can do this, to match five consecutive uppercase letters:

`/([A-Z]){5}/.match("David BLACK")`

But there's an important potential pitfall to be aware of in cases like this.

#### THE LIMITATION ON PARENTHESES ####
If you run that last line of code and look at what the `MatchData` object tells you about the first capture, you may expect to see `"BLACK"`. But you don't:

```irb
>> /([A-Z]){5}/.match("David BLACK")
=> #<MatchData "BLACK" 1:"K">
```
It's just `"K"`. Why isn't `"BLACK"` captured in its entirety?

The reason is that the parentheses don't "know" that they're being repeated five times. They just know that they're the first parentheses from the left (in this particular case) and that what they've captured should be stashed in the first capture slot (`$1`, or `captures[1]` of the `MatchData` object). The expression inside the parentheses `[A-Z]`, can only match one character. If it matches one character five times in a row, it's still only matched one at a time-and it will only "remember" the last one.

In other words, matching one character five times isn't the same as matching five characters one time.

If you want to capture all five characters, you need to move the parentheses so they enclose the entire five-part match:

```irb
>> /([A-Z]{5})/.match("David BLACK")
=> #<MatchData "BLACK" 1:"BLACK">
```
Be careful and literal-minded when it comes to figuring out what will be captured.

We'll look next at ways in which you can specify conditions under which you want matches to occur, rather than the content you expect the string to have.

