# the core node narrative :[#021]


## to extlib or not to extlib :[#022]

we typically strenuously abstain from extlib (a.k.a monkeypatching) but this
is one exception. having this method in String makes tests that
use HEREDOC's much easier to read: it takes the leading whitespace from a
multiline string and uses it to unindent the rest of the string, which allows
us to indent our HEREDOC's "correctly" within the surrounding block, yet keep
that indentation out of the string something that is possible but much uglier
by other means. caveat: your intended string cannot start with any whitespace.
