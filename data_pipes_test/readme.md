## the numbering scheme

We do this because [#010.6] regression-friendliness.

At writing (#history-A.1) we "feel" that we are *at most* a third of the
way "filled up" with test cases and asset. We will use four-digit case
numbers. At writing we have 62 test cases.

```bash
py -c 'min=1;max=3334;ni=62;w=max-min;hwpi=w/ni/2;tuple(print(round(hwpi + w*i/ni)) for i in range(0, ni))'
```



## (document-meta)

  - #history-A.1: massive re-arch during module split
  - #born.
