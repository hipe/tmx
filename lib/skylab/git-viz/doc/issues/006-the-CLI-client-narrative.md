# the CLI client narrative :[#006]


## :#storypoint-20

#todo:eventually - comment this line out and it borks b/c not impl.



## :#storypoint-30

we specify that we take an argument but ignore it for the following reasons:
the framework (legacy) passes us the @param_h in that argument currently.
however we nowadays opt to build an iambic array instead.



## :#storypoint-40

it's ugly to hard-code mocking awareness into this top client, but let's
consider the alterantives:

• if you had a singleton-like propery of a class that you overrode, it would
  have problem

• we don't want any mock awareness in the middle (in the API, or the VCS
  adapter).

we can keep mock-awareness out of the middle because the API takes a lot of
parameters.
