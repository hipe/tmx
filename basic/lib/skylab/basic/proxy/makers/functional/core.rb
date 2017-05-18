module Skylab::Basic

  class Proxy::Makers::Functional < ::BasicObject

    # ->

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
          ProxyClass_via___.new( a, p, self ).execute
        end
      end  # >>

      # ==

      class ProxyClass_via___

        def initialize sym_a, p, cls
          @base_class = cls
          @proc = p
          @member_symbols = sym_a
        end

        def execute

          cls = ::Class.new @base_class

          bx = __member_box

          cls.const_set MEMBER_BOX_CONST_, bx

          cls.send :define_method, :__functional_proxy_association_box__ do
            bx
          end

          cls.class_exec do
            bx.a_.each do |sym|
              define_method sym do |*a, &p|
                @__proxy_implementation__.__receive_call_ p, a, sym
              end
            end
          end

          if @proc
            cls.class_exec( & @proc )
          end
          cls
        end

        def __member_box

          bx = Common_::Box.new

          _use_member_symbols = [ * @base_class.const_get( MEMBER_BOX_CONST_ ).a_, * @member_symbols ]

          _use_member_symbols.each do |sym|
            bx.add sym, sym
          end

          bx.freeze
        end
      end

      # ==

      MEMBER_BOX_CONST_ = :FUNCTIONAL_PROXY_PROPERTY_BOX__

      const_set MEMBER_BOX_CONST_, Common_::Box.the_empty_box

      def initialize * x_a

        @__proxy_implementation__ = ProxyImplementation_via_.call_by do |o|
          o.argument_array = x_a
          o.association_box = __functional_proxy_association_box__
        end
      end

      # ==

      class ProxyImplementation_via_ < Common_::MagneticBySimpleModel

        def argument_value_array= p_a

          @_pair_stream = Common_::Stream.via_times p_a.length do |d|
            Common_::QualifiedKnownKnown.via_value_and_symbol(
              p_a.fetch( d ),
              @association_box.at_offset( d ),  # (is symbol)
            )
          end
          p_a
        end

        def argument_array= x_a
          @_pair_stream = Proxy__PairStream_via_ArgumentArray_[ x_a ]
          x_a
        end

        attr_writer(
          :association_box,
        )

        def execute
          ProxyImplementation___.new __proc_hash
        end

        def __proc_hash

          # (what we do below with using a [#061] "diminishing pool" to
          # assert that there are no missing requireds, this is a
          # microscopic sub-slice of the [#fi-012.3] "one ring" algorithm,
          # namely, using a [#061] "diminishing pool" to assert that there
          # are no missing requireds. our requirements are a small enough
          # sub-slice of what happens there that we opt against incurring a
          # a dependency on [fi]. this logic is tracked with [#fi-037.5.D].)

          proc_hash = {}

          bx = @association_box
          h = bx.h_

          dim_pool = ::Hash[ bx.a_.map { |sym| [ sym, nil ] } ]

          st = remove_instance_variable :@_pair_stream
          begin
            pair = st.gets
            pair || break

            k = pair.name_symbol

            proc_hash[ h.fetch k ] = pair.value

            dim_pool.delete k
            redo
          end while above

          if dim_pool.length.nonzero?
            __when_missing dim_pool.keys
          end

          proc_hash
        end

        def __when_missing keys
          _say = "missing required proxy function definition(s): (#{ keys * ', ' })"
          raise Home_::ArgumentError, _say
        end
      end

      # ==

      class ProxyImplementation___

        def initialize h
          @__proc_hash = h
        end

        def __receive_call_ p, a, m
          @__proc_hash.fetch( m )[ * a, & p ]
        end
      end

      # ==
      # ==

    # -
  end
end
# #tombstone-A: modernized
