require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  ::Skylab::SubTree::TestSupport[ TS_ = self, :filename, 'models/file-coverage' ]

  include Constants

  extend TestSupport_::Quickie

  Callback_ = Callback_

  module InstanceMethods

    include Callback_.test_support::Expect_event::Test_Context_Instance_Methods

  end

  Mock_Boundish___ = ::Struct.new :to_kernel

  MOCK_BOUNDISH_ = Mock_Boundish___.new :_no_kernel_

  NIL_ = nil

  Subject_ = -> do
    SubTree_::Models_::File_Coverage
  end

  TEST__ = 'test'.freeze

  TEST_FILE_PATTERNS_ = [ '*_speg.rb', '*_spek.rb' ]  # :+#ersatz-names, #change-this-in-step:10 this is not yet used but will be

end
