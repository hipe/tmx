module Skylab::Common

  module Selective_Listener  # :[#017]

    class << self

      def call mod, * x_a
        Bundles__.edit_module_via_mutable_iambic mod, x_a
        NIL_
      end

      alias_method :[], :call

      def flattening x
        Flattening__.new x
      end

      def make_via_didactic_matrix a, a_
        Make_via_didactic_matrix__[ a, a_ ]
      end

      def methodic delegate, * x_a
        x_a.push :delegate, delegate
        Selective_Listener_::Methodic__.via_iambic x_a
      end

      def spy_proxy & p
        As_Listener___.new( & p )
      end

      def suffixed o, i
        Suffixed__.new o, i
      end

      def via_digraph_emitter x
        Via_digraph_emitter__.new x
      end

      def via_proc & p
        Via_Proc__.new( & p )
      end
    end

    module Bundles__
      Emission_matrix = -> x_a do
        a = x_a.shift ; a_ = x_a.shift
        a.each do |i|
          a_.each do |i_|
            m_i = :"emit_#{ i }_#{ i_ }"
            define_method m_i do |x|
              @listener.maybe_receive_event i, i_, x
            end ; private m_i
          end
        end ; nil
      end

      Home_.lib_.plugin::Bundle::Multiset[ self ]
    end

    Make_via_didactic_matrix__ = -> channel_i_a, shape_i_a do

      ::Class.new.class_exec do

        def initialize emitter
          @emitter = emitter ; nil
        end

        make_OK_hash = -> moniker_s, i_a do
          h = ::Hash[ i_a.map { |i| [ i, true ] } ]
          h.default_proc =
            Home_.lib_.basic::Hash.loquacious_default_proc.curry[ moniker_s ]
          h
        end

        ok_shape = make_OK_hash[ 'shape', shape_i_a ]

        define_method :maybe_receive_event do |chan_i, * x_a, & p|
          x = p ? p.call : x_a.pop
          ok_shape[ * x_a ]
          @emitter.call_digraph_listeners chan_i, x
        end
        self
      end
    end

    class As_Listener___

      def initialize
        yield self
        @do_debug_proc ||= nil

        if @do_debug_proc
          @debug_IO ||= Home_.lib_.system_lib::IO.some_stderr_IO
        end

        @emission_a or raise ::ArgumentError, "emission_a must be set in block"
        @inspect_emission_proc ||= method :inspect_emission_channel_and_payload
        freeze
      end

      attr_writer :debug_IO, :do_debug_proc,
        :emission_a, :inspect_emission_proc

      def maybe_receive_event * i_a, & p
        x = p ? p.call : i_a.pop
        if @do_debug_proc && @do_debug_proc[]
          @debug_IO.puts @inspect_emission_proc[ i_a, x ]
        end
        @emission_a << Emission___.new( i_a.freeze, x ) ; nil
      end
    private
      def inspect_emission_channel_and_payload i_a, x
        "#{ i_a.inspect }: #{ Home_.lib_.strange x }"
      end
    end

    class Emission___

      def initialize i_a, x
        i_a.frozen? or fail "i_a must be frozen"
        @channel_i_a = i_a
        @_playload_x = x
        freeze
      end

      attr_reader :channel_i_a

      alias_method :channel_x, :channel_i_a
    end

    class Flattening__

      def initialize x
        @down_x = x
      end

      def maybe_receive_event * i_a, & p
        x = p ? p.call : i_a.pop
        @down_x.send ( i_a * UNDERSCORE_ ), x
      end
    end

    class Suffixed__

      def initialize down_x, sffx_i
        @down_p = -> do
          down_x
        end
        @sffx_i = sffx_i
      end

      def maybe_receive_event * i_a, & p
        x = p ? p.call : i_a.pop
        @down_p[].send [ * i_a, @sffx_i ].join( UNDERSCORE_ ).intern, x
      end
    end

    class Via_digraph_emitter__

      def initialize emitter_x

        @normal_p = -> i_a, x do

          emitter_x.send :call_digraph_listeners, * i_a, x  # remove the 'send' i dare you

        end ; nil
      end

      def maybe_receive_event * i_a, & p
        x = if p
          p.call
        else
          i_a.pop
        end
        @normal_p[ i_a, x ]
      end
    end

    class Via_Proc__ < ::Proc
      alias_method :maybe_receive_event, :call
    end

    Selective_Listener_ = self
  end
end
