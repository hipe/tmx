#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Slicer::TestSupport

  module Benchmarks::Benchmark_05  # tuple vs bitfield

    TIMES = 1_000_000

    IS_FOO = 1
    IS_BAR = 2
    IS_BAZ = 4

    def self.tuple_via_bitfield_longhand
      is_foo = true ; is_bar = false ; is_baz = true
      res = 0
      res |= IS_FOO if is_foo
      res |= IS_BAR if is_bar
      res |= IS_BAZ if is_baz
      res
    end

    def self.tuple_via_bitfield_scrunched
      is_foo = true ; is_bar = false ; is_baz = true
      ( is_foo ? IS_FOO : 0 ) | ( is_bar ? IS_BAR : 0 ) | ( is_baz ? IS_BAZ : 0 )
    end

    def self.tuple_via_array
      is_foo = true ; is_bar = false ; is_baz = true
      [ is_foo, is_bar, is_baz ]
    end

    invoke = -> benchm do
      benchm.bmbm do |bm|
        bm.report "returning an int then unpacking it as a bitfield longhand" do
          TIMES.times do
            int = tuple_via_bitfield_longhand
            _foo = ( int & IS_FOO ).nonzero?
            _bar = ( int & IS_BAR ).nonzero?
            _baz = ( int & IS_BAZ ).nonzero?
          end
        end
        bm.report "returning an int then unpacking it as a bitfield scrunched" do
          TIMES.times do
            int = tuple_via_bitfield_scrunched
            _foo = ( int & IS_FOO ).nonzero?
            _bar = ( int & IS_BAR ).nonzero?
            _baz = ( int & IS_BAZ ).nonzero?
          end
        end
        bm.report "returning an array and doing list assignment" do
          TIMES.times do
            _foo, _bar, _baz = tuple_via_array
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
