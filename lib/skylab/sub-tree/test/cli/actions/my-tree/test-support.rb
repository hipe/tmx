require_relative '../test-support'

module Skylab::SubTree::TestSupport::CLI::Actions::My_Tree

  ::Skylab::SubTree::TestSupport::Testlib_::Face_[]::TestSupport::CLI[ self ]
    # do this first

  module InstanceMethods
    alias_method :super_invoke, :invoke  # hackily grab this
  end

  ::Skylab::SubTree::TestSupport::CLI::Actions[ TS_ = self ]  # do this 2nd
                   # we want our own `client` method to supercede the other

  set_command_parts_for_system_under_test 'my-tree'  # we are the top

  include CONSTANTS

  extend TestSupport::Quickie

  FUN = ::Struct.new( :expect_text ).new( -> emission do
    txt = emission.payload_x
    txt.respond_to?( :ascii_only? ) or fail "expected text had #{ txt.class }"
    txt
  end )

  module InstanceMethods

    SUT_TEST_SUPPORT_MODULE_HANDLE_ = TS_

    define_method :get_sut_command_a, ::Skylab::TestSupport::Regret::Get_SUT_command_a_method_

    def build_client
      build_client_for_both  # switch it from 'events' mode to this
    end

    def invoke *argv
      super( * get_sut_command_a.concat( argv ) )
    end
  end
end
