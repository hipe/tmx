# the CLI client narrative :[#006]


## :#storypoint-20

#todo:eventually - comment this line out and it borks b/c not impl.



## :#storypoint-30

we specify that we take an argument but ignore it for the following reasons:
the framework (legacy) passes us the @param_h in that argument currently.
however we nowadays opt to build an iambic array instead.



## :#storypoint-80

without this we run into some nasty problems with our hand-rolled autoloader:
the CLI action base class gets loaded with said autoloader and gets blessed
as one itself. because our hand-rolled autoloader "API" is a very pared down
verison, the necessarily boxxy box node writes checks that the loadee's body
can't cash.

so we enhance this node as a MAARS and we've got to tell it explicitly
we want the methods, because otherwise it would skip us on account of
us already responding to `dir_pathname`.
