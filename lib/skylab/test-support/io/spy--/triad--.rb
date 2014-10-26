module Skylab::TestSupport

  class IO::Spy__::Triad__ < ::Struct.new :instream, :outstream, :errstream

    # see [#020] a comparison of different IO spy aggregations
    # the TL;DR is that this class may be deprecated.

    class << self

      def mock_noninteractive_STDIN_class
        Mock_Noninteractive_STDIN__
      end

      def mock_noninteractive_STDIN_instance
        MOCK_NONINTERACTIVE_STDIN__
      end

      def mock_interactive_STDIN_instance
        MOCK_INTERACTIVE_STDIN__
      end
    end

    def initialize *three
      @do_debug = nil
      three.length > 3 and raise ::ArgumentError, "it's three bro"
      1.upto( 3 ) do |len|  # (allow caller to pass intentional nils..)
        if three.length < len
          three[ len - 1 ] = TestSupport_::IO.spy.new
        end
      end
      super
    end

    attr_reader :do_debug  # just to see if you called `debug!`

    def debug! prepnd=nil
      @do_debug = true
      members.each do |i|
        x = self[ i ]
        x or next
        if x.respond_to? :debug!
          x.debug! prepnd
        else  # assume it is an [#hl-169] IO tee. ignoring `prepnd` for now
          x[ :debug ] = Prefixed_debugging_IO__[ i, TestSupport_.debug_IO ]
        end
      end
      nil
    end

    Prefixed_debugging_IO__ = -> do
      p = -> i, io do
        Prefixed_Debugging_IO__ = TestSupport_::Lib_::Proxy_lib[].nice :puts, :write, :<<
        p = -> i_, io_ do
          fmt = -> x do
            "(#{ i_ }: #{ x.inspect })"
          end
          me = Prefixed_Debugging_IO__.new :<<, -> x do
              io_ << fmt[ x ] ; me
            end,
            :puts, -> x do
              io_.puts fmt[ x ]
            end,
            :write, -> x do
              io_.write fmt[ x ]
              x.length
            end
        end
        p[ i, io ]
      end
      -> i, io do
        p[ i, io ]
      end
    end.call

    def clear_buffers
      values.each( & :clear_buffer )
      nil
    end

    MOCK_INTERACTIVE_STDIN__ =
    class Stub_Interactive_STDIN__
      def tty?
        true
      end
      def debug! _=nil
      end
      self
    end.new

    MOCK_NONINTERACTIVE_STDIN__ =
    class Stub_Noninteractive_STDIN__ < Stub_Interactive_STDIN__
      def tty?
        false
      end
      self
    end.new

    class Mock_Noninteractive_STDIN__ < Stub_Noninteractive_STDIN__
      def initialize a  # mutates a
        @a = a ; nil
      end
      def gets
        @a.shift
      end
    end
  end
end
