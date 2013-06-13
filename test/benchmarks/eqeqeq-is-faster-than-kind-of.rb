#!/usr/bin/env ruby -w

require_relative '../core'

module Skylab::Test

module Benchmarks::Eq_Eq_Eq_Vs_Kind_Of_  # losing 2x indent..

class Alt < Test::Benchmark::Alternative
  def val
    if rand >= 0.5
      1
    else
      :foo
    end
  end
end

alts = [ ]
alts << Alt[ "kind_of?", -> { val.kind_of? ::Fixnum } ]
alts << Alt[ "===",      -> { ::Fixnum === val } ]
alts << Alt[ "==",       -> { ::Fixnum == val.class } ]

_tests = lambda do

  alt_ = ::Class.new( Test::Benchmark::Alternative ).class_exec do
    def initialize alt, val
      super( * alt.to_a )
      @val = val
    end
    attr_reader :val
    self
  end

  assert = ->(alt, input, output) {
    alt = alt_[ alt, input ]
    $stderr.write "#{alt.label} with a val of #{input} executes as #{output.inspect}"
    if (ret = (output == alt.execute))
      $stderr.puts "."
    else
      $stderr.puts " .. FAILED"
    end
    ret
  }

  alts.each do |a|
    assert[a, 1, true]
    assert[a, 1.0, false]
  end
end

t = 4_000_000

_make_bm_jobs = ->(x) {
  alts.each { |a| x.report(a.label) { t.times { a.execute } } }
}

Test::Benchmark.argparse( -> do
  _tests[]
end, -> do
  Test::Benchmark.bmbm( & _make_bm_jobs )
end )

end end  # indent lost 2 x
