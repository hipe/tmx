require_relative '../test-support'

module Skylab::TestSupport::TestSupport::Models

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::TestSupport[ TS__ = self ]

  extend TestSupport_::Quickie

  def self.apply_x_a_on_child_test_node x_a, child  # ok to move up one level
    self._WHAT  # :#tombstone:
  end
end
