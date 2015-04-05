require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  ::Skylab::Snag::TestSupport::CLI[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module ModuleMethods
    include Constants
    def manifest_file
      Snag_::API.manifest_file
    end
  end
end
