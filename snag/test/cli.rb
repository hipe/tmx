module Skylab::Snag::TestSupport

  module Expect_CLI

    class << self

      def new_with * x_a
        Modifiers___.new x_a
      end
    end  # >>

    class Modifiers___

      def initialize x_a
        @p_a = []
        x_a.each_slice 2 do | sym, x |
          send :"__#{ sym }__", x
        end
      end

      def [] tcm

        tcm.extend Module_Methods___

        tcm.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
        tcm.send :define_method, :expect, tcm.instance_method( :expect )  # :+#this-rspec-annoyance
        tcm.include Expect_CLI_
        @p_a.each do | p |
          p[ tcm ]
        end
        NIL_
      end

      def __generic_error_exitstatus__ p

        p_ = -> do
          x = p[]
          p_ = -> do
            x
          end
          x
        end
        @p_a.push -> tcm do

          tcm.send :define_method, :result_for_failure_for_expect_stdout_stderr do
            p_[]
          end
        end
        NIL_
      end

      def __program_name__ x

        a = [ x ].freeze

        @p_a.push -> tcm do

          tcm.send :define_method, :invocation_strings_for_expect_stdout_stderr do
            a
          end
        end
        NIL_
      end

      def __subject_CLI__ p

        @p_a.push -> tcm do

          tcm.send :define_method, :subject_CLI do
            p[]
          end
          NIL_
        end
      end
    end  # >>

    module Module_Methods___

      def use_memoized_client  # a crime

        p = -> tc do

          # the first time:

          tc.init_invocation_for_expect_stdout_stderr_  # call the original

          g = tc.IO_spy_group_for_expect_stdout_stderr
          invo = tc.invocation

          p = -> tc_ do  # subsequent times

            g.lines and fail
            g.line_a = []

            tc_.invocation = invo
            tc_.IO_spy_group_for_expect_stdout_stderr = g

            NIL_
          end
          NIL_
        end

        define_method :init_invocation_for_expect_stdout_stderr do
          p[ self ]
          NIL_
        end
      end
    end

    def invoke * argv
      using_expect_stdout_stderr_invoke_via_argv argv
    end

    def o * x_a, & p  # legacy

      if x_a.length.nonzero? || p

        x_a.unshift :styled
        expect_stdout_stderr_via_arglist x_a, & p
      else

        expect_failed
      end
    end

    Expect_CLI_ = self
  end
end
