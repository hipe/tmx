require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions
  ::Skylab::Snag::TestSupport::CLI[ Actions_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie  # try running a _spec.rb file with `ruby -w`

  module InstanceMethods
    def invoke_from_tmpdir *argv
      from_tmpdir do
        client_invoke(* argv)
      end
    end
  end
end
