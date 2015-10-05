module Skylab::TestSupport

  class Benchmark::Mock_  # experimental #hack for testing that your
    # benchmark use cases work correctly, before actually benchmarking
    # them yet.

    def initialize y
      @y = y
    end

    def bmbm
      yield self
      nil
    end

    def report label
      @y << "mock label: #{ label }"
      yield
    end
  end
end
