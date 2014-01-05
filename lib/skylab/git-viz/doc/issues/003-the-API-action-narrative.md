# the API action narrative :[#003]



## :#storypoint-20

life is easier when we model it such that there is a common-denominator set
of fields shared universally by every action. but the particular composition
of that list (in terms of both shallow names and deep semantics) will flux
from application to application and over time.



## :#storypoint-30

here we #hook-in to [hl] to change how we process iambics: in an effort to
bridge the old and the new, we are using the [mh] formal attributes library
along with more "modern" iambics.

the newfangled iambic way involves working with atr writers that take no
arguments, but instead consume as many terms as they want from the @x_a ivar.

the older [mh] formal attributes are based around generated atr writers that
take one argument.

what we do here bridges between the two.



## :#storypoint-r40

coinciding with #storypoint-10, here we #hook-in to [mh] to alter the behavior
of the atr writer creation. we make the writers private so that [hl] iambics
can detect them.
