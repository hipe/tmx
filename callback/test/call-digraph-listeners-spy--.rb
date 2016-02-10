module Skylab::Callback::TestSupport

  class Call_Digraph_Listeners_Spy__  # read [#022] the narrative  #storypoint-1

    class << self
      private :new
    end

    Home_::Actor.methodic self, :properties,
      :debug_IO,
      :do_debug_proc

    def initialize & edit_p

      @emission_a = []
      instance_exec( & edit_p )
      @do_debug_proc ||= EMPTY_P_
    end

  private

    def debug=
      @do_debug_proc = Home_::NILADIC_TRUTH_
      KEEP_PARSING_
    end

  public

    EMPTY_P_ = Home_::EMPTY_P_

    attr_reader :emission_a

    def call_digraph_listeners stream, payload_x  # per spec [#001]

      @emission_a.push Emission___.new( stream, payload_x )

      if @do_debug_proc.call

        o = @emission_a.last

        @debug_IO.puts o.to_a.inspect
      end

      NIL_
    end

    class Emission___

      def initialize ss, pl

        @_payload_x = pl
        @stream_symbol = ss
      end

      def to_a  # e.g for pretty debugging output
        [ @stream_symbol, @_payload_x ]
      end

      def produce_line_content_string
        @_payload_x
      end

      attr_reader(
        :stream_symbol,
      )

      alias_method :channel_x, :stream_symbol
    end

    # ~ retrieving and deleting emissions

    def clear!
      @emission_a.clear
    end

    def delete_emission_a
      x = @emission_a
      @emission_a = nil
      x
    end
  end
end
