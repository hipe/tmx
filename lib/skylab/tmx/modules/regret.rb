module Skylab::TMX

  class CLI

    namespace :regret, -> do

      require 'skylab/test-support/core'

      ::Skylab::TestSupport::Regret::CLI::Client

    end

  end

  module Modules::Regret
    # nothing.
  end
end
