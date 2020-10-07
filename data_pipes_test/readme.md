## the numbering scheme

We do the numbering scheme because [#010.6] regression-friendliness.

At writing (#history-A.1) we "feel" that we are *at most* a third of the
way "filled up" with test cases and asset. We will use four-digit case
numbers. At writing we have 62 test cases.

```bash
py -c 'min=1;max=3334;ni=62;w=max-min;hwpi=w/ni/2;tuple(print(round(hwpi + w*i/ni)) for i in range(0, ni))'
```



### Magnetics

0262 is the first case number of sync. we have three items before that:

```bash
py -c 'min=1;max=262;ni=3;w=max-min;hwpi=w/ni/2;tuple(print(round(hwpi + w*i/ni)) for i in range(0, ni))'
```

- select 0044
- filter by tags 0130
- convert collection 0218
- sync



## (document-meta)

  - #history-A.1: massive re-arch during module split
  - #born.
