require 'benchmark'
module Foo
  module Bar
    module Baz
      module Wick

        class << self

          def blearg1
            NAME.split( SEP ).last
          end

          def blearg2
            RX.match( NAME )[ 1 ]
          end
        end

        NAME = name
        RX = /([^:]+)$/
        SEP = '::'
      end
    end
  end
end

n = 5e5.to_i
thing = Foo::Bar::Baz::Wick
fail('blearg1 fail') unless thing.blearg1 == "Wick"
fail('blearg2 fail') unless thing.blearg2 == "Wick"
Benchmark.bm(7) do |x|
  x.report("regexp")  { n.times do; thing.blearg2; end }
  x.report("split")   { n.times do; thing.blearg1; end }
end
