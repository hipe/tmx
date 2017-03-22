require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] patch - integration" do

    TS_[ self ]
    use :expect_event

    it "file against file" do

      path = produce_temporary_starting_file

      _against :target_file, path,
        :patch_file, patch_file_for_file

      _expect_common_event_pattern

      ::File.read( path ).should eql "after\n"
    end

    it "file against directory" do

      path = produce_temporary_directory

      _against :target_directory, path,
        :patch_file, patch_file_for_directory

      _expect_common_event_pattern

      ::File.read( _expected_path_that_will_be_created ).should eql "huzzah\n"
    end

    it "string against file" do

      path = produce_temporary_starting_file

      _against :target_file, path,
        :patch_string, <<-HERE.gsub( %r(^[ ]+), EMPTY_S_ )
          --- a/nosee
          +++ b/nosee
          @@ -1,1 +1,1 @@
          -before
          +after
        HERE

      _expect_common_event_pattern

      ::File.read( path ).should eql "after\n"
    end

    it "string against directory" do

      _against :target_directory, produce_temporary_directory,
        :patch_string, <<-HERE.gsub( /^[ ]+/, EMPTY_S_ )
          --- /dev/null
          +++ b/make-this-dir/one-file
          @@ -0,0 +1 @@
          +hizzie
        HERE

      _expect_common_event_pattern

      ::File.read( _expected_path_that_will_be_created ).should eql "hizzie\n"
    end

    # ~ starting files and directories & derivatives

    def produce_temporary_starting_file

      td = prepared_tmpdir
      path = td.join( 'some-file' ).to_path
      io = ::File.open( path, ::File::CREAT | ::File::WRONLY  )
      io.write "before\n"
      io.close
      path
    end

    def produce_temporary_directory

      _td = prepared_tmpdir
      path = _td.to_path
      @_last_tmpdir_path = path
      path
    end

    def prepared_tmpdir

      _path = ::File.join services_.filesystem.tmpdir_path, 'hl-xyzizzy-patch'

      Home_::Filesystem::Tmpdir.with(
        :path, _path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO,
      ).clear
    end

    # ~ patches

    def patch_file_for_file
      fixture_file_ 'patch.04-one-line.patch'
    end

    def patch_file_for_directory
      fixture_file_ 'patch.08-minimal-deep.patch'
    end

    # ~ execution

    def _against * x_a

      @result = services_.patch( * x_a, & listener_ )
      nil
    end

    # ~ expectations

    _PATCHING_FILE_RX = /\Apatching file /

    define_method :_expect_common_event_pattern do

      _em = expect_neutral_event :process_line
      line = black_and_white _em.cached_event_value
      line.should match _PATCHING_FILE_RX
      expect_succeed
    end

    # ~ expected files

    def _expected_path_that_will_be_created
      ::File.join @_last_tmpdir_path, 'make-this-dir/one-file'
    end
  end
end
