require_relative '../test-support'

module Skylab::Permute::TestSupport

  describe "[pe] non-interactive CLI - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :my_CLI

    context "  0) no args" do

      given do
        argv
      end

      it "expecting" do
        first_line.should be_line_about_expecting_compound_or_operation
      end

      it "usage" do
        second_line.should be_stack_sensitive_usage_line
      end

      it "invite" do
        last_line.should be_invite_with_argument_focus
      end
    end

    context "1.1) one wrong arg" do

      given do
        argv 'foiple'
      end

      it "unrec" do
        first_line_string.include? "unrecognized " or fail
      end

      it "did you mean" do
        second_line.string.include? "did you mean" or fail
      end
    end

    context "1.3) ping" do

      given do
        argv 'ping'
      end

      it "succeeds" do
        exitstatus.zero? || fail
      end

      it "expresses" do
        first_line_string == "hello from permute.\n" || fail
        1 == number_of_lines || fail
      end
    end

    _CMD = 'generate'

    context "  0) no args (under the generate command)" do

      given do
        argv _CMD
      end

      it "custom errmsg" do
        first_line_string.include? 'expecting categories' or fail
      end

      it "specific invite" do
        last_line.should be_invite_with_option_focus
      end
    end

    context "1.2) can't start with short" do

      given do
        argv 'gen', '-c'
      end

      it "fails" do
        fails
      end

      it "reason" do
        first_line_string == %(expecting long switch at "-c"\n) || fail
      end
    end

    context "1.2) unrec" do

      given do
        argv _CMD, '--long', 'x', '-c', 'x'
      end

      it "fails" do
        fails
      end

      it "unrec" do
        first_line_string == %(unrecognized category letter "c"\n) || fail
      end

      it "did you mean" do
        second_line.should be_line( :styled, :e, "did you mean 'long'?")
      end
    end

    context "ambiguity" do

      given do
        argv _CMD, * %w( generate --county=washtenaw --coint=pariah -c fooz )
      end

      it "custom message (lost contextualization but meh)" do
        first_line_string == %(failed because ambiguous category letter "c" - did you mean "county" or "coint"?\n)
      end

      it "invite" do
        last_line.should be_invite_with_option_focus
      end
    end

    context "2.4) help omg" do

      given do
        argv _CMD, '-h'
      end

      it "usage section doesn't have argument terms" do

        _sec = _section :usage
        _ = _sec.first_line.unstyled_styled
        _.include? 'YOUR-VALUE' or fail
        _.include? '<' and fail  # argument term
      end

      it "options have the custom description" do

        _sec = _section :options
        _sec.raw_lines.fetch(1).string.include? 'wide-open' or fail
      end

      it "there is no arguments section" do
        _coarse_parse.has_section :argument and fail
      end

      def _section k
        _coarse_parse.section k
      end

      shared_subject :_coarse_parse do
        _ = niCLI_state.lines
        Zerk_test_support_[]::Non_Interactive_CLI::Help_Screens::Coarse_Parse.new _
      end
    end

    context "so much money" do

      given do
        argv_array(
          %w(generate --flavor vanilla -fchocolate --cone sugar -cwaffle -ccup)
        )
      end

      it "succeeds" do
        succeeds
      end

      it "so much money" do

        _st = Common_::Stream.via_nonsparse_array niCLI_state.lines

        _st_ = _st.map_by do |o|
          :o == o.stream_symbol || fail
          o.string
        end

        _exp = <<-HERE.unindent
          |    flavor |   cone |
          |   vanilla |  sugar |
          |   vanilla | waffle |
          |   vanilla |    cup |
          | chocolate |  sugar |
          | chocolate | waffle |
          | chocolate |    cup |
        HERE

        _exp_st = Home_.lib_.basic::String.line_stream _exp

        TestSupport_::Expect_Line::Streams_have_same_content[ _st_, _exp_st, self ]
      end
    end
  end
end
# :+#tombstone: was [#ts-010]
