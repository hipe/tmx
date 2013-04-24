require_relative 'test-support'

module Skylab::Cull::TestSupport::CLI::Actions::Init

  ::Skylab::Cull::TestSupport::CLI::Actions[ Init_TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Cull }::CLI::Actions::Init" do

    extend Init_TS_

    as :creating_done,
      %r{creating \./\.cullconfig \.\. done \(\d\d bytes\)\.\z}i, :nonstyled

    it "from inside an empty directory, explains the situation" do

      from_inside_empty_directory do |d|

       invoke 'init'

       expect :creating_done

      end
    end

    as :exists,
      %r{\Awtvr init: exists, skipping - \./\.cullconfig\z}, :nonstyled

    it "from inside a directory with a nerk, explains it all" do

      from_inside_a_directory_with( :some_config_file ) do

        invoke 'init'

        expect :exists

      end
    end
  end
end
