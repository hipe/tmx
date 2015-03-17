require_relative 'test-support'

module Skylab::GitViz::TestSupport::Test_Lib::Mock_FS

  describe "[gv] test lib -mock FS - pathname as fs node" do

    extend TS_

    before :all do

      class Eg_Test_Eg_Context_FS

        Mock_FS_Parent_Module__::Mock_FS[ self ]

        define_method :cache_hash_for_mock_FS, BUILD_CACHE_METHOD_[]

        def manifest_path_for_mock_FS
          COMMON_MOCK_FS_MANIFEST_PATH_
        end
      end
    end

    it "that who exists in the manifest exists" do
      tc = test_context
      @pn = tc.mock_pathname '/simple-absolut'
      expect_exist ; expect_absolute ; expect_not_directory
    end

    it "that who does not does not" do
      with_pathname 'does-not'
      expect_not_exist
    end

    it "\"relative\" paths are just paths whose first el. isn't the ''" do
      with_pathname 'simple-relatif'
      expect_exist ; expect_relative ; expect_not_directory
    end

    it "compound absolute ok" do
      with_pathname '/compound/absolut'
      expect_exist ; expect_absolute ; expect_not_directory
    end

    it "compound relative ok" do
      with_pathname 'compound/relatif'
      expect_exist ; expect_relative ; expect_not_directory
    end

    it "any path that has children is a directory" do
      with_pathname '/compound'
      expect_exist
      expect_directory
    end

    it "via hack, a path specified in the manifest with trailing '/' is dir" do
      with_pathname '/absolut/directory-hack/'
      expect_exist
      expect_absolute
      expect_directory
    end

    it "whether or not you include the trailing slash" do
      with_pathname '/absolut/directory-hack'
      expect_exist
      expect_absolute
      expect_directory
    end

    it "or even multiple slashes" do
      with_pathname 'relatif/directory-hack///'
      expect_exist
      expect_relative
      expect_directory
    end

    def with_pathname s
      @pn = resolve_pathname_from_string s ; nil
    end

    def resolve_pathname_from_string str
      test_context.mock_pathname str
    end
    def test_context_class
      Eg_Test_Eg_Context_FS
    end

    def expect_exist
      @pn.should be_exist
    end

    def expect_not_exist
      @pn.exist?.should eql false
    end

    def expect_directory
      @pn.should be_directory
    end

    def expect_not_directory
      @pn.directory?.should eql false
    end
  end
end
