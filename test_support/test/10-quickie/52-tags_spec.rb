require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - tags" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :quickie

    it "invalid tag - bespoke whining" do
      # -
        call :tag, "%%YIPEE%%"
        expect :error, :expression, :parse_error, :invalid_tag_expression do |y|
          y == [ %(invalid 'tag' expression: "%%YIPEE%%") ] || fail
        end
        expect_API_result_for_fail_
      # -
    end

    same_describe_for = -> a, mod do

      mod.describe do

        context "c1" do

          it "eg1" do
            a.push :eg_1_ran
          end

          it "eg2", zib_zub: true do
            a.push :eg_2_ran
          end
        end

        it "eg3", wild_card: true do
          a.push :eg_3_ran
        end

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

    context "valid, relevant tag" do

      it "ran these in this order" do
        _ran_these == [ :eg_2_ran, :eg_4_ran ] || fail
      end

      it "the counts don't count the ones that were skipped" do
        _stats.example_count == 2 || fail
      end

      shared_subject :_ran_these_and_stats do

        ran_these = []

        call(
          :load_tests_by, same_tests_for[ ran_these, self ],
          :tag, :zib_zub,
        )

        expect_example_ %w( c1 eg2 )
        expect_example_ %w( eg4 )

        _statistics = execute
        [ ran_these, _statistics ]
      end
    end

    context "one negative, one positive, AND'ed together" do

      # discussion of our policy here is at [#009.B]

      it "ran only this one" do
        _ran_these == [ :eg_2_ran ] || fail
      end

      it "counted only that one" do
        _stats.example_count == 1 || fail
      end

      shared_subject :_ran_these_and_stats do

        ran_these = []

        call(
          :load_tests_by, same_tests_for[ ran_these, self ],
          :tag, :zib_zub,
          :tag, "~shib_shub", # <-
        )

        expect_example_ %w( c1 eg2 )

        _statistics = execute
        [ ran_these, _statistics ]
      end
    end

    context "integrate with CLI - bad tag" do

      it "whines about invalid tag, invites" do
        _state
      end

      it "does not even evaluate the `describe` block" do
        _state.first && fail
      end

      shared_subject :_state do

        seen = false

        run_the_tests_thru_a_CLI_expecting_everything_on_STDERR_ do |o|

          o.receive_test_support_module_by = -> mod do

            mod.describe "c1" do
              seen = true

              it "eg1" do
                TS_._NEVER
              end
              :_do_not_interpret_this_value_with_any_significance_
            end
          end

          o.expect_lines_by = method :__expect_these_lines
        end

        [ seen ]
      end

      def __expect_these_lines o
        o.expect %(invalid --tag expression: "%%MAZINGA%%")
        o.expect "try 'ruby sperk.kd -h' for help"
      end

      def ARGV_
        %w( --tag %%MAZINGA%% )
      end
    end

    context "integrate with CLI - normal" do

      it "output is as expected, line-by-line" do
        _state || fail
      end

      it "ran the approps examples" do
        _state == [ :eg_2_ran ] || fail
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

        o.expect "Run options:"
        o.expect "  include {:zib_zub=>true}"
        o.expect "  exclude {:shib_shub=>true}"
        o.expect
        o.expect EMPTY_S_  # <- this one might an accident (the root node with no desc)?
        o.expect                "  c1"
        o.expect_styled_content "    eg2", :green
        expect_finished_line_ o
        o.expect_styled_content "1 example, 0 failures", :green
      end

      def ARGV_
        %w( --tag=~shib_shub --tag zib_zub )
      end
    end

    # ==

    def _ran_these
      _ran_these_and_stats.fetch 0
    end

    def _stats
      _ran_these_and_stats.fetch 1
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
  end
end
# #born
