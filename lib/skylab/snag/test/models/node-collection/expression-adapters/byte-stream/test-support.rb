require_relative '../test-support'

module Skylab::Snag::TestSupport::Models::Manifest::File

  ::Skylab::Snag::TestSupport::Models::Manifest[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def fixture_pathname basename
      TS_.dir_pathname.join "fixtures/#{ basename }"
    end
  end
end
