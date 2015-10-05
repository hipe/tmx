require 'benchmark'
module Foo
  module Bar
    module Baz
      module Wick
        class << self
          def blearg1
            to_s.split('::').last.downcase.intern
          end
          Re = /([^:]+)$/
          def blearg2
            Re.match(to_s)[1].downcase.intern
          end
        end
      end
    end
  end
end

n = 5e5.to_i
thing = Foo::Bar::Baz::Wick
fail('blearg1 fail') unless thing.blearg1 == :wick
fail('blearg2 fail') unless thing.blearg2 == :wick
Benchmark.bm(7) do |x|
  x.report("regexp")  { n.times do; thing.blearg2; end }
  x.report("split")   { n.times do; thing.blearg1; end }
end
