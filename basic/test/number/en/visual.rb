require_relative '../../test-support'

module Skylab::Basic::TestSupport_Visual

  class Number

    class EN

      _Execute = -> stderr do

        # <- 3

  # visual-test only! see also unit tests

  fun = ::Skylab::Basic::Number::EN

  number = fun.number

  num2ord = fun.num2ord

  method = nil

  print = -> x do

    stderr.puts "#{ '%9d' % x }:-->#{ method[ x ] }<--"
  end

  [
    ->(x) { number[ x ] },
    ->(x) { num2ord[ x ] }
  ].each do |m|
    method = m
    (0..9).each(&print)
    (10..13).each(&print)
    (14..19).each(&print)
    [20, 21, 22, 23, 24, 25, 26, 27, 28, 29].each(&print)
    [30, 31, 40, 50, 60, 70, 80, 90, 99].each(&print)
    [100, 101, 200, 203, 300, 399, 827, 998, 999].each(&print)
    [1000, 1001, 1423, 1900, 1999, 2000, 2001].each(&print)
    [42388].each(&print)
    [7000_000_000_000_000_000_000_000].each(&print)
  end
# -> 3
      end

      def initialize _i, o, e, _a
        @_e = e
        @_o = o
      end

      def receive_parent_ par, const, slug

      end

      def produce_executable_
        self
      end

      define_method :execute do
        _Execute[ @_o ]
        @_e.puts "(done with visual test)"
        true
      end
    end
  end
end
