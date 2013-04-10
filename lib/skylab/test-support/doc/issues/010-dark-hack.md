# dark hack

during the transition from ruby 1.9.2 to 1.9.3 tons of tests broke
because of a change in the way constant scope works in a manner I
had trouble finding documentation for..

(it *appears* as though it used to look up the constant in each module
in the ancestor chain for `self`, and now it doesn't, and strictly sticks
to lexical scope .. but this is just a fuzzy guess at the issue.)

the easiest way to slough through all these was often to wrap around
the outermost `describe` block module declaration for ::Skylab, which
allowed us at least to access our subproduct "toplevel" constant(s)
with minimal effort.

(a historical note - although at first we didn't care, we were eventually
made to dislike the feeling of wrapping our whole file of test cases
inside an ad-hoc testing sandbox module because some people seemed
to feel that you should always be able to have the (rspec) `describe`
node be the outermost thing.. we hence made efforts to facilitate this
with things like `Quickie.enable_kernel_describe`.

however, once the constant lookup rules changed we wished we had
always stuck to our guns and used a sandbox module. Regret is the
acquisition of wisdom as experienced by a pessimist.)

all this said, it is unknown as of yet whether this represents more
of a temporary workaround or a structural convention change, hence
the tracking tag.

~
