#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Slicer::TestSupport

  module Benchmarks::Benchmark_16

    TIMES___ = 5_000_000  # a few seconds to run. less than 4.

    setup_for_check_or_real_run = -> do
      NOTHING_
    end

    class LeftGuy
      FOO = :ohai_left
    end

    class LeftGuyChild < LeftGuy
    end

    class RightGuy
      def self.foo
        :ohai_right
      end
    end

    class RightGuyChild < RightGuy
    end

    the_left_way = -> * do
      LeftGuyChild::FOO
    end

    the_right_way = -> * do
      RightGuyChild.foo
    end

    _check_run = -> y do
      setup_for_check_or_real_run[]
      :ohai_left == the_left_way[] || fail
      :ohai_right == the_right_way[] || fail
      y << "the two ways both work."
      NIL
    end

    _real_run = -> do
      setup_for_check_or_real_run[]
      number_of_times = TIMES___
      TestSupport_::Benchmark.bmbm do |bm|
        bm.report "the left way" do
          number_of_times.times( & the_left_way )
        end
        bm.report "the right way" do
          number_of_times.times( & the_right_way )
        end
      end
    end

    TestSupport_::Benchmark.selftest_argparse[ _check_run, _real_run ]
  end
end
