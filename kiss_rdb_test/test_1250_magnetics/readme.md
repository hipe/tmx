From parent: 1250-2499  [#019.3] magnetics

The amount of magnetics we have right now: 5 (then 4)
Multiply it by 3 for expansion: 15


beg = 1255
jump = (2499-beg)/15
first = beg + jump/2

```
py -c 'beg=1255;jump=(2499-beg)/15;first=beg+jump/2;print(tuple(round(first+jump*i) for i in range(0, 15)))'
```


1296 lines via template
1379 doubly linked list
1393 parse recfile for schema
1416 collection via path
1448 (expansion 3/3)
1462 indexes
1545 provision new identifier randomly
1628
1711
1794
1877
1960
2043
2126
2209
2292
2375
2399 (last)


(the expansion:)
```
py -c 'beg=1379;end=1462;w=end-beg;nu=3;pt0=beg+w/nu/2;print(tuple(round(pt0 + w/nu*i, 2) for i in range(0,nu)))'
```
(then we shifted the space to the right by six units because it was colliding with previous)


  - #born.
