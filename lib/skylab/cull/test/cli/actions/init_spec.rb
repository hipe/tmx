require_relative 'test-support'

module Skylab::Cull::TestSupport::CLI::Actions::Init

  ::Skylab::Cull::TestSupport::CLI::Actions[ TS_ = self ]

  include Constants

  extend TestSupport::Quickie

  describe "[cu] CLI actions - init" do

    extend TS_

    as :creating_done,
      %r{creating #{ PN_ } \.\. done \(\d\d bytes\)\.\z}i, :nonstyled

    it "from inside an empty directory, explains the situation" do

      from_inside_empty_directory do |d|

       invoke 'init'

       expect :creating_done

      end
    end

    as :exists,
      %r{\Awtvr init: exists, skipping - #{ PN_ }\z}, :nonstyled

    it "from inside a directory with a nerk, explains it all" do

      from_inside_a_directory_with( :some_config_file ) do

        invoke 'init'

        expect :exists

      end
    end
  end
end
