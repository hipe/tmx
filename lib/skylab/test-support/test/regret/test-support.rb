require_relative '../test-support'

module Skylab::TestSupport::TestSupport::Regret

  ::Skylab::TestSupport::TestSupport[ TS_ = self ]

  part = nil
  set_command_parts_for_system_under_test do |y|
    part ||= ::Skylab::Subsystem::PATHNAMES.calculate do
      bin.join( supernode_binfile ).to_s
    end
    y << part
  end

  module InstanceMethods

    TS_HANDLE_ = TS_

    def sut_cmd_a
      ts = nearest_indexed_test_support_module
      ts.get_command_parts_for_system_under_test_notify
    end
  end
end
