require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey status" do

    Expect_event_[ self ]

    extend TS_

    it "with a noent path" do
      against Cull_.dir_pathname.join( 'no-ent' ).to_path
      expect_not_OK_event :start_directory_does_not_exist
      expect_failed
    end

    it "with a path that is a file" do
      against Cull_.dir_pathname.join( 'core.rb' ).to_path
      expect_not_OK_event :start_directory_is_not_directory
      expect_failed
    end

    it "with a path that is a directory but workspace not found #egads" do
      against Cull_._lib.filesystem.tmpdir_path
      expect_not_OK_event :resource_not_found
      expect_failed
    end

    it "with a workspace with no datappoints" do
      against TS_::Fixtures::Directories[ :freshly_initted ]
      scn = @result
      x = scn.gets
      x.should be_nil
    end

    it "with an upstream 'foo'" do
      count = 0
      y = []
      against TS_::Fixtures::Directories[ :upstream_foo ]
      scn = @result
      x = scn.gets
      while x
        count += 1
        x.render_all_lines_into_under y, expression_agent_for_expect_event
        x = scn.gets
      end
      count.should eql 1
      y.first.should eql 'upstream (val "zippy dippy")'
    end

    def against path
      call_API :survey, :status, :path, path
    end
  end
end
