module Skylab::TestSupport

  class IO::Spy::Triad < ::Struct.new :instream, :outstream, :errstream

    # see [#020] a comparison of different IO spy aggregations
    # the TL;DR is that this class may be deprecated.

    def initialize *three
      @do_debug = nil
      three.length > 3 and raise ::ArgumentError, "it's three bro"
      1.upto( 3 ) do |len|  # (allow caller to pass intentional nils..)
        if three.length < len
          three[ len - 1 ] = ::Skylab::TestSupport::IO::Spy.new
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

    MOCK_INTERACTIVE_STDIN =
    class Stub_Interactive_STDIN__
      def tty?
        true
      end
      def debug! _=nil
      end
      self
    end.new

    MOCK_NONINTERACTIVE_STDIN =
    class Stub_Noninteractive_STDIN__ < Stub_Interactive_STDIN__
      def tty?
        false
      end
      self
    end.new

    class Mock_Noninteractive_STDIN < Stub_Noninteractive_STDIN__
      def initialize a  # mutates a
        @a = a ; nil
      end
      def gets
        @a.shift
      end
    end
  end
end
