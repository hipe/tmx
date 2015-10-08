Skylab.const_defined?( :Callback, false ) or self._SANITY

module Skylab::Callback

  # #todo - this is still needed and it's not pretty

  # it is necessary (for both visual tests and actual usage) for e.g
  # `[cb] digraph viz` to be able to go from path to constant, and this is the
  # easiest way to achieve that given the break in the isomorphicism between
  # filesystem and constants graph ([#ts-011] tracks this)

  # we could avoid the orphan by putting this in a function stowaway,
  # but we'd rather keep any trace of this mess out of the main file.

  require_relative '../../../test/test-support'

  Test = TestSupport  # ick/meh

end
