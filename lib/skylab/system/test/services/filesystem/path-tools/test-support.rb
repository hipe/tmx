require_relative '../test-support'

module Skylab::Headless::TestSupport::System::Services::Filesystem::Path_Tools

  ::Skylab::Headless::TestSupport::System::Services::Filesystem[ self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def subject
      super.path_tools
    end
  end
end
