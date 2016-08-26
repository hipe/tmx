require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] magnetics - test directory via path" do

    TS_[ self ]
    use :expect_event

    it "loads" do
      _subject_magnetic
    end

    it "against an asset file when the root dir is not found" do

      given do
        the_asset_file
        max_num_dirs 0
      end

      expect_not_OK_event :resource_not_found do | ev |
        ev_ = ev.to_event
        ev_.start_path ==_the_asset_file_path || fail
        ev_.num_dirs_looked.zero? || fail
        ::Array.try_convert( ev_.file_pattern_x ) || fail
        ev_.ok == false || fail
      end

      expect_failed
    end

    it "against a test file when the root dir is not found" do

      given do
        the_test_file
        max_num_dirs 0
      end

      expect_not_OK_event :resource_not_found
      expect_failed
    end

    it "against an asset file when the root dir is found" do

      given do
        the_asset_file
        max_num_dirs 2
      end

      expect_that_the_root_is_found
    end

    it "against a test file when the root dir is found" do

      given do
        the_test_file
        max_num_dirs 2
      end

      expect_that_the_root_is_found
    end

    it "on the root dir itself - root is found" do

      given do
        path fixture_tree( :one )
        max_num_dirs 1
      end

      expect_that_the_root_is_found
    end

    it "on the test dir itself - root is found" do

      given do
        path "#{ fixture_tree :one }/test"
        max_num_dirs 1
      end

      expect_that_the_root_is_found
    end

    # ~ test setup & asset execution

    def given

      _oes_p = event_log.handle_event_selectively
      o = _subject_magnetic.new( & _oes_p )

      yield

      d = remove_instance_variable :@__max_num_dirs
      s = remove_instance_variable :@__path

      o.instance_variable_set :@max_num_dirs_to_look, d
      o.instance_variable_set :@start_path, s

      @result = o.execute
      NIL
    end

    def the_asset_file
      path _the_asset_file_path
    end

    taf = nil
    define_method :_the_asset_file_path do
      taf ||= "#{ fixture_tree :one }/foo.kode"
    end

    def the_test_file
      path _the_test_file_path
    end

    ttf = nil
    define_method :_the_test_file_path do
      ttf ||= "#{ _fixture_tree }/test/foo_speg.kode"
    end

    def path path
      @__path = path ; nil
    end

    def max_num_dirs d
      @__max_num_dirs = d ; nil
    end

    # ~ test assertion

    exp = nil
    define_method :expect_that_the_root_is_found do

      exp ||= ::File.join _fixture_tree, Home_::TEST_DIR_FILENAME_
      @result == exp || fail
    end

    ft = nil
    define_method :_fixture_tree do
      ft ||= fixture_tree :one
    end

    def _subject_magnetic
      Home_::Magnetics::TestDirectory_via_Path
    end
  end
end
