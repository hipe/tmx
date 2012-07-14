require 'benchmark'

module Skylab
  module TestSupport
    module Benchmarking
    end
  end
end

module Skylab::TestSupport
  class Benchmarking::Alternative < ::Struct.new(:label, :block)
    def initialize params
      params.each { |k, v| send("#{k}=", v) }
    end
  end
end

Alt = Skylab::TestSupport::Benchmarking::Alternative

module Foo
  module BarBaz
    module BiffoBazzo
    end
  end
end

mod = Foo::BarBaz::BiffoBazzo
mod_str = mod.to_s

RE = /[^:]+\z/

alts = [
  Alt.new(
    label: "3 lvl split pop",
    block: -> { mod_str.split('::').last }
  ),
  Alt.new(
    label: "inline regex",
    block: -> { /[^:]+\z/.match(mod_str)[0] }
  ),
  Alt.new(
    label: "regex constant",
    block: -> { RE.match(mod_str)[0] }
  )
]

t = 2_000_000

make_bm_jobs = ->(bm) {
  alts.each { |a| bm.report(a.label) { t.times { a.block.call } } }
}

test_that_benchmark_blocks_are_correct = ->() do
  alts.each do |a|
    s = a.block.call
    $stderr.puts("OK?:#{ "%30s:------->%s<-------" % [a.label, s] }")
  end
end

# test_that_benchmark_blocks_are_correct.call
Benchmark.bmbm(&make_bm_jobs)
