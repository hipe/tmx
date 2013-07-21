module Skylab::TestSupport

  module Benchmark

    def self.bmbm *a, &b
      Subsys::Services::Benchmark.bmbm( *a, &b )
    end

    def self.selftest_argparse
      const_get :Selftest_argparse_, false
    end
  end
end
