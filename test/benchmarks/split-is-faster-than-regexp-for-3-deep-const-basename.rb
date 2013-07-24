#!/usr/bin/env ruby -w

require_relative '../core'

module Skylab::Test
module Benchmarks::Split_vs_rx_  # losing 2x indent

TIMES = 200_000  # this amount is few enough to see it working right away.
  # increase the number for more precise results.

module Foo
  module BarBaz
    module BiffoBazzo
    end
  end
end

alt = Test::Benchmark::Alternative
mod = Foo::BarBaz::BiffoBazzo
mod_str = mod.to_s

re = /[^:]+\z/

alts = []
alts << alt[ "3 lvl split pop", -> { mod_str.split('::').last } ]
alts << alt[ "inline regex", -> { /[^:]+\z/.match(mod_str)[0] } ]
alts << alt[ "regex var in outer scope", -> { re.match(mod_str)[0] } ]

stderr = Stderr_

test_that_benchmark_blocks_are_correct = -> do
  alts.each do |a|
    s = a.proc.call
    stderr[].puts "OK?:#{ "%30s:------->%s<-------" % [a.label, s] }"
  end
end

Test::Benchmark.selftest_argparse[ -> do
  test_that_benchmark_blocks_are_correct[]
end, -> do
  t = TIMES
  Test::Benchmark.bmbm do |bm|
     alts.each do |a|
       bm.report a.label do
         t.times do
           a.proc.call
         end
       end
     end
   end
end ]

end end  # lost 2x indent
