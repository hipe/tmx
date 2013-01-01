# Sexp

## Representing Numeric Values in Sexps

When it comes time to deal with Numerics, consider what
it means to be a lossless Sexp, and then reconsider having members
that are themselves numeric. Consider: since for the kinds of
grammars we parse, a given numeric value may have multiple ways to
be represented as a string, (e.g. "3.14", "3.140") converting from
a such a string to its corresponding numeric value is a lossly
conversion, but the opposite is never true (we never lose information
if we take what started as a string and keep it as the same string).

So, when the inevitable time comes that you need to get a numeric value
from a sexp node, consider either making a to_i or to_f doohah in its
extension module, *or* forgoing the above and dealing with the
aforementioned possible lossiness.

