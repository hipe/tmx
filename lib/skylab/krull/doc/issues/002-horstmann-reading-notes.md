# learning scala

## introduction

we are learning just enough to write our own little scraper ..


## Sept 29, 2015

jkup shared:

    http://logic.cse.unt.edu/tarau/teaching/scala_docs/scala-for-the-impatient.pdf

  … and

    https://twitter.github.io/scala_school/

started reading at 8:07PM. wow! we have a scala "-version" by 8:19PM.
hello world happens immediately after (sort of).

  • personal observation: scala's type system is simlar to swift's.
    (or, the reverse.))

  • p.o: and yes, `val` vs. `var` appear to have the same
    syntax & semantics, yay.

  • you usually don't need `val`




### 1.3. Types

these classes are: Byte Char Short Int Long Float Double.

  • p.o: primitives are like in ruby, pseudo objects.

### 1.5. Calling Functions and Methods

  • the rule of thumb is that a parameterless method that doesn't modify
    the object has no parentheis

### 1.6. The `apply` Method

  • ..is called magically by the `()` operator.

  • idiom: this is often how construction works.

### 1.7 & 1.8 - use this section later, for docs

### 2.1. Conditional Expressions

  • the type of a mixed type expression is the supertype of both
    branches. `Any`. `Unit`. `()`

  • repl - use {} in multiline `if` statement. use `:paste` then Ctrl-k

(day change)

### 2.3. Block Expressions and Assignments (Wednesday, Sept 30th, 11:00)

  • like ruby: a block is an expression, not a statement.

  • unlike ruby: the assigment expression results in a value of type `Unit`.

### 2.4. Loops

  • in scala we often use list comprehensions instead of loops.

  • `while` and `do` are as Java and C++.

  • `for` is not as those. it is a language construct: `for (i <- expr)`:`
    * `i` assumes the element type of `expr`
    * `i` is scoped to the body of the loop
    * `.to()` is "up to and including", `.until()` is "up to (exclusive)"

  • there is no `break` - be clever. (see text here)

### 2.5. Advanced For Loops and For Comprehensions

  • you can achieve the effect of loops within loops by the N
    expressions (as generators) passed to the `for()` construct (see).

  • there can be a "guard" to the generator (which is like a pass filter)

  • you can use N number of "definitions" there (variables).

  • you can (in my words) turn a for loop into a map (whose result is a
    Vector) by starting the body with `yield`. this is called a for
    *comprehension*.

  • the type that comes back from the generator corresponds to the type
    of the first generator.

  • you can use `{}` instad of `()`, and newlines instead of `;`!

### 2.6. Functions (1:17pm)

  • like C and unlike Java, scala has plain old functions.

  • this is what a function defintion looks like:

        def abs(x: Double) = if (x >= 0) x else -x

      * you must specify the types of all parameters
      * you must specify the return type IFF it's recursive

  • `return` is not commonly used

  • for those recursives, `def fac(n: Int): Int = ...`

### 2.7. Default and Named Arguments

  • defaulting works as expected:

        def decorate(str: String, left: String = "[", right: String = "]") =..

  • you can use named arguments, which allows you to pass them in any
    order.

    * you can mix named and unnamed arguments where unnamed first.

### 2.8. Variable Arguments

  • like this:

        def sum(args: Int*) = ..

    the type is a `Seq` (chapter 6)

  • to "glob" the argument you pass in a call,

        sum(1 to 5: _*)

### 2.9. Procedures

  • a *procedure* has no value, and is only called for its side effect.

    * define such a function by omitting the `=` in the definition.

### 2.10. Lazy Values

  • SHAMWOW: put `lazy` before `val` (see)

### 2.11. Exceptions

  • unlike java, here you need not declare that your function or method
    might throw an exception (for reasons (see)).

  • the `throw` expression has the special type `Nothing`, which is a
    trick to allow the compiler to assign the type you "mean" for an
    `if/else` expression.

  • for catching, see the "Pattern Matchind and Case Classes" chapter,
    then (see).

  • NOTE: at end of chapter 2, there were some exercises we didn't get

## 3. Working with Arrays (14:22)

  • (note that there are other collection types..)

  • `+=` is like `push`

  • `++=` is like `concat`

  • `trimEnd`, `insert`, `remove`, `toArray`, `toBuffer` (see)
    * "amortized constant time"

### 3.3. Traversing Arrays (and ArrayBuffers) (see)

### 3.4. Transforming Arrays

  • `filter` and `map` is a more functional way of doing guards and `yield`

### 3.5. Common Algorithms

  • `sum`, `min`, `max`, `sortWith`

  • you can sort in place an array but not an array buffer (see)

  • instead of `join`, `mkString`.

  • `toString` is useful for debugging, only defined for ArrayBuffer, not Ary

### 3.6 Deciphering ScalaDoc

  • (`Traversable`, `Iterator`) -> (`TraversableOnce`): these are traits..

### 3.7 Multi-Dimensional Array

  • `ofDim` (see)

### 3.8. Interoperating with Java (see)

### (3.9. Exercises)

## 4. Maps and Tuples

### 4.1. Constructing a Map

  • a map is a collection of pairs.

  • did you know that `()` is a tuple? .. `->`

### 4.2. Accessing Map Values

  • `()`, `contains`, `getOrElse`, `get`

### 4.3. Updating Map Values

  • `()=`, +=( Tuple* ), `-=`

### 4.4. Iterating over Maps (we are lazy)

  • for ((k, v) <- map) process k and v; `keySet`, `values`

### 4.5. Hash Tables and Trees (meh)

### 4.6. Interoperating with Java (meh)

### 4.7. Tuples

    (), t._2, t _2

### 4.8. Zipping

  • l.o - `zip`

  • `keys.zip(values).toMap`

### 4.9. Exercises (todo)

## 5. Classes

  • a file can contain several classes, they have public visibility

  • it's good style to use `()` on mutator methods

    * when the defintion has no `()`, this style is enforced (use this).

  • `private` vs. `private[this]`

### 5.6. Auxiliary Constructors

### 5.7. The Primary Constructor (you just need to read this whole thing twice)

## 6. Objects - the `object` structure is its own thing in scala (etc)

## 7. Packages and Imports (etc)

## 8. Inheritance (October 1st 2015. 10:00AM)

  • only the primary constructor can call a superclass constructor (from .5)

### 8.10. ERRATA - "XREF"

  • `-Xcheckinit`

### 9. Files and Regular Expressions (etc).

"DONE" at Oct 1, 11:14 AM
