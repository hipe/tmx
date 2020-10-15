## the numbering scheme

We do the numbering scheme because [#010.6] regression-friendliness.

This numbering scheme has gone thru at least two complete overhauls.


```bash
py -c 'which=0; beg=3251; end=5000; segs=5; space=(end-beg); segw=space/segs; half_segw=segw/2; print(beg+(which*segw)+half_segw)'
```


### THE NEW WAY

- two foundational formats
  -  2.50%: (0001-0250) ((62.5) 0125, (187.5))
- non-command-like functions, magnets (EMPTY)
  -  7.50%: (0251-1000)
- command-like functions (high-level operations) that use foundation formats
  - 17.50%: (1001-2750) (3624.5)    cc(1062).07 select(1167).05 sync(1517).15 fbt(1298).
- other format adapters
  -  5.00%: (2751-3250)   html(2760) ps(2849) mdt(2938)
- integrations of operations with other FA's
  - 17.50%: (3251-5000)
- reserved for some magical future
  - 50.00%



## (document-meta)

  - #history-B.3: yet another re-arch, renumbering 3 months later for mag cloud
  - #history-A.1: massive re-arch during module split
  - #born.
