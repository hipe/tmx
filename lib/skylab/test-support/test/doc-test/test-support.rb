require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  ::Skylab::TestSupport::TestSupport[ TS_ = self ]

  if false  # #todo
  def self.apply_x_a_on_child_test_node x_a, child
    parent_anchor_module.apply_x_a_on_child_test_node x_a, child
  end
  end

  include Constants

  extend TestSupport_::Quickie

  TestLib_ = TestLib_

  TestSupport_ = TestSupport_

  module InstanceMethods

    def event_expression_agent
      TestSupport_::Lib_::Bzn_[]::API.expression_agent_instance
    end
  end

  module Sandboxer
    define_singleton_method :spawn do
    end
  end

  Subject_ = -> do

    TestSupport_::DocTest

  end
end
