module Skylab::Callback::TestSupport

  class Call_Digraph_Listeners_Spy__  # read [#022] the narrative  #storypoint-1

    Callback_.lib_.entity self do

      o :polymorphic_writer_method_name_suffix, :'='

      def debug=
        @do_debug_proc = Callback_::NILADIC_TRUTH_
        KEEP_PARSING_
      end

      o :properties, :do_debug_proc, :debug_IO

    end

    EMPTY_P_ = Callback_::EMPTY_P_

    def initialize * x_a
      block_given? and self._FIXME
      init_via_iambic x_a
    end

    def init_via_iambic x_a
      @emission_a = []
      process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
      @do_debug_proc ||= EMPTY_P_
    end

    attr_reader :emission_a

    def call_digraph_listeners stream, payload_x  # per spec [#001]
      @emission_a.push Emission__.new( stream, payload_x )
      if @do_debug_proc.call
        o = @emission_a.last
        @debug_IO.puts [ o.stream_symbol, o.payload_x ].inspect
      end ; nil
    end

    class Emission__

      def initialize *a
        @stream_symbol, @payload_x = a
      end

      attr_reader :stream_symbol, :payload_x

      alias_method :channel_x, :stream_symbol

      def to_a  # e.g for pretty debugging output
        [ @stream_symbol, @payload_x ]
      end
    end

    # ~ retrieving and deleting emissions

    def clear!
      @emission_a.clear
    end

    def delete_emission_a
      r = @emission_a ; @emission_a = nil ; r
    end
  end
end
