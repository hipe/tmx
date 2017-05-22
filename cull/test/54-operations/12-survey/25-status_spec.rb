require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - survey - status" do

    TS_[ self ]
    use :expect_event

# (1/N)
    it "with a noent path" do
      against ::File.join TS_.dir_path, 'no-ent'
      expect_not_OK_event_ :start_directory_does_not_exist
      expect_fail
    end

# (2/N)
    it "with a path that is a file" do
      against __FILE__
      expect_not_OK_event :start_directory_is_not_directory
      expect_fail
    end

# (3/N)
    it "with a path that is a directory but workspace not found" do
      against TestSupport_::Fixtures.directory :empty_esque_directory
      expect_not_OK_event :resource_not_found
      expect_fail
    end

# (4/N)
    it "with a workspace with no datappoints" do
      against fixture_directory_ :freshly_initted
      scn = @result
      x = scn.gets
      x.should be_nil
    end

# (5/N)
    it "with an upstream 'foo'" do
      count = 0
      y = []
      against fixture_directory_ :upstream_foo
      scn = @result
      expag = expression_agent_for_expect_emission_normally
      begin
        o = scn.gets
        o || break
        count += 1
        o.express_into_under y, expag
        redo
      end while above
      count.should eql 1
      y.first.should eql 'upstream (val "zippy dippy")'
    end

    def against path
      call_API :survey, :status, :path, path
    end
  end
end
