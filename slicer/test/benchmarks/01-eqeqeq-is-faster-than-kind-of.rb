#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Slicer::TestSupport

  module Benchmarks::Benchmark_01  # `===` vs `kind_of`

    # <-2

TIMES = 400_000  # this number is few enough so that you can see this
  # thing working right away and get a rough sense for the comparision.
  # a larger number will yield more precision.

class Alt < TestSupport_::Benchmark::Alternative
  def val
    if rand >= 0.5
      1
    else
      :foo
    end
  end
end

cls = ::Integer

alts = [ ]
alts << Alt[ "kind_of?", -> { val.kind_of? cls } ]
alts << Alt[ "===",      -> { cls === val } ]
alts << Alt[ "==",       -> { cls == val.class } ]

_tests = lambda do

  alt_ = ::Class.new( TestSupport_::Benchmark::Alternative ).class_exec do
    def initialize alt, val
      super( * alt.to_a )
      @val = val
    end
    attr_reader :val
    self
  end

  stderr = TestSupport_.debug_IO

  assert = ->(alt, input, output) {
    alt = alt_[ alt, input ]
    stderr.write "#{alt.label} with a val of #{input} executes as #{output.inspect}"
    if (ret = (output == alt.execute))
      stderr.puts "."
    else
      stderr.puts " .. FAILED"
    end
    ret
  }

  alts.each do |a|
    assert[a, 1, true]
    assert[a, 1.0, false]
  end
end

t = TIMES

_make_bm_jobs = ->(x) {
  alts.each { |a| x.report(a.label) { t.times { a.execute } } }
}

TestSupport_::Benchmark.selftest_argparse[ -> do
  _tests[]
end, -> do
  TestSupport_::Benchmark.bmbm( & _make_bm_jobs )
end ]

# -> 2

  end
end
