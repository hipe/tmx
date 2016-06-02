require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - context multi-block - several blocks, one match" do

    TS_[ self ]
    use :memoizer_methods
    use :SES_context_lines

    # -

      given do

        str unindent_ <<-HERE
          line 1
          line 2
          ohai
          line 4
          line 5
        HERE

        rx %r(^ohai$)
      end

      during_around_match_controller_at_index 0

      context "don't engage the replacement" do

        mutate_edit_session_for_context_lines_by do
          string_edit_session_begin_
        end

        it "(the replacement looks good)" do

          expect_edit_session_output_ unindent_ <<-HERE
            line 1
            line 2
            ohai
            line 4
            line 5
          HERE
        end

        context "ask for no leading and no trailing context" do

          num_lines_before 0
          num_lines_after 0
          shared_context_lines

          it "before lines is none" do
            _before_is_none
          end

          it "after lines is none" do
            _after_is_none
          end

          it "during is legit" do
            _during_is_legit
          end
        end

        context "ask for one trailing no leading" do

          num_lines_before 0
          num_lines_after 1
          shared_context_lines

          it "before is none" do
            _before_is_none
          end

          it "during is legit" do
            _during_is_legit
          end

          it "after is legit" do
            _after_is_legit
          end
        end

        context "ask for one leading no trailing" do

          num_lines_before 1
          num_lines_after 0
          shared_context_lines

          it "before is legit" do
            _before_is_legit
          end

          it "during is legit" do
            _during_is_legit
          end

          it "after is none" do
            _after_is_none
          end
        end

        def _during_is_legit

          for_context_stream_ during_throughput_line_stream_
          for_first_and_only_line_
          expect_last_atoms_ :match, 0, :orig, :content, "ohai", :static, * _NL
        end
      end

      context "do engage the replacement" do

        mutate_edit_session_for_context_lines_by do

          es = string_edit_session_begin_
          mc = es.first_match_controller
          mc.engage_replacement_via_string 'yerp'
          es
        end

        it "(the replacement looks good)" do

          expect_edit_session_output_ unindent_ <<-HERE
            line 1
            line 2
            yerp
            line 4
            line 5
          HERE
        end

        context "ask for one leading and one trailing" do

          num_lines_before 1
          num_lines_after 1
          shared_context_lines

          it "before is legit" do
            _before_is_legit
          end

          it "during is legit" do
            _during_is_legit
          end

          it "after is legit" do
            _after_is_legit
          end
        end

        def _during_is_legit

          for_context_stream_ during_throughput_line_stream_
          for_first_and_only_line_
          expect_last_atoms_ :match, 0, :repl, :content, "yerp", :static, * _NL
        end
      end

      def _before_is_none
        expect_no_lines_in_ before_throughput_line_stream_
      end

      def _after_is_none
        expect_no_lines_in_ after_throughput_line_stream_
      end

      def _before_is_legit

        for_context_stream_ before_throughput_line_stream_
        for_first_and_only_line_
        expect_last_atoms_ :static_continuing, :content, "line 2", * _NL
      end

      def _after_is_legit

        for_context_stream_ after_throughput_line_stream_
        for_first_and_only_line_
        expect_last_atoms_ :static, :content, "line 4", * _NL
      end
    # -
  end
end
