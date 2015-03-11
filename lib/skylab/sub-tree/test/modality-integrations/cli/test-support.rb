require_relative '../../test-support'

Skylab::SubTree::TestSupport::Modality_Integrations = ::Module.new  # :+#stowaway

module Skylab::SubTree::TestSupport::Modality_Integrations::CLI

  ::Skylab::SubTree::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def subject_CLI
      SubTree_::CLI
    end

    define_method :invocation_strings_for_expect_stdout_stderr, -> do
      a = [ 'stcli' ].freeze
      -> do
        a
      end
    end.call
  end

  # ~ shorts

  NIL_ = NIL_

  SubTree_ = SubTree_

  TestSupport_ = TestSupport_

end
