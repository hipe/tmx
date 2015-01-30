module Skylab::Callback

  module Proxy

    class Functional__ < ::BasicObject

      # make a 'fuctional' proxy class with a list of member names:
      #
      #     My_Proxy = Subject_[].functional :foo, :baz
      #
      # in contrast to `inline` which creates a proxy "inline" by mutating
      # a singleton class, this makes a (::BasicObject) subclass proxy class
      # in one step that you instantiate in another step.
      #
      # build a proxy instance by passing it procs to implement the fields:
      #
      #     pxy = My_Proxy.new :foo, -> x { "bar: #{ x }" },
      #       :baz, -> { :BAZ }
      #
      #     pxy.foo( :wee )  #=> "bar: wee"
      #     pxy.baz  # => :BAZ

      class << self
        def call_via_arglist a, & p
          Actor__[ a, p, self ]
        end
      end

      class Actor__

        Callback_::Actor.call self, :properties,
          :i_a, :p, :base_class

        def execute
          begin_class
          resolve_box
          finish_class
          @p and @class.class_exec( & @p )
          @class
        end

      private

        def begin_class
          @class = ::Class.new @base_class ; nil
        end

        def resolve_box
          resolve_members
          @box = Callback_::Box.new
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
          nil
        end
      end

      CONST_ = :FUNCTIONAL_PROXY_PROPERTY_BOX__

      const_set CONST_, Callback_::Box.the_empty_box

      def initialize * x_a
        @__proxy_kernel__ = Kernel_.new __functional_proxy_property_box__
        @__proxy_kernel__.process_iambic_fully x_a
      end

      class Kernel_

        def initialize box
          @box = box
          @p_h = {}
        end

        def process_arglist_fully p_a
          begin_process
          resolve_pairs_scan_via_arglist p_a
          finish_process
        end

        def process_iambic_fully x_a
          begin_process
          resolve_pairs_scan_via_iambic x_a
          finish_process
        end

        def method_proc i
          @p_h.fetch i
        end

      private

        def begin_process
          @missing_h = ::Hash[ @box.a_.map { |i| [ i, nil ] } ] ; nil
        end

        def resolve_pairs_scan_via_iambic x_a
          @pairs_scan = Try_convert_iambic_to_pairs_scan_[ x_a ] ; nil
        end

        def resolve_pairs_scan_via_arglist p_a
          @pairs_scan = Callback_.stream.via_times( p_a.length ) do |d|
            [ @box.at_position( d ), p_a.fetch( d ) ]
          end ; nil
        end

        def finish_process
          @pairs_scan.each do |i, p|
            @p_h[ @box.fetch i ] = p
            @missing_h.delete i
          end
          if @missing_h.length.nonzero?
            when_missing @missing_h.keys
          end
        end

        def when_missing i_a
          ::Kernel.raise ::ArgumentError, say_missing( i_a )
        end

        def say_missing i_a
          "missing required proxy function definition(s): (#{ i_a * ', ' })"
        end
      end
    end
  end
end
