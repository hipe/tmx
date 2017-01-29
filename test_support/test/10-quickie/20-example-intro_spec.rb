require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - example intro" do

    # temporary note: this test was introduced now only to confirm that we
    # can run multiple tests with r.s by naming them on the command line
    # (these seems fairly certain). this is something we may or may not
    # try to support with core quickie (as opposed to the quickie "recursive
    # runner") when we flip to self-support pretty soon here (at -0.847)

    TS_[ self ]
    use :memoizer_methods
    use :quickie

    context "one context with one example, no tests" do

      it "output is as expected, line-by-line" do
        _state || fail
      end

      it "ran the example (once)" do
        _state == [ :_ran_it_ ] || fail
      end

      shared_subject :_state do
        run_the_tests_
      end

      def given_this_test_file_ mod

        a = []
        mod.describe "desc 1" do

          context "ctxt 1" do

            it "eg 1" do
              a.push :_ran_it_
            end
          end
        end
        a
      end

      def expect_these_lines_ o
        o.expect                "desc 1"
        o.expect                "  ctxt 1"
        o.expect_styled :green, "    eg 1"
        _expect_finished_line o
        o.expect_styled :green, "1 example, 0 failures"
      end
    end

    def _expect_finished_line o
      o.expect %r(\A\nFinished in \d+(?:\.\d+)? seconds?\z)
    end

    def run_the_tests_

      _lib = Zerk_test_support_[]::Non_Interactive_CLI::Fail_Early

      exp = _lib::SingleStreamExpectations.define do |o|
        expect_these_lines_ o
      end

      sess = exp.to_assertion_session_under self

      @STDERR = sess.downstream_IO_proxy

      rt = build_runtime_
      _svc = hackishly_start_service_ rt
      mod = build_new_sandbox_module_
      rt.__enhance_test_support_module_with_the_method_called_describe mod

      x = given_this_test_file_ mod  # <- runs the tests

      sess.finish

      x
    end

    def stderr_
      remove_instance_variable :@STDERR
    end

    # ==

    def toplevel_module_
      toplevel_module_with_rspec_not_loaded_
    end

    def kernel_module_
      kernel_module_with_rspec_not_loaded_
    end

    # ==
  end
end
# #born: years later
