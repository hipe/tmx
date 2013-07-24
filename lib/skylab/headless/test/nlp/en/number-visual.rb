require_relative '../test-support'

module Skylab::Headless::TestSupport::NLP

  # visual-test only! see also unit tests
  fun = Headless::NLP::EN::Number::FUN
  number = fun.number
  num2ord = fun.num2ord
  method = nil
  stderr = Stderr_[]
  print = ->(x) { stderr.puts("#{'%9d' % [x]}:-->#{ method[ x ] }<--") }
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
end
