module Skylab::PubSub

  # it is necessary (for both visual tests and actual usage) for e.g
  # `pub-sub viz` to be able to go from path to constant, and this is the
  # easiest way to achieve that given the break in the isomorphicism between
  # filesystem and constants graph ([#ts-011] tracks this)

  require_relative 'core'
  require_relative 'test/test-support'

  Test = TestSupport  # it's bad

end
