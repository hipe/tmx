require_relative '../test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph
  ::Skylab::TanMan::TestSupport::CLI::Actions[ self ]

  include CONSTANTS

  extend TestSupport::Quickie     # Quickie enabled!
                                  # try just running indiv. files with 'ruby -w'



  module InstanceMethods

    def invoke_from_dotfile_dir *args
      cd dotfile_pathname.dirname do
        client.invoke args
      end
    end

    let :names do
      output_unzip.names
    end

    let :output_unzip do
      output.unzip
    end

    let :strings do
      output_unzip.strings
    end
  end
end
