module Skylab::TestSupport

  class Coverage::Service

    def self.start infostream, path_prefix_f
      new( infostream ).start path_prefix_f
    end

    def initialize infostream
      @y = ::Enumerator::Yielder.new( & infostream.method( :puts ) )
      nil
    end

    def start path_prefix_f
      Coverage::Coverer.new( @y, path_prefix_f ).cover
      nil
    end
  end
end
