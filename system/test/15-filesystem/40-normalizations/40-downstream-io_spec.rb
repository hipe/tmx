require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] filesystem - n11ns - downstream IO" do

    TS_[ self ]
    use :filesystem_normalizations

    it "exists, no formal force - OVERWRITES" do

      _setup_same

      against_ @_path

      _want_overwrote
    end

    it "exists, formal force, actual force is known and true" do

      _setup_same

      @result = subject_via_plus_real_filesystem_plus_listener_(
        :path, @_path,
        :force_arg, __build_force_yes_arg,
      )

      _want_overwrote
    end

    it "exists, formal force, actual force is known and false" do

      @result = subject_via_plus_real_filesystem_plus_listener_(
        :path, TestSupport_::Fixtures.file( :three_lines ),
        :force_arg, __build_force_no_arg,
      )

      _em = want_not_OK_event :missing_required_properties

      _sym = _em.cached_event_value.terminal_channel_symbol

      :missing_required_permission == _sym or fail

      want_fail
    end

    def __build_force_yes_arg

      Common_::QualifiedKnownKnown.via_value_and_symbol true, :force
    end

    def __build_force_no_arg

      Common_::QualifiedKnownKnown.via_value_and_symbol false, :force
    end

    it "no exist, dirname does not exist" do

      _path = ::File.join(
        _not_here,
        'some-file-2.txt'
      )

      against_ _path
      want_not_OK_event :parent_directory_must_exist
      want_fail
    end

    it "no exist, parent directory is file" do

      _path = ::File.join(
        TestSupport_::Fixtures.file( :three_lines ),
        'some-other-file',
      )
      against_ _path

      want_not_OK_event :exception do | ev |
        :errno_enotdir == ev.terminal_channel_symbol or fail
      end

      want_fail
    end

    it "no exist, dry run" do

      _path = _not_here

      @result = subject_via_plus_real_filesystem_plus_listener_(
        :path, _path,
        :is_dry_run, true,
      )

      want_neutral_event :before_probably_creating_new_file
      want_no_more_events

      x = @result.value
      d = x.write 'abc'
      3 == d or fail
      x.close

      ::File.exist?( _path ) and fail
    end

    def _setup_same

      td = memoized_tmpdir_.clear

      _pn = td.write 'wizzie', 'hi'

      @_path = _pn.to_path

      NIL_
    end

    def _want_overwrote

      want_neutral_event :before_editing_existing_file
      want_no_more_events

      io = @result.value
      io.write 'hey'
      io.close

      expect( ::File.read( @_path ) ).to eql 'hey'
    end

    def _not_here
      TestSupport_::Fixtures.file( :not_here )
    end

    def subject_
      Home_::Filesystem::Normalizations::Downstream_IO
    end
  end
end
