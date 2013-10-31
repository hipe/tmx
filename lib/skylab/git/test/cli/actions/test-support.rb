require_relative '../../../core'

require 'skylab/test-support/core'

module Skylab::Git::TestSupport

  module Actions

    ::Skylab::TestSupport::Regret[ self ]

    module CONSTANTS

      ::Skylab::MetaHell::FUN::Import_constants[ ::Skylab,
        %i| Git Headless TestSupport |, self ]

    end
  end
end
