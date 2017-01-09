require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] filesystem - n11ns - upstream IO" do

    # ([#004.A] explains the numbering rational of these files.)

    TS_[ self ]
    use :filesystem_normalizations

    it "not exist" do

      against_ _not_here

      _em = expect_not_OK_event :stat_error

      black_and_white( _em.cached_event_value ).should match %r(\ANo such file or directory )

      expect_failed
    end

    it "not exist (path arg passed, name is used)" do

      _pa = Common_::Qualified_Knownness.via_value_and_symbol(
        _not_here, :wazoozie )

      @result = subject_.with(
        :qualified_knownness_of_path, _pa,
        & handle_event_selectively_ )

      _em = expect_not_OK_event :stat_error

      black_and_white( _em.cached_event_value ).should match %r(\ANo such 'wazoozie' - )

      expect_failed
    end

    def _not_here
      TestSupport_::Fixtures.file( :not_here )
    end

    it "wrong ftype" do

      against_ TestSupport_::Fixtures.directory :empty_esque_directory
      expect_not_OK_event :wrong_ftype
      expect_failed
    end

    it "exist" do

      against_ TestSupport_::Fixtures.file( :three_lines )
      expect_no_events
      kn = @result
      kn.is_known_known or fail
      io = kn.value_x
      io.gets or fail
      io.close
    end

    it "sin and file" do

      @result = subject_.with(
        :stdin, _non_interactive_stdin,
        :path, 'no-see',
        & handle_event_selectively_ )

      expect_not_OK_event :ambiguous_upstream_arguments
      expect_failed
    end

    def _non_interactive_stdin
      Home_.services.test_support::STUBS.noninteractive_STDIN_instance
    end

    def subject_
      Home_.services.filesystem :Upstream_IO
    end
  end
end
