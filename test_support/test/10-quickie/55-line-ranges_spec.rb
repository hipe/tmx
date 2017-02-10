require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - line ranges" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :quickie

    line_numbers_hack = -> mod do
      mod.extend TS_::Quickie::Indicated_Line_Ranges::TheseModuleMethods
      NIL
    end

    same_describe_for = -> a, mod do

      mod.describe do

        line_numbers_hack[ self ]

        context "c1" do

          _hack_next_line_number 5

          it "eg1" do
            a.push :eg_1_ran
          end

          _hack_next_line_number 10

          it "eg2", zib_zub: true do
            a.push :eg_2_ran
          end
        end

        _hack_next_line_number 15

        it "eg3", wild_card: true do
          a.push :eg_3_ran
        end

        _hack_next_line_number 20

        it "eg4", zib_zub: true, shib_shub: true do
          a.push :eg_4_ran
        end

        :_do_not_interpret_this_value_with_any_significance_
      end
    end

    same_tests_for = -> a, real_ctx do
      -> rt do
        _mod = real_ctx.enhanced_module_via_runtime_ rt
        same_describe_for[ a, _mod ]
      end
    end

    it "not look like integer" do

      call :from, '-3woot'
      expect :error, :expression, :parse_error, :must_be_digit do |y|
        y == [ "'from' must be digit" ] || fail
      end
      expect_API_result_for_fail_
    end

    it "look like negative integer" do

      call :to, '-1'
      expect :error, :expression, :parse_error, :digit_is_negative do |y|
        y == [ "'to' cannot be negative" ] || fail
      end
      expect_API_result_for_fail_
    end

    it "is zero" do

      call :line, "0"
      expect :error, :expression, :parse_error, :digit_is_zero do |y|
        y == [ "'line' cannot be zero" ] || fail
      end
      expect_API_result_for_fail_
    end

    it "two ranges are OR'ed together" do

      # -
        a = []

        call(
          :load_tests_by, same_tests_for[ a, self ],
          :from, 5, :to, 9,
          :from, 16, :to, 20,
        )

        expect_example_ %w( c1 eg1 )
        expect_example_ %w( eg4 )
        _stats = execute
        _stats.example_count == 2 || fail
        a == [ :eg_1_ran, :eg_4_ran ] || fail
      # -
    end

    it "you can use an open-ended FROM" do

      # -
        a = []

        call(
          :load_tests_by, same_tests_for[ a, self ],
          :from, 15,
        )

        expect_example_ %w( eg3 )
        expect_example_ %w( eg4 )
        _stats = execute
        _stats.example_count == 2 || fail
        a == [ :eg_3_ran, :eg_4_ran ] || fail
      # -
    end

    it "you can use a TO with an implied beginning (plus a LINE)" do

      # -
        a = []

        call(
          :load_tests_by, same_tests_for[ a, self ],
          :to, 10,
          :line, 20,
        )

        expect_example_ %w( c1 eg1 )
        expect_example_ %w( c1 eg2 )
        expect_example_ %w( eg4 )
        _stats = execute
        _stats.example_count == 3 || fail
        a == [ :eg_1_ran, :eg_2_ran, :eg_4_ran ] || fail
      # -
    end

#++F

    context "integrate with CLI - normal" do

      it "output is as expected, line-by-line" do
        _state || fail
      end

      it "ran the approps examples" do
        _state == [ :eg_1_ran, :eg_4_ran ] || fail
      end

      shared_subject :_state do

        run_the_tests_thru_a_CLI_expecting_everything_on_STDOUT_ do |o|

          o.receive_test_support_module_by = -> mod do
            a = []
            same_describe_for[ a, mod ]
            a
          end

          o.expect_lines_by = method :__expect_these_lines
        end
      end

      def __expect_these_lines o

        o.expect "Run options: include {:line_numbers=>[5,20-∞]}"
        o.expect
        o.expect EMPTY_S_  # <- this one might an accident (the root node with no desc)?
        o.expect                "  c1"
        o.expect_styled_content "    eg1", :green
        o.expect_styled_content "  eg4", :green
        expect_finished_line_ o
        o.expect_styled_content "2 examples, 0 failures", :green
      end

      def ARGV_
        %w( -5 --from=20 )
      end
    end

    # ==

    def toplevel_module_
      toplevel_module_with_rspec_not_loaded_
    end

    def kernel_module_
      kernel_module_with_rspec_not_loaded_
    end

    # ==

    def expression_agent
      subject_module_::API::TinyExpressionAgent___.instance
    end

    # ==
  end
end
# #born
