module Skylab::Callback

  module Bundles

    Emit_to_IO_stream_string = -> x_a do
      module_exec x_a, & Emit_to_IO_stream_string_.to_proc
    end

    Listeners_digraph = -> a do
      Callback_[ self, :employ_DSL_for_digraph_emitter ]  # #idempotent
      graph_x = a.fetch 0 ; a.shift
      if graph_x
        if graph_x.respond_to? :each_pair
          listeners_digraph graph_x
        else
          listeners_digraph( * graph_x )
        end
      end ; nil
    end

    module Digraph_methods  # assumes an `call_digraph_listeners` method

      Item_Grammar__ = Callback_.lib_.bundle_item_grammar.
        new %i( structure structifiying ), :emitter, %i( emits_to_channel )

      build_method = -> sp do
        structural, structifying = ( sp.adj.to_a if sp.adj )
        emits_to_channel, = ( sp.pp.to_a if sp.pp )
        emits_to_channel ||= sp.keyword_value_x
        if structural
          structifying and never
          -> x do
            emit_to_channel_structure emits_to_channel, x
          end
        elsif structifying
          -> x do
            emit_to_channel_structifiable emits_to_channel, x
          end
        else
          -> do x
            call_digraph_listeners emits_to_channel, x
          end
        end
      end

      to_proc = -> a do
        include Digraph_methods
        p = Item_Grammar__.build_parser_for a
        while (( sp = p[] ))
          define_method sp.keyword_value_x, & build_method[ sp ]
          private sp.keyword_value_x
        end
      end
      define_singleton_method :to_proc do to_proc end

      def emit_to_channel_structifiable chan_i, ev
        if ! ev.respond_to? :members
          ev = build_structured_event_from_event ev
        end
        emit_to_channel_structure chan_i, ev
      end

      def emit_to_channel_structure chan_i, ev
        ev.respond_to?( :members ) or raise ::TypeError, "no implicit #{
          }conversion of #{ ev.class } into ~Struct intended for #{
            }channel `#{ chan_i }` emitted by ( #{ self.class } )"
        call_digraph_listeners chan_i, ev
        nil
      end
    end

    Employ_DSL_for_digraph_emitter = -> _ do
      extend Callback_::Digraph::MMs ; include Callback_::Digraph::IMs ; nil
    end

    Event_factory = -> a do
      Callback_[ self, :employ_DSL_for_digraph_emitter ]  # #idempotent
      event_factory a.fetch 0 ; a.shift ; nil
    end

    Extend_digraph_emitter_module_methods = -> _ do
      extend Callback_::Digraph::MMs ; nil
    end

    Include_digraph_emitter_module_methods = -> _ do
      include Callback_::Digraph::MMs ; nil
    end

    Callback_.lib_.bundle_multiset self
  end

  module Emit_to_IO_stream_string_
    to_proc = -> x_a do
      define_method :init_simple_IO_manifold, begin
        if :default_to_stream == x_a.first
          Build_init_method_with_default_stream__[ x_a ]
        else
          Build_init_method__[]
        end
      end
      private :init_simple_IO_manifold
    private
      def emit_to_IO_stream_string i, s
        @simple_IO_manifold_h[ i ].puts s ; nil
      end
    end ; define_singleton_method :to_proc do to_proc end

    Build_init_method_with_default_stream__ = -> x_a do
      x_a.shift ; default_stream_i = x_a.shift
      default_proc = -> h, _ { h.fetch default_stream_i }
      -> h do
        h.default_proc and fail "default stream specified in 2 places"
        h.default_proc = default_proc
        @simple_IO_manifold_h = h ; nil
      end
    end

    Build_init_method__ = -> do
      default_proc = Callback_.lib_.hash_lib.loquacious_default_proc.curry[ 'stream' ]
      -> h do
        h.default_proc ||= default_proc
        @simple_IO_manifold_h = h ; nil
      end
    end
  end
end
