require_relative '../../../test-support'

module Skylab::GitViz::TestSupport::Models

  describe "[gv] models - hist-tree - modalities - CLI", wip: true do

    extend TS_
    use :mock_system
    use :expect_CLI

    it "help screen - expect [#br-042] back-to-front property mutation" do

      invoke 'hi', '-h'

      screen = GitViz_.lib_.brazen.test_support.CLI::Expect_Section.
        tree_via_line_stream(
          sout_serr_line_stream_for_contiguous_lines_on_stream :e )

      screen.children.map { |cx| cx.x.unstyled_header_content }.should eql(
        [ 'usage', 'options', 'argument' ] )

      screen.children.last.only_child.x.line_content.should eql 'path'

      expect_result_for_success
    end

    it "see dots (mocked)", wip: true do

      @for_expect_stdout_stderr_prepare_invocation = method :__prepare_invo

      invoke 'hi', '/derp/berp/dirzo'
      __expect_information_about_moves
      __expect_dots
      expect_succeeded
    end

    def __prepare_invo invo
      invo.receive_environment( { __system_conduit__: mock_system_conduit } )
      NIL_
    end

    def __expect_information_about_moves

      on_stream :e
      2.times do
        expect %r(\bappears\b.+informational\b)
      end

      NIL_
    end

    def __expect_dots
      expect_emissions_on_channel :o
      expect " ├everybody in the room is floating  │ •• "
      expect " ├it's just                          │"
      expect " │ └funky like that                  │• • "
      expect " └move-after                         │   •"
    end
  end
end
