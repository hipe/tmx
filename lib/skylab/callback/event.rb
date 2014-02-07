module Skylab::Callback

  module Event

    class Unified  # [#019] #storypoint-10

      -> do  # `initialize`
        next_id = nil
        define_method :initialize do |esg, stream_name, *payload| # #storypoint-10
          @event_id = next_id[ ]
          @event_stream_graph_p = if esg
            esg.respond_to?( :call ) and fail 'where'
            -> { esg }
          else
            esg.nil? and raise ::ArgumentError, "must be trueish or false"
            false  # false meaning "intentionally not set"
          end
          @is_touched = false
          payload.length.nonzero? and @payload_a = payload
          @stream_name = stream_name ; nil
        end

        next_id = -> do
          nxt_id = 0
          -> { nxt_id += 1 }
        end.call

      end.call

      attr_reader :event_id, :is_touched, :payload_a, :stream_name

      def is_event
        true
      end

      def touched?
        is_touched
      end

      def is? stream_i
        (( @cs ||= Callback::Digraph::Contextualized_Stream_Name.
          new( @stream_name, event_stream_graph ) )).is? stream_i
      end

      undef_method :to_s  # for now this is here to catch mistakes loudly

      Callback::Lib_::Function[].enhance( self ).
        as_private_getter :@event_stream_graph_p, :event_stream_graph

      def touch!
        @is_touched = true
        self
      end
    end

    class Textual < Unified  # #storypoint-12

      def initialize esg, stream_name, text
        @text = text
        super esg, stream_name
      end

      attr_reader :text
    end
  end
end
