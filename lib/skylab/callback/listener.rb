module Skylab::Callback

  module Listener  # this is the first node dedicated to [#todo:during-merge]

    def self.[] mod, * x_a
      Bundles__.apply_iambic_on_client x_a, mod ; nil
    end

    module Bundles__
      Emission_matrix = -> x_a do
        a = x_a.shift ; a_ = x_a.shift
        a.each do |i|
          a_.each do |i_|
            m_i = :"emit_#{ i }_#{ i_ }"
            define_method m_i do |x|
              @listener.call_any_listener i, i_ do x end
            end ; private m_i
          end
        end ; nil
      end
      Callback::Lib_::Bundle_Multiset[ self ]
    end

    Class_from_diadic_matrix = -> channel_i_a, shape_i_a do
      ::Class.new.class_exec do
        def initialize emitter
          @emitter = emitter ; nil
        end
        make_OK_hash = -> moniker_s, i_a do
          h = ::Hash[ i_a.map { |i| [ i, true ] } ]
          h.default_proc =
            Callback::Lib_::
              Basic_Hash[]::Loquacious_default_proc.curry[ moniker_s ]
          h
        end
        ok_shape = make_OK_hash[ 'shape', shape_i_a ]
        define_method :call_any_listener do |chan_i, shape_i, & p|
          ok_shape[ shape_i ]
          @emitter.call_digraph_listeners chan_i, p.call
        end
        self
      end
    end

    From_digraph_emitter = class From_emitter__
      def self.[] emitter
        new emitter
      end
      def initialize emitter
        @call_p = -> i_a, p do
          _event_x = p.call
          args = [ * i_a, _event_x ]
          emitter.send :call_digraph_listeners, * args  # remove the 'send' i dare you
        end ; nil
      end
      def call_any_listener * a, & p
        @call_p[ a, p ]
      end
      self
    end

    class Suffixed
      def self.[] * a
        new( * a )
      end
      def initialize sffx_i, down
        @down_p = -> { down } ; @sffx_i = sffx_i ; nil
      end
      def call_any_listener * i_a, & p
        @down_p[].send [ * i_a, @sffx_i ].join( '_' ).intern, p.call
      end
    end

    class Spy_Proxy

      def initialize
        yield self
        @do_debug_proc ||= nil
        @do_debug_proc and @debug_IO ||= Callback::Lib_::Some_stderr[]
        @emission_a or raise ::ArgumentError, "emission_a must be set in block"
        @inspect_emission_proc ||= method :inspect_emission_channel_and_payload
        freeze
      end

      attr_writer :debug_IO, :do_debug_proc,
        :emission_a, :inspect_emission_proc

      def call_any_listener * i_a, & p
        x = p[]
        if @do_debug_proc && @do_debug_proc[]
          @debug_IO.puts @inspect_emission_proc[ i_a, x ]
        end
        @emission_a << Emission__.new( i_a.freeze, x ) ; nil
      end
    private
      def inspect_emission_channel_and_payload i_a, x
        "#{ i_a.inspect }: #{ Callback::Lib_::Inspect[ x ] }"
      end
    end

    class Emission__

      def initialize i_a, x
        i_a.frozen? or fail "i_a must be frozen"
        @channel_i_a = i_a ; @payload_x = x
        freeze
      end

      attr_reader :channel_i_a, :payload_x

      alias_method :channel_x, :channel_i_a
    end

    class Proc_As_Listener < ::Proc
      alias_method :call_any_listener, :call
    end
  end
end
