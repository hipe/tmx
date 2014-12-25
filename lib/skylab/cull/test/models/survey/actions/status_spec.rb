require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey status" do

    if false

    extend TS_

    as :no_cull, /\Ano cull config file found in \. or 3 levels up\.\z/, :nonstyled
    as :invite_specific, /\Atry wtvr status -h for help\.\z/i, :styled

    it "from inside an empty directory, explains the situation" do

      from_inside_empty_directory do

        invoke 'st'

        expect :no_cull, :invite_specific

      end
    end

    as :active_is,
      %r{\Aactive config file is: #{ PN_ }\z}, :nonstyled

    it "from inside a directory with a nerk, explains it all" do

      from_inside_a_directory_with( :some_config_file ) do

        invoke 'st'

        expect :active_is

      end
    end
    end
  end
end
