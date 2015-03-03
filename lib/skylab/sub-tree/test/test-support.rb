require_relative '../core'

module Skylab::SubTree::TestSupport

  SubTree_ = ::Skylab::SubTree
  Autoloader_ = SubTree_::Autoloader_

  TestSupport_ = Autoloader_.require_sidesystem :TestSupport

  TestSupport_::Regret[ self ]

  TS_ = self

  module Constants
    SubTree_ = SubTree_
    TestSupport_ = TestSupport_
  end

  extend TestSupport_::Quickie

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def subject_API
      SubTree_::API
    end
  end

  Callback_ = SubTree_::Callback_

  NIL_ = nil
end
