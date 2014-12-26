require_relative '../test-support'

module Skylab::Headless::TestSupport::System::Services

  describe "[hl] system services patch" do

    Expect_event_[ self ]

    extend TS_

    it "file against file" do

      path = produce_temporary_starting_file

      against :target_file, path,
        :patch_file, patch_file_for_file

      expect_common_event_pattern

      ::File.read( path ).should eql "after\n"
    end

    it "file against directory" do

      path = produce_temporary_directory

      against :target_directory, path,
        :patch_file, patch_file_for_directory

      expect_common_event_pattern

      ::File.read( expected_path_that_will_be_created ).should eql "huzzah\n"
    end

    it "string against file" do

      path = produce_temporary_starting_file

      against :target_file, path,
        :patch_string, <<-HERE.gsub( %r(^[ ]+), EMPTY_S_ )
          --- a/nosee
          +++ b/nosee
          @@ -1,1 +1,1 @@
          -before
          +after
        HERE

      expect_common_event_pattern

      ::File.read( path ).should eql "after\n"
    end

    it "string against directory" do

      against :target_directory, produce_temporary_directory,
        :patch_string, <<-HERE.gsub( /^[ ]+/, EMPTY_S_ )
          --- /dev/null
          +++ b/make-this-dir/one-file
          @@ -0,0 +1 @@
          +hizzie
        HERE

      expect_common_event_pattern

      ::File.read( expected_path_that_will_be_created ).should eql "hizzie\n"
    end

    # ~ starting files and directories & derivatives

    def produce_temporary_starting_file
      td = prepared_tmpdir
      path = td.join( 'some-file' ).to_path
      io = ::File.open( path, Headless_::WRITE_MODE_ )
      io.write "before\n"
      io.close
      path
    end

    def produce_temporary_directory
      @__last_tmpdir__ = prepared_tmpdir
      @__last_tmpdir__.to_path
    end

    def prepared_tmpdir

      fs = Headless_.system.filesystem

      fs.tmpdir(
        :path, fs.tmpdir_pathname.join( 'hl-xyzzy-patch' ).to_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO ).clear
    end

    # ~ patches

    def patch_file_for_file
      my_fixtures_dirname.join( 'one-line.patch' ).to_path
    end

    def patch_file_for_directory
      my_fixtures_dirname.join( 'minimal-deep.patch' ).to_path
    end

    def my_fixtures_dirname
      TS_.dir_pathname.join 'patch/fixtures'
    end

    # ~ execution

    def against * x_a

      @result = subject.patch( * x_a, & handle_event_selectively )
      nil
    end

    # ~ expectations

    _PATCHING_FILE_RX = /\Apatching file /

    define_method :expect_common_event_pattern do
      ev = expect_neutral_event :process_line
      line = black_and_white ev
      line.should match _PATCHING_FILE_RX
      expect_succeeded
    end

    def black_and_white_expression_agent_for_expect_event
      Headless_::Lib_::Bzn_[]::API.expression_agent_instance
    end

    # ~ expected files

    def expected_path_that_will_be_created
      @__last_tmpdir__.join( 'make-this-dir/one-file' ).to_path
    end
  end
end
