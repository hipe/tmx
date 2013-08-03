module Skylab::TestSupport

  class Coverage::Service

    def self.start infostream, path_prefix_p
      new( infostream ).start path_prefix_p
    end

    def initialize infostream
      @y = ::Enumerator::Yielder.new( & infostream.method( :puts ) )
      nil
    end

    def start path_prefix_p
      Coverage::Coverer.new( @y, path_prefix_p ).cover
      nil
    end
  end
end
