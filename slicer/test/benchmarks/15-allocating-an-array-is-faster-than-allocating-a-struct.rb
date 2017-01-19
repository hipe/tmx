#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Slicer::TestSupport

  module Benchmarks::Benchmark_15  # cost of building a two-struct vs two-array

    # array was 1.8x faster

    TIMES___ = 2_500_000  # ~2 seconds to run

    setup_for_check_or_real_run = -> do
      NOTHING_
    end

    the_struct_way = -> * do
      MyStruct___.new :A, :B
    end

    the_array_way = -> * do
      [ :A, :B ]
    end

    MyStruct___ = ::Struct.new :_no_see_1, :_no_see_2

    _check_run = -> y do
      setup_for_check_or_real_run[]
      x = the_struct_way[]
      x_ = the_array_way[]
      x[0] == :A || fail
      x[1] == :B || fail
      x_[0] == :A || fail
      x_[1] == :B || fail
      y << "the struct and the array have the same data."
      NIL
    end

    _real_run = -> do
      setup_for_check_or_real_run[]
      number_of_times = TIMES___
      TestSupport_::Benchmark.bmbm do |bm|
        bm.report "the array way" do
          number_of_times.times( & the_array_way )
        end
        bm.report "the struct way" do
          number_of_times.times( & the_struct_way )
        end
      end
    end

    TestSupport_::Benchmark.selftest_argparse[ _check_run, _real_run ]
  end
end
