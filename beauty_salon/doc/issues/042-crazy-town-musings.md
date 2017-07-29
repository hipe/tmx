# crazy-town musings :[#042]


## the problem with finding ending line numbers :[#here.B]

TL;DR: it appears that to do this correctly will be impossible using
our current dependencies. here is the thinking leading to this conclusion:

the general idea is that if we have a "compound" sexp (any that
contains other sexp's), each sexp it is composed of will start on
the same line as *it*, or a subsequent line, recursively.

for one thing, there are exceptions to this assumption, as we have
seen with the else-if sugar EDIT [that one place].

but following the (false) assumption, the idea WAS that you can find
the ending line number of a compound sexp by finding the ending line
number of its "lastmost" node (recursively), which (corollarily)
will not be a compound node but an atomic node ("atomic" here meaning
a node that does not contain within its composition any other sexp's).

but there is a general problem with this approach that we can illustrate
from several vantagepoints:



### vantagepoint one: multiline literals

consider all the forms of "literal" that can span several lines:
  - multiline regexp literals
  - multiline string literals
    (it seems every kind of string literal can span multiple lines:
      - single-quoted
      - double-quoted
      - HEREDOC's of course
      - and at least two others)
  - certainly array literals
  - hash literals
  - argument lists
  - the `%w()` and `%i()` language constructs (forms of array literal)

well for one thing you might say, for all but the first two and the last
bullet above, these are all "compound" sexp's that would seem to be covered
by our recursive algorithm above. but the issue is those three bullets:
i.e we can't attempt to determine the ending line number of regexp and
string literals without some shudderworthy hackery (counting the newline
characters in their byte representation? would that even work?).

and in the case of constructs like `%w()` and `%i()`, we are up the creek
without a paddle. the only way to determine the line endings here would be
effectively to re-parse these features from the real file ourselves (also
not impossible, but shudderworthy).



### vantagepoint two: the `end` keywords

imagine a no-frills class definition that defines three methods, and is
formatted in an unsurprising way. looking at the last method defined in
this class, let's say that the last node under the method body is an
`if-else` expression, and the last element (non-recursively) of the `else`
expression is some `const` dereference:

    class MyClass

      def meth1
        # ..
      end

      def meth2
        # ..
      end

      def meth3
        if xx
          # ..
        else
          UNABLE_
        end
      end
    end

this (syntactically valid) code can be used to illustrate both the
spirit of our recursive algorithm and its main shortcoming: if we apply
the recursive approach to the sexp of the above class definition (the
class is composed of a list of method definitions, the last method
definition is composed of a list of (let's say) logic constructs, the
last logic construct's last element is the `UNABLE_` const dereference),
then we get the line number of the line that `UNABLE_` occurs on, not
the line containing the `end` keyword of the subject class.

again, consistent with the pattern, we could try to determine this
"correct" ending line number with some shudderworty hackery involving
managing our own stack and then, from the recursively derived ending line
number we would count the contiguous real lines with `/\A[ \t]*end\b/` or
some craziness like that; but this brings us back to the shuddery of
writing our own hackish parsing..
