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
    # otherwise change state while they are holding on to it. )
    #

    class << self
      def enhance mod
        Shell__.new Kernel__.new mod
      end
    end

    class Shell__

      MetaHell_::Ivars_with_Procs_as_Methods.call self,
        :with_with_instance,
        :with_with_instance_optionally,
        :with_lease_and_release

      def initialize k
        x_a = []
        flush = -> do
          x_a_ = x_a ; x_a = nil
          k.receive_iambic x_a_
        end
        @with_with_instance_optionally = -> do
          x_a.push :new_stays_public, true, :apply_with_instance
          flush[]
        end
        @with_with_instance = -> do
          x_a.push :new_stays_public, false, :apply_with_instance
          flush[]
        end
        @with_lease_and_release = -> p=nil do
          if p
            x_a.push :fly_p, p
          end
          x_a.push :apply_lease_and_release
          flush[]
        end
      end
    end

    class Kernel__

      def initialize mod
        @apply_with_instance = @apply_lease_and_release = nil
        @fly_p = -> do
          new  # context is flyweigtht class
        end
        @make_new_private = false
        @mod = mod
      end

      MetaHell_::Lib_::Entity_lib[].call self, -> do

        def apply_with_instance
          @apply_with_instance = true
        end

        def apply_lease_and_release
          @apply_lease_and_release = true
        end

        def fly_p
          @fly_p = iambic_property
        end

        def new_stays_public
          @make_new_private = ! iambic_property
        end
      end

      def receive_iambic x_a
        ok = process_iambic_fully 0, x_a
        ok and execute
      end

      def execute
        if @apply_with_instance
          Apply_with_instance__[ @mod, @fly_p ]
        end
        if @apply_lease_and_release
          Apply_lease_and_release__[ @mod, @fly_p ]
        end
        if @make_new_private
          @mod.singleton_class.send :private, :new
        end
        nil
      end
    end

    Apply_with_instance__ = -> mod, fly_p do

      mod.define_singleton_method :with_instance, -> do
        a = []

        -> & p do
          o = if a.length.zero?
            instance_exec( & fly_p )
          else
            a.pop
          end
          x = p[ o ]
          o.clear_for_pool
          a.push o
          x
        end
      end.call ; nil
    end

    Apply_lease_and_release__ = -> mod, fly_p do

      a = []

      mod.define_singleton_method :lease do
        if a.length.zero?
          instance_exec( & fly_p )
        else
          a.pop
        end
      end

      mod.define_singleton_method :release do |x|
        x.clear_for_pool
        a.push x ; nil
      end
    end

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

  end
end
