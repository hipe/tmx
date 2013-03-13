module Skylab::Headless::TestSupport

  class CLI::Streams_Spy < ::Struct.new :instream, :outstream, :errstream
                                  # (the SECOND you do anything funky, change
                                  # this to a class, you hear!?)

    def clear_buffers
      values.each(& :clear_buffer )
      nil
    end

    def debug! prepend=nil
      values.each do |v|
        v.debug!( prepend ) if v
      end
      nil
    end

    def initialize *three
      three.length > 3 and raise ::ArgumentError, "it's three bro"
      1.upto( 3 ) do |len|        # (allow caller to pass intentional nils..)
        if three.length < len
          three[ len - 1 ] = ::Skylab::TestSupport::IO::Spy.standard
        end
      end
      super
    end
  end
end
