module Skylab::TestSupport

  class Coverage_::Service

    def self.start infostream, path_prefix_p
      new( infostream ).start path_prefix_p
    end

    def initialize stderr
      stderr.respond_to? :puts or raise ::ArgumentError  # make sure it looks like an IO
      @y = ::Enumerator::Yielder.new( & stderr.method( :puts ) )
      nil
    end

    def start path_prefix_p
      Coverage_::Coverer.new( @y, path_prefix_p ).cover
      nil
    end
  end
end
