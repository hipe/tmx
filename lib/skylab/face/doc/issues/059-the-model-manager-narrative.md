# the model manager narrative :[#059]

# :#intro

#experimental. abstracted from *one* application, the main thing this guy
does is manage that there is only one memory-persistent instance of each
collection (and, if desired per model, one controller).




## :#storypoint-15

argument is a singular or plural sounding name, whose single- or plural-
sounding-ness will be used to determine if this name references a controller
or a collection (controller).

on the name: "aref" is a more low-level sounding name for `[]`, borrowed from
the ruby source.

currently our behavior is to result in the memoized instance of the model
controller/collection if one exists, otherwise instiate one and, if it is
deemed appropriate, memoize it.  result is the new or existing nerk, and you
have no way of knowing which.



## :#storypoint-30

poka yoke! the init block comes from upstream and the validation happens
downstream yay! we are the middleman who memoizes the valid entity
(or collection). `x_if_yes` gets the entity if it takes one argument,
otherwise (if yes) is called with no arguments.
