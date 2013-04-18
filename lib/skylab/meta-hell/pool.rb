module Skylab::MetaHell

  module Pool

    # The Pools' `with_instance` enhancement is essentially a partial
    # implementation of a flyweight pattern. It is for when you want to
    # avoid incuring the overhead of allocating and de-allocating lots of
    # objects that you expect to need for perhaps only a short time or
    # limited scope.
    #
    # example of enhancing a class with `with_instance`:
    #
    #     class Foo
    #       Pool.enhance( self ).with :with_instance
    #     end
    #
    #     Foo.new  # => NoMethodError: protected method `new' called for [..]
    #
    #     Foo.with_instance do |f|
    #       # .. ( use f )
    #     end
    #
    #
    # ( Be forewarned that flyweighting can cause hard to track down bugs
    # if used frivolously. You've got to make sure that `clear_for_pool`
    # clears *all* of your state and that you never pass a flyweight out
    # to something that doesn't know it's a flyweight, because it might
    # change state while they are holding on to it. )
    #
    -> do  # `enhance`

      use_with_instance_instead_of_new = nil

      define_singleton_method :enhance do |mod|
        Conduit_::OneShot.new(
          with_instance: -> do
            mod.module_exec( & use_with_instance_instead_of_new )
            nil
          end
        )
      end

      module Conduit_
      end

      class Conduit_::OneShot
        def with sym
          @with[ sym ]
        end
        def initialize h
          @with = -> sym do
            @mutex = sym
            freeze
            h.fetch( sym )[ ]
          end
        end
      end

      use_with_instance_instead_of_new = MetaHell::FUN.module_mutex[ -> do
        class << self
          protected :new
        end
        pool_a = [ ]
        define_singleton_method :with_instance do |&b|
          o = pool_a.length.nonzero? ? pool_a.pop : new
          r = b[ o ]
          o.clear_for_pool
          pool_a << o
          r
        end
      end ]
    end.call
  end
end
