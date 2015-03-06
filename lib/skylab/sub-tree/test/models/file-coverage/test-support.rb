require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  ts = ::Skylab::SubTree::TestSupport

  ts.autoloaderize_with_filename_child_node 'models/file-coverage', self

  ts[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Callback_ = Callback_

  module InstanceMethods

    include Callback_.test_support::Expect_event::Test_Context_Instance_Methods

  end

  Mock_Boundish___ = ::Struct.new :to_kernel

  MOCK_BOUNDISH_ = Mock_Boundish___.new :_no_kernel_

  NIL_ = nil

  TEST__ = 'test'.freeze

  TEST_FILE_PATTERNS_ = [ '*_speg.rb', '*_spek.rb' ]  # :+#ersatz-names, #change-this-in-step:10 this is not yet used but will be

end
