require_relative '..'
require 'skylab/basic/core'

module Skylab::PubSub

  %i| Autoloader Basic MetaHell PubSub |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  def self.[] mod, * x_a
    Bundles.apply_iambic_on_client x_a, mod
  end

  module Bundles

    Emits = -> a do
      extend PubSub::Emitter  # might be re-entrant
      graph_x = a.fetch 0 ; a.shift
      if graph_x
        if graph_x.respond_to? :each_pair
          emits graph_x
        else
          emits( * graph_x )
        end
      end ; nil
    end

    Event_factory = -> a do
      extend PubSub::Emitter  # might be re-entrant
      event_factory a.fetch 0 ; a.shift ; nil
    end

    module Emitter_methods  # assumes an `emit` method

      Item_Grammar__ = MetaHell::Bundle::Item_Grammar.
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
            emit emits_to_channel, x
          end
        end
      end

      to_proc = -> a do
        include Emitter_methods
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
        emit chan_i, ev
        nil
      end
    end

    MetaHell::Bundle::Multiset[ self ]
  end

  MAARS = MetaHell::MAARS

  MAARS[ self ]

  stowaway :TestSupport, 'test/test-support'  # [hl]

end
