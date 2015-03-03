require_relative '../../test-support'

module Skylab::SubTree::TestSupport::The_CLI_Modality

  ::Skylab::SubTree::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  PN_ = 'xyzzy'

  if false

  _Face_TS = ::Skylab::SubTree::TestSupport::TestLib_::Face_[]::TestSupport
  _Face_TS::CLI::Client[ MY_Tree_TS_ = self ]  # do this first

  class << self

    def expect_text emission
      txt = emission.payload_x
      txt.respond_to?( :ascii_only? ) or fail "expected text had #{ txt.class }"
      txt
    end
  end

  module InstanceMethods
    alias_method :super_invoke, :invoke  # hackily grab this
  end

  ::Skylab::SubTree::TestSupport::CLI::Actions[ TS_ = self ]  # do this 2nd
                   # we want our own `client` method to supercede the other

  set_command_parts_for_system_under_test 'my-tree'  # we are the top

  include Constants

  extend TestSupport_::Quickie

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
end
