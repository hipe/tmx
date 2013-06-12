module Skylab::TMX

  class CLI::Client

    namespace :regret, -> do

      require 'skylab/test-support/core'

      ::Skylab::TestSupport::Regret::CLI::Client

    end, :skip, false

  end

  module Modules::Regret
    # nothing.
  end
end
