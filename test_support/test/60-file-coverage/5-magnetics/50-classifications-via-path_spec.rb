require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] file-coverage - magnetics - classifications via path" do

    TS_[ self ]
    use :want_event
    use :file_coverage

    it "(the subsystem loads)" do  # stowed away here b.c this file is first
      subsystem_
    end

    it "loads" do
      _subject_magnetic
    end

    it "path does not exist" do

      given do
        test_dir_is_test_dir_one
        @path = fixture_tree :one, 'i-dont-exist.file'
      end

      want_not_OK_event :resource_not_found do |ev|
        ::File.basename( ev.path ) == 'i-dont-exist.file' || fail
      end

      want_fail
    end

    it "path is a test file" do

      given do
        test_dir_is_test_dir_one
        @path = fixture_tree :one, 'test', 'foo_speg.kode'
      end

      want :test, :file
    end

    it "path is an asset file" do

      given do
        test_dir_is_test_dir_one
        @path = fixture_tree :one, 'foo.kode'
      end

      want :asset, :file
    end

    it "path is a non-root test directory" do

      given do
        test_dir_is_test_dir_two
        @path = fixture_tree :two, 'test', 'dir-A'
      end

      want :test, :directory, :non_root
    end

    it "path is a non-root asset directory" do

      given do
        test_dir_is_test_dir_two
        @path = fixture_tree :two, 'dir-A-'
      end

      want :asset, :directory, :non_root
    end

    it "path is the root test directory" do

      given do
        test_dir_is_test_dir_one
        @path = fixture_tree :one, 'test'
      end

      want :test, :directory, :root
    end

    it "path is the root asset directory" do

      given do
        test_dir_is_test_dir_one
        @path = fixture_tree :one
      end

      want :asset, :directory, :root
    end

    # --

    def given

      yield

      _td = remove_instance_variable :@test_dir
      _pa = remove_instance_variable :@path
      _p = event_log.handle_event_selectively

      @result = _subject_magnetic[ _td, _pa, & _p ]
      NIL
    end

    td1 = nil
    define_method :test_dir_is_test_dir_one do
      td1 ||= _same :one
      @test_dir = td1 ; nil
    end

    td2 = nil
    define_method :test_dir_is_test_dir_two do
      td2 ||= _same :two
      @test_dir = td2 ; nil
    end

    def _same sym
      fixture_tree sym, Home_::Init.test_directory_entry_name
    end

    def want testiness_symbol, shape_symbol, rootiness_symbol=nil

      if @result
        x = @result.difference_against testiness_symbol, shape_symbol, rootiness_symbol
        x and fail x.description
        want_no_events
      else
        fail "expected result, had none"
      end
    end

    alias_method :_subject_magnetic, :classifications_via_path_magnetic_
  end
end
