require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions
  ::Skylab::Snag::TestSupport::CLI[ Actions_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie  # try running a _spec.rb file with `ruby -w`


end
