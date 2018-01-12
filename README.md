# RPN Calculator
**Reversed Polish Notation Calculator**  
Version X.X.X (Leviathan)  
January 12, 2018  
by Paul Lipkowski (RooiGevaar19)  

Since 11/24/2017, proudly written in FreePascal. :smile:

> Pascal is not dead. It's just a Force that remains forever, just like it does in Luke Skywalker. 

## About RPN
**Reverse Polish Notation** (RPN) is a mathematical notation in which operators follow their operands. It allows to evaluate the mathematical expressions without using parentheses.

**More info:** https://en.wikipedia.org/wiki/Reverse_Polish_notation

### Examples of RPN expressions

Ordinary expression | RPN Expression
------------------- | --------------
5 | 5
2 + 3 | 2 3 +
(2.5 * 2) + 5 | 2.5 2 * 5 +
-4 * (2 / 3) | -4 2 3 / *
(2 + 5) * (11 - 7) | 2 5 + 11 7 - *
((8 - 2) / 3 + (1 + 4) * 2) / 6 | 8 2 - 3 / 1 4 + 2 * + 6 /

## How to use it

### Console application
- Execute a command **rpn** with a quoted RPN expression (e.g. `rpn "2 3 + 4 *"`). More info about expressions in `rpn expression` and `rpn operands`.
- Remember that all values and operands must be delimited with 1 space char.
- In order to specify your output, you can execute rpn with a flag (e.g. `rpn "2 3.4 + 4.5 *" -i` provides an output of rounded integer). Type a command `rpn help` to check out the available flags in this program. 
- If you need help, you can type `rpn help`.

### GUI Application
- Open an app executable.
- In order to compute an RPN expression, just type it in the upper text box and click the "Count it!"-button. The result appears in the result box below. 
- Remember that all values and operands must be delimited with 1 space char.

## Implemented operations:

### Binary operations
- expr1 expr2 operand

Name | Programme Operand
---- | -----------------
add | +
substract | -
multiply | *
divide | /
power | ^
power | pow
root | root
logarithm | log
integer division | div
modulo | mod
newton | newton

*to be extended*

### Unary operations
- expr0 operand

Programme Operand | Name 
----------------- | ----
abs | absolute value
sqrt | suqare root
exp | exponential
! | factorial
fact | factorial
sin | sine
cos | cosine
tan | tangent
cot | cotangent
sec | secant
csc | cosecant
ln | natural logarithm
fib | Fibonacci number 
trunc | truncate
round | round
times | do the following operand/value N times (N is an integer value, N >= 1)

*to be extended*

### Stack operations
- If you already own some values on the stack, e.g. after solving some minor expressions (`2 3 +  9 5 -` leaves 5 and 4 on the stack respectively), you may use stack operations on them by taking **ALL** its values.


**Note 1:** Values themselves are put on the stack when solving the expression.
**Note 2:** The stack operations clear entire stack after execution.

Programme Operand | Name 
----------------- | ----
sum | sum of all values
product | product of all values
count | amount of values put on the stack (stack's size)

**Examples:** 
- `5 3 8 9 2 5 1 10 32.5 4 sin 2 2 + 5 10 sum` sums all values previously put on the stack

*to be extended*

### Operands without any arguments
Those operands may 

| Operand | Purpose                                                                                       |
|:-------:| --------------------------------------------------------------------------------------------- |
| >       | Scan 1 value from an input (e.g. standard input) and add it on the top of the stack of values |
| Xn      | Do the next thing n-times. ('n' is a constant integer value, n >= 1)                          |
| X*      | Do the next thing until the end of input                                                      |

*to be extended*

**Examples:** 
- `> > +` scans 2 values and adds them
- `X2 > +` equivalent of the expression above
- `X* > sum` read all values from an input and sums them

### Available constant values:
- e.g. 2*π -> 2 PI *

Name | Symbol | Approximated value | Programme Operand
---- | ------ | ------------------ | -----------------
Pi | π | 3.1415926535897 | PI
Euler number | e | 2.7182818284590 | EU
Golden number | φ | 1.6180339887498 | FI

## Languages support for the GUI application (Linux)
- :uk: **English** - *default*
- :poland: **Polish** (Polski) 
- :de: German (Deutsch) - *to be implemented*
- 🇿🇦 Afrikaans (Afrikaans) - *to be implemented*
- :denmark: Danish (Dansk) - *to be implemented*
- :israel: Hebrew (עברית) - *to be implemented*

## Improvements

Version | Version Name | Date of Release | Improvements
------- | ------------ |:---------------:| ------------
0.1.0 | Aleph | 11/24/2017 | Basic version
0.2.0 | Bet | 11/27/2017 | Improved computing power of integer values
0.2.1 | Gimel | 12/1/2017 | Unary operands
0.3.0 | Dalet | 1/12/2018 | Detect system language (GUI, Linux), fix of some bugs, stack operations
X.X.X | Leviathan | 1 day after Universe dies | Development Edition, may be sometimes unstable