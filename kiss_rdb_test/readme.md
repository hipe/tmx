## why number scheme?

see [#010.6] for an in-depth discussion of what regression-friendliness is
and why we care about it. coming up with a "number scheme" at this level is
our manifestation of regression-friendliness at this level.



## numbering scheme

  - 0001-2499  storage adapter support (1250)
  - 2500-4999  storage adapters (3750)
  - 5000-9999  modality adaptations (7500)


## storage support

  - 0001-0624  test support (for whole package)
  - 0625-1249  models
  - 1250-2499  [#019.3] magnetics


## storage adapters

py -c 'print(tuple(round(2500 + (2500/16) + (2500 * (i/8))) for i in range(0, 8)))'

  - markdown-table (because lol) (2656)
  - rec (first because respect for elders) (2969)
  - csv (should be simplest, dumb) (3281)
  - json (widely supported) (3594)
  - xml (stable) (3906)
  - toml (was first) (4219)
  - yaml (fallback) (4531)
  - eno (dream) (4844)
  - google sheets (4921)


## modality adaptations

py -c 'print(tuple(round(5000 + (5000/14) + (5000 * (i/7))) for i in range(0, 7)))'
py -c 'print(tuple(round(5000 + (5000 * (i/7))) for i in range(0, 8)))'

5357 API
5715
6071 niCLI
6429
6786 iCLI
7500 web/React-ish
8214 desktop
8929 mobile
9643 secrets of the universe




## (document-meta)

  - #history-A.1
  - #birth
