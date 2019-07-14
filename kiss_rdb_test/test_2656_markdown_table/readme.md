this whole node is mostly created to drive the
unifying test cannon

  - number of storage adapters: 8
  - area starting number: 2500
  - area space: 2500
  - your storage adapter offset: 0
  - number of verb cases: 9

```bash
py -c 'print(tuple(round(2500 + (2500/8/9/2) + (i * 2500/8/9)) for i in range(0, 9)))'
py -c 'print(tuple(round(2500 + (i * 2500/8/9)) for i in range(0, 10)))'
py -c 'beg=2400;end=2500;space=end-beg;nu=7;first_mid=beg+(space/nu/2);print(tuple(round(first_mid+(space*i/nu),2) for i in range(0,nu)))'
```


2400
2450 (many legacy tests)
2500
2517 resolve collection
2535
2552 traverse ID's
2569
2587 traverse all entities
2604
2622 retrieve
2639
2656 delete
2674
2691 create
2708
2726 update
2743
2760 expansion one
2778
2795 expansion two
2812

  - #born.
