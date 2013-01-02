require_relative 'test-support'

module Foo
  module BarBaz
    module BiffoBazzo
    end
  end
end

alt = Skylab::TestSupport::Benchmarking::Alternative
mod = Foo::BarBaz::BiffoBazzo
mod_str = mod.to_s

re = /[^:]+\z/

alts = [
  alt.new(
    label: "3 lvl split pop",
    block: -> { mod_str.split('::').last }
  ),
  alt.new(
    label: "inline regex",
    block: -> { /[^:]+\z/.match(mod_str)[0] }
  ),
  alt.new(
    label: "regex var in outer scope",
    block: -> { re.match(mod_str)[0] }
  )
]

test_that_benchmark_blocks_are_correct = -> do
  alts.each do |a|
    s = a.block.call
    $stderr.puts "OK?:#{ "%30s:------->%s<-------" % [a.label, s] }"
  end
end

# test_that_benchmark_blocks_are_correct.call

t = 2_000_000

Benchmark.bmbm do |bm|
  alts.each do |a|
    bm.report a.label do
      t.times do
        a.block.call
      end
    end
  end
end
