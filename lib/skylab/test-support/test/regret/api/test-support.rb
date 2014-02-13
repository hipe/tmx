require_relative '../test-support'

module Skylab::TestSupport::TestSupport::Regret::API

  ::Skylab::TestSupport::TestSupport::Regret[ self ]

  def self.apply_x_a_on_child_test_node x_a, child
    parent_anchor_module.apply_x_a_on_child_test_node x_a, child
  end
end
