## why number scheme?

see [#010.6] for an in-depth discussion of what regression-friendliness is
and why we care about it. coming up with a "number scheme" at this level is
our manifestation of regression-friendliness at this level.




## generating the number scheme

we have N categories of test, ordered roughly in order of simple-to-complex.

for N is 11, we this (or equivalent oneliner)

```sh
$ for i in 1 2 3 4 5 6 7 8 9 10 11 ; do py -c "print($i.0/11 * 1000)" ; done
```

the above gives us the "boundaries".
to get the midpoints in each of those boundaries, we do similar:

```sh
$ for i in 1 3 5 7 9 11 13 15 17 19 21 ; do py -c "print($i.0/22 * 1000)" ; done
```

we take the above floating point numbers (both boundaries and midpoints)
and round them up. things might be off-by-one.




## numbering scheme

  - 001-091:  (placeholder for private models) (45)
  - 092-182:  (placeholder for private magnetics) (136)
  - 183-273:  (placeholder for public models) (227)
  - 274-364:  magnetics (318)
  - 365-455:  (placeholder for some kind of API) (409)
  - 456-545:  non-interactive CLI (500)
  - 546-636:  (placeholder for interactive CLI) (591)
  - 637-727:  (placeholder for web (React)) (682)
  - 728-818:  (placeholder for desktop) (773)
  - 819-909:  (placeholder for mobile) (would subdivide) (864)
  - 910-999:  (placeholder for secrets of the universe) (955)




## discussion: this is not that other scheme

this number-scheme is not the same as [#868] our test case numberspace.

however the two correlate and interleave:

this scheme is for numbering nodes (directories) at this level only. the
other scheme is for numbering test cases that are all part of the same broad
development plan.

at #birth the latter scheme interleaves throughout the topic scheme only
in the sense that we will at first try to tackle some of our business-
functions while also covering CLI, MAYBE (EDIT)




## (document-meta)

  - #birth
