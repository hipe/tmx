module Skylab::PubSub

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
              @listener.call i, i_ do x end
            end ; private m_i
          end
        end ; nil
      end
      MetaHell::Bundle::Multiset[ self ]
    end

    Class_from_diadic_matrix = -> channel_i_a, shape_i_a do
      ::Class.new.class_exec do
        def initialize emitter
          @emitter = emitter ; nil
        end
        make_OK_hash = -> moniker_s, i_a do
          h = ::Hash[ i_a.map { |i| [ i, true ] } ]
          h.default_proc =
            Basic::Hash::Loquacious_default_proc.curry[ moniker_s ]
          h
        end
        ok_shape = make_OK_hash[ 'shape', shape_i_a ]
        define_method :call do |chan_i, shape_i, & p|
          ok_shape[ shape_i ]
          @emitter.emit chan_i, p.call
        end
        self
      end
    end

    From_emitter = class From_emitter__
      def self.[] emitter
        new emitter
      end
      def initialize emitter
        @call_p = -> i_a, p do
          _event_x = p.call
          args = [ * i_a, _event_x ]
          emitter.send :emit, * args  # remove the 'send' i dare you
        end ; nil
      end
      def call * a, & p
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
      def call * i_a, & p
        @down_p[].send [ * i_a, @sffx_i ].join( '_' ).intern, p.call
      end
    end
  end
end
