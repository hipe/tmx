require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] output adapters - quickie (and o.a's in general)" do

    TS_[ self ]
    # use :expect_event
    # use :expect_line

    it "loads" do
      _subject
    end

    context "business module names that are { three|two|one } parts long" do

      it "three-part business path OK - note the top const is not there", wip: true do

        _against "Foo::Bar::Baz",
          "So, your example:\n",
          [ "if foo\n", "  then bar\n", "end\n" ]

        advance_to_module_line

        line.should eql "module Foo::Bar::TestSupport::Baz\n"

        expect_next_nonblank_line_is "  describe \"[ba] Baz\" do\n"

        expect_next_nonblank_line_is "    it \"your example\" do\n"

        em = @result
        em.category.should eql [ :success, :wrote ]
      end

      it "two-part business path OK - intentional redundancy with \"sigil\"", wip: true do

        _against 'WizzieWazzie::Moo_Moo',
          "THEN IT totally rocks:\n",
          [ "one line\n" ]

        advance_to_describe_line

        line.should eql "  describe \"[mm] WizzieWazzie::Moo_Moo\" do\n"

        expect_next_nonblank_line_is "    it \"totally rocks\" do\n"

      end

      it "one-part business path not OK - emits event talking about no", wip: true do

        _against 'Wazoozle',
          "it's fun:\n",
          []

        @output_s.length.should be_zero

        expect_not_OK_event :shallow_business_module_name

        expect_failed
      end

      def _against business_module_name, desc_line, code_line_a

        _oa = _subject.output_adapter false, & _handle_event_selectively  # is known dry

        _mns = mock_node_stream desc_line, code_line_a

        down_IO = TS_.testlib_.string_IO.new

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

        _text_span = _Omni_Mock_.new [ desc_line ]

        _lines = Common_::Stream.via_nonsparse_array code_line_a

        _matchdata = Home_::Models_::Example_Node::Matchdata.new nil, _lines

        _x = models_module_::Example_Node.new(
          _text_span, _matchdata )

        Common_::Stream.via_item _x
      end
    end

    context "INTEGRATION" do

      it "omg.", wip: true do

        _input_path = Home_.dir_pathname.join(
          Common_::Autoloader.default_core_file ).to_path

        _output_path = TS_.dir_pathname.join(
          'integration/final/top_spec.rb' ).to_path

        @result = Home_::API.call(
          :generate,
          :upstream_path, _input_path,
          :output_path, _output_path,
          :dry_run,
          :force,
          :output_adapter, :quickie,
          :on_event_selectively, _handle_event_selectively,
        )

        expect_neutral_event :before_editing_existing_file

        @result.category.should eql [ :success, :wrote ]
      end
    end

    def _handle_event_selectively
      event_log.handle_event_selectively
    end

    def _subject
      output_adapters_module_::Quickie
    end
  end
end
