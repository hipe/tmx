This package is distinct in that it has "submodules" as an officially
recognized thing at its top level.

On the asset wing of things (the asset code), we have modules like
"listening", "memoization" at the top level of this package (well, under the
topmost module, the package module). We don't typically place "business names"
at the top level of the package like this, but everything is so abstract in
this package that it feels okay.

Symmetry is broken because here in the test wing we have a directory/unit
with the term "submodules" literally in it, whereas we don't have a module
literally called "submodules". That is as we want it to be, because for
regression-friendly testing we want the submodules grouped as a unit, but
for avoiding overly verbose package names in imports, we want the actual
submodules to live at the top of the package.


## test case numbering allocation table:

  - 0001-4999  submodules
  - 5000-9999  magnetics


In that first category we break it into 20 spans to start
(`py -c 'print(tuple((125+(i*250)) for i in range(0, 20)))'`):

  - 0105-0115  tinies (0125)
  - xxxx-xxxx  memoization (0375)
  - xxxx-xxxx  streamlib (0675)
  - xxxx-xxxx  listening (0875)
  - xxxx-xxxx  write only io proxy (1125)


In that second category (magnetics):

  - 5000-7499  "pure" magnetics not about microservices etc
  - 7500-9999  magnetics for modality adaptations


In the pure magnetics category
(`py -c 'print(tuple((5062.5+(i*125)) for i in range(0, 20)))'`):

  - 5129-5177  rotating buffer (5188)


In the category of magnetics for modality adaptations
(`py -c 'print(tuple((7562.5+(i*125)) for i in range(0, 20)))'`)

  - 7751-7805  parameter via definition (7813)
  - 8063-8063  command via parameter stream (8063)
  - 8189-8189  parameters cannon (8189)
  - 8313-8313  command stream (8313)



## (document-meta)

  - #born.
