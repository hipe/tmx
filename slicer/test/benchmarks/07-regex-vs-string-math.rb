#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Slicer::TestSupport

  module Benchmarks::Benchmark_07  # regexp vs string match

    TIMES__ = 1_000_000  # fast enough to see. increase recommended

    name = "foo::bar::baz"

    invoke = -> benchm do
      benchm.bmbm do |bm|
        bm.report "can i just do string math" do
          TIMES__.times do
            name[ name.rindex( ':' ) + 1  .. -1 ]
          end
        end
        bm.report "instead of regex" do
          TIMES__.times do
            /[^:]+\z/.match( name )[ 0 ]
          end
        end
      end
    end

    TestSupport_::Benchmark.selftest_argparse[ -> y do
      invoke[ TestSupport_::Benchmark::Mock_.new y ]
    end, -> do
      invoke[ TestSupport_::Benchmark ]
    end ]
  end
end
