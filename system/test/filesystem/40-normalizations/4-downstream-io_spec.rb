require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] filesystem - n11ns - downstream IO" do

    TS_[ self ]
    use :filesystem_normalizations

    it "exists, no formal force - OVERWRITES" do

      _setup_same

      against_ @_path

      _expect_overwrote
    end

    it "exists, formal force, actual force is known and true" do

      _setup_same

      @result = subject_.with(
        :path, @_path,
        :force_arg, __build_force_yes_arg,
        & handle_event_selectively_ )

      _expect_overwrote
    end

    it "exists, formal force, actual force is known and false" do

      @result = subject_.with(
        :path, TestSupport_::Fixtures.file( :three_lines ),
        :force_arg, __build_force_no_arg,
        & handle_event_selectively_ )

      _em = expect_not_OK_event :missing_required_properties

      _sym = _em.cached_event_value.terminal_channel_symbol

      :missing_required_permission == _sym or fail

      expect_failed
    end

    def __build_force_yes_arg

      Common_::Qualified_Knownness.via_value_and_symbol true, :force
    end

    def __build_force_no_arg

      Common_::Qualified_Knownness.via_value_and_symbol false, :force
    end

    it "no exist, dirname does not exist" do

      _path = ::File.join(
        _not_here,
        'some-file-2.txt'
      )

      against_ _path
      expect_not_OK_event :parent_directory_must_exist
      expect_failed
    end

    it "no exist, parent directory is file" do

      _path = ::File.join(
        TestSupport_::Fixtures.file( :three_lines ),
        'some-other-file',
      )
      against_ _path

      expect_not_OK_event :exception do | ev |
        :errno_enotdir == ev.terminal_channel_symbol or fail
      end

      expect_failed
    end

    it "no exist, dry run" do

      _path = _not_here

      @result = subject_.with(
        :path, _path,
        :is_dry_run, true,
        & handle_event_selectively_ )

      expect_neutral_event :before_probably_creating_new_file
      expect_no_more_events

      x = @result.value_x
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

    def _expect_overwrote

      expect_neutral_event :before_editing_existing_file
      expect_no_more_events

      io = @result.value_x
      io.write 'hey'
      io.close

      ::File.read( @_path ).should eql 'hey'
    end

    def _not_here
      TestSupport_::Fixtures.file( :not_here )
    end

    def subject_
      Home_.services.filesystem :Downstream_IO
    end
  end
end
