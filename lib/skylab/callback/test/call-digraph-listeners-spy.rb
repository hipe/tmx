module Skylab::Callback::TestSupport

  class Emit_Spy  # read [#022] the emit spy narrative  #storypoint-1

    def initialize
      @do_debug_p = nil ; @emission_a = [] ; @debug_IO = nil
      block_given? and yield self ; nil
    end

    attr_reader :emission_a ; attr_writer :debug_IO

    def debug!
      self.do_debug = true ; nil
    end

    def do_debug= is_on
      self.do_debug_proc = -> { is_on }
      is_on
    end

    def do_debug_proc= p
      @debug_IO ||= ::STDERR
      @do_debug_p = p ; nil
    end

    def emit stream, payload_x  # per spec [#ps-001]
      @emission_a << Emission__.new( stream, payload_x )
      if @do_debug_p && @do_debug_p.call
        o = @emission_a.last
        @debug_IO.puts [ o.stream_name, o.payload_x ].inspect
      end ; nil
    end

    class Emission__

      def initialize stream_name, payload_x
        @stream_name, @payload_x = stream_name, payload_x
      end

      attr_reader :stream_name, :payload_x

      alias_method :channel_x, :stream_name

      def to_a  # e.g for pretty debugging output
        [ @stream_name, @payload_x ]
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
