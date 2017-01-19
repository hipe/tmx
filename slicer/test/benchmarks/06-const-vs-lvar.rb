#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Slicer::TestSupport

  module Benchmarks::Benchmark_06  # const vs lvar

    TIMES__ = 30_000_000

    class Foo
      CONST = 1
      def initialize times
        @times = times
      end
      def with_const
        @times.times do
          CONST + 2
        end
        nil
      end
      def with_lvar
        lvar = CONST
        @times.times do
          lvar + 2
        end
        nil
      end
    end

    invoke = -> benchm do
      benchm.bmbm do |bm|
        bm.report "it is slgnificantly slower to access a const" do
          f = Foo.new TIMES__
          f.with_const
        end
        bm.report "than an lvar" do
          f = Foo.new TIMES__
          f.with_lvar
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
