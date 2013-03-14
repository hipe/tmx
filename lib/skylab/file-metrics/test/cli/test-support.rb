require_relative '../test-support'
require 'skylab/face/test/cli/test-support'

module Skylab::FileMetrics::TestSupport::CLI

  ::Skylab::Face::TestSupport::CLI[ self ]  # KRAY
  ::Skylab::FileMetrics::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module ModuleMethods

    include CONSTANTS

    def sandbox_module
      # (we aren't in the business of producing modules (we aren't DSL-y, we
      # are a subproduct) so we don't need a sandbox module to populate with
      # generated nerks. Make sure we don't accidentally use the auxiliary
      # version of this method because it would populate a sandbox in a
      # strange module (the alternative would be too overwrought).
    end

    def client_class
      FileMetrics::CLI
    end

    extend MetaHell::DSL_DSL

  end

  module InstanceMethods

    include CONSTANTS

    def program_name
      'fm'
    end
  end
end
