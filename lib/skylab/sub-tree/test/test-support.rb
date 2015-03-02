require_relative '../core'

module Skylab::SubTree::TestSupport

  SubTree_ = ::Skylab::SubTree
  Autoloader_ = SubTree_::Autoloader_

  TestSupport_ = Autoloader_.require_sidesystem :TestSupport

  TestSupport_::Regret[ self ]

  TS_ = self

  extend TestSupport_::Quickie

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  NIL_ = nil
end
