require_relative '../test-support'

module Skylab::TestSupport::TestSupport::Regret

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::TestSupport[ TS__ = self ]

  -> do
    part = nil
    set_command_parts_for_system_under_test do |y|
      y << part[]
    end
    part = -> do
      TestSupport_::TestSupport::TestLib_::System_pathnames_calculate[ -> do
        bin.join( supernode_binfile ).to_s
      end ]
    end
  end.call

  module InstanceMethods

    SUT_TEST_SUPPORT_MODULE_HANDLE_ = TS__  # makes the below method work

    define_method :sut_cmd_a, TestSupport_::Regret::Get_SUT_command_a_method_

  end
end
