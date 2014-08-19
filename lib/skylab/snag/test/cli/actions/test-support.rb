require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  ::Skylab::Snag::TestSupport::CLI[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  module ModuleMethods
    include CONSTANTS
    def manifest_file
      Snag_::API.manifest_file
    end
  end
end
