require_relative '../test-support'

module Skylab::TestSupport::TestSupport::Regret

  ::Skylab::TestSupport::TestSupport[ TestSupport_ = self ]

  part = nil
  set_command_parts_for_system_under_test do |y|
    part ||= ::Skylab::Subsystem::PATHNAMES.calculate do
      bin.join( supernode_binfile ).to_s
    end
    y << part
  end

  module InstanceMethods

    SUT_TEST_SUPPORT_MODULE_HANDLE_ = TestSupport_  # makes the below method work

    define_method :sut_cmd_a, ::Skylab::TestSupport::Regret::Get_SUT_command_a_method_

  end
end
