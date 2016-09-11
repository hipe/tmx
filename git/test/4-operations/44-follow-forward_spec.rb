require_relative '../test-support'

module Skylab::Git::TestSupport

  describe "[gi] operations - follow forward" do

    TS_transitional_[ self ]
    use :memoizer_methods
    use :one_off_as_operation

    it "loads" do
      subject_one_off_CLI_
    end

    context "help screen" do

      given do
        argv '-h'
      end

      it "succeeds" do
        succeeds
      end

      it "content is probably fine" do
        a = lines
        a.first.string == "usage: gizzy [-v] <path>\n" || fail
        a.last.string.include? "some debugging info" or fail
      end
    end

    context "money" do

      given do
        argv 'fileA-2'
      end

      it "succeeds" do
        succeeds
      end

      it "looks right (2 lines)" do
        _expect "renamed to fileA-3"
        _expect "renamed to fileA-4"
        __expect_no_more_output_lines
      end

      def the_system_conduit_
        TS_::Fixture_Modules::Mock_Processes_01::Build[]
      end
    end

    def _expect part
      x = _things.gets
      if part != x
        x.should eql part
      end
    end

    def __expect_no_more_output_lines
      x = _things.gets
      if x
        fail "unexpected extra output line (with: #{ x.inspect })"
      end
    end

    def _things
      @___this_stream ||= __build
    end

    def __build
      _lines = ooao_state_.lines
      Common_::Stream.via_nonsparse_array _lines do |line|
        X_oper_ff_FOURTH_CEL_RX.match( line.string )[ :cel ]
      end
    end

    X_oper_ff_FOURTH_CEL_RX = /(?:\A(?:[^ ]+)(?:[ ][^ ]+){2}[ ])(?<cel>.+)/

    shared_subject :subject_one_off_CLI_ do
      require_oneoff_as_operation_ 'tmx-git-follow-forward'
    end
  end
end
