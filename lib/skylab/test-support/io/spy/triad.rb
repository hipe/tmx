module Skylab::TestSupport

  class IO::Spy::Triad < ::Struct.new :instream, :outstream, :errstream

    # see [#023] for a comparison of different IO spy aggregations

    def initialize *three
      @do_debug = nil
      three.length > 3 and raise ::ArgumentError, "it's three bro"
      1.upto( 3 ) do |len|  # (allow caller to pass intentional nils..)
        if three.length < len
          three[ len - 1 ] = ::Skylab::TestSupport::IO::Spy.standard
        end
      end
      super
    end

    attr_reader :do_debug  # just to see if you called `debug!`

    def debug! prepend=nil
      @do_debug = true
      values.each do |v|
        v.debug!( prepend ) if v
      end
      nil
    end

    def clear_buffers
      values.each( & :clear_buffer )
      nil
    end

    class Mock_Interactive_STDIN__
      def tty?
        true
      end
      def debug! _=nil
      end
    end

    MOCK_INTERACTIVE_STDIN = Mock_Interactive_STDIN__.new

  end
end
