#!/usr/bin/env ruby -w

require_relative '../core'

module Skylab::Test

  module Benchmarks::Regex_vs_string_math__

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

    Test_::Benchmark.selftest_argparse[ -> y do
      invoke[ Test_::Benchmark::Mock_.new y ]
    end, -> do
      invoke[ Test_::Benchmark ]
    end ]
  end
end
