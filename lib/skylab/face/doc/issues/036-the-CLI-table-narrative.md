# the CLI table narrative :[#036]

## :#storypoint-5

this is one of several CLI table implementations. one day we will designate
one of the narratives as the home to sort these out.



## :#storypoint-80

keep in mind what is happening here - *every* time you call the curried
executable, it makes a deep copy of the whole field box. it feels like we
should optimize this but it depends on the usage whether this is helpful: we
don't expect our usage patterns to justify such an optimization at this point



## :#storypoint-100

lock down the surface matrix from the data producer now - it might be a
randomized functional tree, for e.g (in which case you wouldn't want to
iterate over it twice). also, some custom enums want to short circuit the
entire rendering of the table, halfway through collapsing themselves, hence
we check the result of `each`.



## :#storypoint-280

when this form is called the instance is acting as a curried executable - the
arguments do not mutate this instance.
