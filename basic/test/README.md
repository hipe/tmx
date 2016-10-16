# number allocation

## notes

there's 26 nodes at writing. it's crowded enough that we will use a 3 digit
numberspace. we want not to occupy 0 or 100 so:

    27.times { |d| puts ( 100.0 * d ) / 27 }

the below numbers are determined by the above numbers rounded.

(a bit more than a month later the above approach becomes [#ts-024].)




## table

  - "atoms" (037 number, 074 string)

  - bound compounds (111 range, 148 rotating buffer)

  - unbound compounds, fundamental comp sci data structures (185 list, 222 queue, 295 hash, 296 set, 333 box)

  - computer science structures and tools: (370 mutex, 407 function, 444 digraph, 481 tree, 519 state machine, 556 proxy, 593 sexp)

  - platform programming concepts: (630 regexp, 667 yielder, 704 enumerator, 740 method, 777 module, 815 class)

  - nature, concern or business specific (852 time, 888 token, 926 field, 963 pathname)
