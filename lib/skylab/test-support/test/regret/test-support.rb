require_relative '../test-support'

module Skylab::TestSupport::TestSupport::Regret

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::TestSupport[ TS__ = self ]

  module CLI
    TS__[ self ]

    add_command_parts_for_system_under_test do |y|
    end
    TS__ = self

    module Actions
      TS__[ self ]
      add_command_parts_for_system_under_test do |y|
      end
      TS__ = self
    end
  end
  def self.apply_x_a_on_child_test_node x_a, child  # ok to move up one level
    child.const_set :TS__, child
    child.include child::Constants
    child.extend TestSupport_::Quickie
    begin
      i = x_a.shift
      i_ = TestSupport_::Callback_::Name.via_variegated_symbol( i ).as_const
      _mod = TestSupport_.const_get i_ , false
      _mod.apply_on_test_node_with_x_a_passively child, x_a
    end while x_a.length.nonzero? ; nil
  end

  -> do
    part = -> do
      lib = TestSupport_::TestSupport::TestLib_
      ( lib::System[].defaults.bin_pathname.join lib::Supernode_binfile[] ).to_path
    end

    set_command_parts_for_system_under_test do |y|
      y << part[]
    end
  end.call

  module InstanceMethods

    SUT_TEST_SUPPORT_MODULE_HANDLE_ = TS__  # makes the below method work

    define_method :sut_cmd_a, TestSupport_::Regret::Get_SUT_command_a_method_

  end
end
