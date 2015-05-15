require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - output adapters - quickie ( & OA's in general )" do

    extend TS_
    use :expect_event
    use :expect_line

    it "loads" do
      subject
    end

    context "business module names that are { three|two|one } parts long" do

      it "three-part business path OK - note the top const is not there" do

        against "Foo::Bar::Baz",
          "So, your example:\n",
          [ "if foo\n", "  then bar\n", "end\n" ]

        advance_to_module_line

        line.should eql "module Foo::Bar::TestSupport::Baz\n"

        expect_next_nonblank_line_is "  describe \"[ba] Baz\" do\n"

        expect_next_nonblank_line_is "    it \"your example\" do\n"

        expect_one_event_and_neutral_result :wrote
      end

      it "two-part business path OK - intentional redundancy with \"sigil\"" do

        against 'WizzieWazzie::Moo_Moo',
          "THEN IT totally rocks:\n",
          [ "one line\n" ]

        advance_to_describe_line

        line.should eql "  describe \"[mm] WizzieWazzie::Moo_Moo\" do\n"

        expect_next_nonblank_line_is "    it \"totally rocks\" do\n"

      end

      it "one-part business path not OK - emits event talking about no" do

        against 'Wazoozle',
          "it's fun:\n",
          []

        @output_s.length.should be_zero

        expect_not_OK_event :shallow_business_module_name

        expect_failed
      end

      def against business_module_name, desc_line, code_line_a

        _oa = subject.output_adapter false, & handle_event_selectively  # is known dry

        _mns = mock_node_stream desc_line, code_line_a

        down_IO = TestSupport_::Library_::StringIO.new

        @result = _oa.against :business_module_name, business_module_name,
          :node_upstream, _mns,
          :line_downstream, down_IO

        @output_s = down_IO.string

        if do_debug
          debug_IO.puts "NEET:#{ @output_s }<---"
        end

        nil
      end

      def mock_node_stream desc_line, code_line_a

        _text_span = Omni_Mock_.new [ desc_line ]

        _lines = Callback_::Stream.via_nonsparse_array code_line_a

        _matchdata = DocTest_::
          Intermediate_Streams_::Models_::Example_Node::Matchdata.new(
            nil, _lines )

        _x = Subject_[]::Intermediate_Streams_::Models_::Example_Node.new(
          _text_span, _matchdata )

        Callback_::Stream.via_item _x
      end
    end

    context "INTEGRATION" do

      it "omg." do

        _input_path = DocTest_.dir_pathname.join(
          Callback_::Autoloader.default_core_file ).to_path

        _output_path = TS_.dir_pathname.join(
          'integration/final/top_spec.rb' ).to_path

        @result = DocTest_::API.call :generate,
          :upstream_path, _input_path,
          :output_path, _output_path,
          :dry_run,
          :force,
          :output_adapter, :quickie,
          :on_event_selectively, handle_event_selectively

        expect_neutral_event :before_editing_existing_file
        expect_neutral_event :wrote
        expect_no_more_events

      end
    end

    def subject
      Subject_[]::Output_Adapters_::Quickie
    end
  end
end
