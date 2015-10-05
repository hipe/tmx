module Skylab::TestSupport

  module Benchmark

    def self.bmbm *a, &b
      Home_::Library_::Benchmark.bmbm( *a, &b )
    end

    def self.selftest_argparse
      const_get :Selftest_argparse_, false
    end
  end
end
