require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey status" do

    Expect_event_[ self ]

    extend TS_

    it "with a noent path" do
      call_API :survey, :status, :path, Cull_.dir_pathname.join( 'no-ent' ).to_path
      expect_not_OK_event :start_directory_does_not_exist
      expect_failed
    end

    it "with a path that is a file" do
      call_API :survey, :status, :path, Cull_.dir_pathname.join( 'core.rb' ).to_path
      expect_not_OK_event :start_directory_is_not_directory
      expect_failed
    end

    it "with a path that is a directory but workspace not found #egads" do
      _egads = Cull_._lib.filesystem.tmpdir_path
      call_API :survey, :status, :path, _egads
      expect_not_OK_event :resource_not_found
      expect_failed
    end

    if false

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
