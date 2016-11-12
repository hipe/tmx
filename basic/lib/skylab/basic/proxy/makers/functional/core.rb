module Skylab::Basic

  # ->

    class Proxy::Makers::Functional < ::BasicObject

      # make a 'fuctional' proxy class with a list of member names:
      #
      #     MyProxy = Home_::Proxy::Makers::Functional.new :foo, :bar
      #
      # in contrast to `inline` which creates a proxy "inline" by mutating
      # a singleton class, this makes a (::BasicObject) subclass proxy class
      # in one step that you instantiate in another step.
      #
      # build a proxy instance by passing it procs to implement the fields:
      #
      #     pxy = MyProxy.new(
      #       :foo, -> x { "bar: #{ x }" },
      #       :bar, -> { :BAZ },
      #     )
      #
      # per the procs you passed, it can take arguments:
      #
      #     pxy.foo( :wee )  # => "bar: wee"
      #
      # or not:
      #
      #     pxy.bar  # => :BAZ
      #
      #
      # build another proxy instance, this time with a hash
      #
      #     pxy2 = MyProxy.new(
      #       foo: -> { :A },
      #       bar: -> s { "#{ s.upcase }A#{ s.upcase }" },
      #     )
      #
      # note the signatures of the methods have changed
      #
      #     pxy2.foo  # => :A
      #     pxy2.bar 'y'  # => "YAY"
      #

      class << self

        alias_method :orig_new_, :new

        def new * a, & p
          cls = make_ a, & p
          cls.singleton_class.send :alias_method, :new, :orig_new_
          cls
        end

        def make_ a, & p
          Make___[ a, p, self ]
        end
      end  # >>

      class Make___

        Attributes_actor_.call( self,
          :i_a,
          :p,
          :base_class,
        )

        def execute
          begin_class
          resolve_box
          finish_class
          @p and @class.class_exec( & @p )
          @class
        end

      private

        def begin_class
          @class = ::Class.new @base_class
          NIL_
        end

        def resolve_box
          resolve_members
          @box = Common_::Box.new
          @member_i_a.each do |i|
            @box.add i, i
          end
          nil
        end

        def resolve_members
          @member_i_a = [ * @base_class.const_get( CONST_ ).a_, * @i_a ]
          nil
        end

        def finish_class
          _BOX = @box
          @class.const_set CONST_, _BOX
          @class.send :define_method, :__functional_proxy_property_box__ do
            _BOX
          end
          @box.a_.each do | sym |
            @class.send :define_method, sym do | * a, & p |
              @__proxy_kernel__.method_proc( sym )[ * a, & p ]
            end
          end
          NIL_
        end
      end

      CONST_ = :FUNCTIONAL_PROXY_PROPERTY_BOX__

      const_set CONST_, Common_::Box.the_empty_box

      def initialize * x_a
        @__proxy_kernel__ = Kernel_.new __functional_proxy_property_box__
        @__proxy_kernel__.process_iambic_fully x_a
      end

      class Kernel_

        def initialize box
          @box = box
          @p_h = {}
        end

        def process_iambic_fully x_a
          begin_process
          __init_pair_stream_via_iambic x_a
          finish_process
        end

        def process_arglist_fully p_a
          begin_process
          __init_pair_stream_via_arglist p_a
          finish_process
        end

        def method_proc i
          @p_h.fetch i
        end

      private

        def begin_process
          @missing_h = ::Hash[ @box.a_.map { |i| [ i, nil ] } ] ; nil
        end

        def __init_pair_stream_via_iambic x_a
          @_pair_stream = Try_convert_iambic_to_pair_stream_[ x_a ]
          NIL_
        end

        def __init_pair_stream_via_arglist p_a

          @_pair_stream = Common_::Stream.via_times p_a.length do | d |

            Common_::Pair.via_value_and_name(
              p_a.fetch( d ),
              @box.at_position( d ) )
          end
          NIL_
        end

        def finish_process

          @_pair_stream.each do | pair |

            sym = pair.name_symbol

            @p_h[ @box.fetch sym ] = pair.value_x

            @missing_h.delete sym
          end

          if @missing_h.length.nonzero?
            when_missing @missing_h.keys
          end
        end

        def when_missing i_a
          ::Kernel.raise Home_::ArgumentError, say_missing( i_a )
        end

        def say_missing i_a
          "missing required proxy function definition(s): (#{ i_a * ', ' })"
        end
      end
    end
  # <-
end
