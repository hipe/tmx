# the dupe narrative :[#021]

## the overview

we implement and use a method called 'dupe' when we want something like a
deep copy (for whatever definition of "deep copy" we decide on for that
particular class).

we intentionally introduce the new term 'dupe' instaead of just using
the builtin method `dup` so that we do not fail silently in case we fail to
reach our own implementation. (that is, we never want ruby to decide for us
what a deep copy means; and we avoid this by never using `dup` for this
purpose, unless we intend to.)

however, our implementation of `dupe` is always (at the time of this writing)
simply a call to ruby's builtin `dup` method, and here's why:

in concert with the `dup` method, ruby provides hooking through an
`initialize_copy` method (referred to hereafter as "i.c" in this document.)
the typical behavior for `dup` on an "typical" object appears to be that
a new object is allocated, and `i.c` is sent to it with the original object
as the sole argument. `initialize` is never sent to the new object.

for almost all circumstances this is exactly the facility we want: when
creating "new" objects that are not copies, there is typically a more involved
setup. when initializing copies of an existing object we may be able to give
ourselves an easier time because we can shallow-copy particular values
without needing to validate their own values or their upstreams values as
appropriate.

it is actually easier to hear about the history of this in order to understand
the present..



## history

the builtin `i.c` method is nice because it frees us from doing a hack we used
to do before we knew about it that looked something like:

    class Foo
      def dupe
        x_a = base_args
        self.class.allocate.instance_exec
          base_init( * x_a )
          self
        end
      end
      def base_args
        [ @a, @b ]
      end
      def base_init a, b
        @a = a ; @b = b ; nil
      end
    end

the above was a typical implementation of 'dupe' before we knew about
`initialize_copy`. note the ugliness of calling `allocate` and `instance_exec`.


## the present

when implementing 'dupe' for your class, your class must know whether its
parent class is 'dupe'-aware. if your class is the first in its chain to
implement 'dupe' then it will be done differently then when it is a child
class of a dupe-er.

...
