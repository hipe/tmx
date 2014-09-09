# the string template narrative :[#028]

## introduction

(NOTE: the content outside of these parenthesis entirely predates the
timestamp of them having been added here. they were moved here out from
inline in the code at this commit. it perhaps bears mentioning that
aspects of this simple & useful class would be written differently if we
wrote them now.)

the stupid-simplest implementation of templating possible (think mustache
but with *only* parameter interpolation and nothing else). also some fun
is creeping in.




## :#note-85

else we write it back into the string (ick?) for possible future chaining in a
template pipeline or whatever -- *or* optionally we could substitue empty
strings; but this kind of thing should probably be done in the the controller
with template reflection.




## :#note-110

result is an enumerator that yields one ad-hoc tuple with metadata for every
first occurence of a parameter-looking string in the template string. (it is
called "`get_`" because currently it [ reads the file and ] parses the string
anew at each invocation. it is future-proofing to distinguish itself from
other methods that may cache their results.

(borrowed from what may have been mis-perceived as similar convention in
ObjectiveC / Cocoa) :[#014])




## :#about-margins

for some experimental attempts at SASS-like prettiness in our templates,
we might like to know what the "margin" is for any template parameter.

let `margin` mean the zero or more characters that occur before the
"surface characters" of the parameter, up to the beginning of the line
(excluding any leading newline from the previous line).

any template parameter may occur multiple times in the same file,
however this facility only reveals the margin for the first occurence of
the parameter in the file. consequently a template author "needing to
know" the margin of a parameter that is used multiple times may need to
make a unique parameter representing that parameter at that occurence in
the file, which is probably better design anyway.

an occurence of a parameter may have an occurence of another parameter
(or the same parameter) "before" it in the line (that is, between it
and the beginning of the line). for such occurences we say that it
has no margin, and result in `nil`. (we could do otherwise but it is
contrary to the notion (and utility) of a margin (being something fixed
and immutable for some context) so this is hence more poka-yoke.)
