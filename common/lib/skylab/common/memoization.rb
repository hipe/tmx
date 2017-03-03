module Skylab::Common

  Memoization = ::Module.new

  module Memoization::Pool

    # the below enhancement that the subject offers is a partial
    # implementation of a flyweight pattern. It is for when you want to
    # avoid incurring the overhead of allocating and de-allocating lots of
    # objects that you expect to need for perhaps only a short time or
    # limited scope.

    # here's an example of enhancing a class with the enhancer function:
    # This implementation requires that your class define a `clear_for_pool`
    # instance method that will be called to reset the object back to an
    # empty state after it is used in each `instance_session` block.
    #
    #     class Foo
    #
    #       Home_::Memoization::Pool[ self ].instances_can_only_be_accessed_through_instance_sessions
    #
    #       def initialize
    #         @state = :money
    #       end
    #
    #       def clear_for_pool
    #         @state = :cleared
    #       end
    #
    #       attr_reader :state
    #     end
    #
    # with such a class, you can't create instances of it
    #
    #     Foo.new  # => NoMethodError: private method `new' called for..
    #
    # however you can access it during a session:
    #
    #     keep = nil
    #     Foo.instance_session do |o|
    #       o.state  # => :money
    #       keep = o
    #     end
    #
    #     keep.state  # => :cleared
    #
    # ( Be forewarned that flyweighting can cause hard to track down bugs
    # if used frivolously. You've got to make sure that `clear_for_pool`
    # clears *all* of your state and that you never pass a flyweight out
    # to something that doesn't know it's a flyweight, because it might
    # otherwise change state while they are holding on to it. )
    #
    # (we break this last rule in the test to show that the callback is called.)

    class << self

      def [] mod
        Shell__.new Kernel__.new mod
      end
    end  # >>

    class Shell__

      Home_::Session::Ivars_with_Procs_as_Methods.call self,
        :instances_can_only_be_accessed_through_instance_sessions,
        :instances_can_be_accessed_through_instance_sessions,
        :lease_by

      def initialize k

        x_a = []

        flush = -> do
          x_a_ = x_a ; x_a = nil
          k.receive_iambic x_a_
        end

        @instances_can_be_accessed_through_instance_sessions = -> do
          x_a.push :new_stays_public, true, :define_instance_session_method
          flush[]
        end

        @instances_can_only_be_accessed_through_instance_sessions = -> do
          x_a.push :new_stays_public, false, :define_instance_session_method
          flush[]
        end

        @lease_by = -> &p do
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

        @do_define_instance_session_method = nil
        @apply_lease_and_release = nil

        @fly_p = -> do
          new  # context is the flyweigtht class!
        end

        @make_new_private = false
        @mod = mod
      end

      def receive_iambic x_a
        _ok = process_argument_scanner_fully scanner_via_array x_a
        _ok and execute
      end

      include Home_.lib_.fields::Attributes::Actor::InstanceMethods
        # here's an example of a performer that uses the above i.m module
        # but does not define an ATTRIBUTES structure. :[#007.1]

    private

      def define_instance_session_method=
        @do_define_instance_session_method = true
        KEEP_PARSING_
      end

      def apply_lease_and_release=
        @apply_lease_and_release = true
        KEEP_PARSING_
      end

      def fly_p=
        @fly_p = gets_one
        KEEP_PARSING_
      end

      def new_stays_public=
        @make_new_private = ! gets_one
        KEEP_PARSING_
      end

      def execute

        if @do_define_instance_session_method
          Define_instance_session_method___[ @mod, @fly_p ]
        end

        if @apply_lease_and_release
          Define_lease_and_releae_methods___[ @mod, @fly_p ]
        end

        if @make_new_private
          @mod.singleton_class.send :private, :new
        end

        NIL_
      end
    end

    Define_instance_session_method___ = -> mod, fly_p do

      mod.define_singleton_method :instance_session, -> do
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

    Define_lease_and_releae_methods___ = -> mod, fly_p do

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

      # The Pool's `lease_by` enhancement follows the same idea
      # as the above  enhancement, but instead of wrapping
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
