module Skylab::MetaHell

  module Pool

    # Pool's `with_instance` enhancement is essentially a partial
    # implementation of a flyweight pattern. It is for when you want to
    # avoid incuring the overhead of allocating and de-allocating lots of
    # objects that you expect to need for perhaps only a short time or
    # limited scope.
    #
    # example of enhancing a class with `with_instance`:
    #
    #     class Foo
    #       Pool.enhance( self ).with_with_instance
    #     end
    #
    #     Foo.new  # => NoMethodError: private method `new' called for [..]
    #
    #     Foo.with_instance do |f|
    #       # .. ( use f )
    #     end
    #
    # This implementation requires that your class define a `clear_for_pool`
    # instance method that will be called to reset the object back to an
    # empty state after it is used in each `with_instance` block.
    #
    # ( Be forewarned that flyweighting can cause hard to track down bugs
    # if used frivolously. You've got to make sure that `clear_for_pool`
    # clears *all* of your state and that you never pass a flyweight out
    # to something that doesn't know it's a flyweight, because it might
    # change state while they are holding on to it. )
    #
    -> do  # `enhance`

      use_with_instance_instead_of_new = nil
      use_lease_and_release_instead_of_new = nil
      define_singleton_method :enhance do |mod|
        mutex = Mutex_.new
        Conduit_.new(
          -> do
            mutex.bump :with_with_instance
            mod.module_exec( & use_with_instance_instead_of_new )
            nil
          end,
          ->( *a ) do
            mutex.bump :lease_and_release
            mod.module_exec( *a, & use_lease_and_release_instead_of_new )
            nil
          end
        )
      end

      class Conduit_
        def initialize wi, lar
          define_singleton_method :with_with_instance, &wi
          define_singleton_method :with_lease_and_release, &lar
        end
      end

      class Mutex_
        def initialize
          @did = nil
        end
        def bump sym
          if @did
            raise "mutex failed - cannot do \"#{ sym }\", alread did #{
              }#{ @did }"
          else
            @did = sym
            nil
          end
        end
      end

      use_with_instance_instead_of_new = MetaHell::Module::Mutex[ -> do

        class << self

          private :new

          pool_a = [ ]

          define_method :with_instance do |&b|
            o = pool_a.length.nonzero? ? pool_a.pop : new
            r = b[ o ]
            o.clear_for_pool
            pool_a << o
            r
          end
        end
      end ]

      use_lease_and_release_instead_of_new = MetaHell::Module::Mutex[ -> init do

        singleton_class.class_exec do  # like `class << self` but inheirt scope

          private :new

          pool_a = [ ]

          define_method :lease do
            if pool_a.length.nonzero?
              pool_a.pop
            else
              class_exec( & init )
            end
          end

          define_method :release do |x|
            pool_a << x
            nil
          end
        end
      end ]

      # The Pool's `with_lease_and_release` enhancement follows the same idea
      # as the `with_with_instance` enhancement, but instead of wrapping
      # the flyweight iteration in a block, it lets you call `lease` and
      # `release` explicitly.
      #
      # Please see unit test for example.
      #
      # (The two enhancements exist as separate only because they came from
      # different places. Whenever it is optimal to merge the other on top of
      # the one we should do so [#023].)

    end.call
  end
end
