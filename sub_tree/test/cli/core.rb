module Skylab::SubTree::TestSupport

  module CLI

    class << self

      def [] tcc, * x_a

        tcc.include self

        x_a.each do | sym |

          _const = Common_::Name.via_variegated_symbol( sym ).as_const

          Here_.const_get( _const, false )[ tcc ]
        end

      end
    end  # >>

    # -- hook-ins/outs for want stdout stderr

    def subject_CLI
      Home_::CLI
    end

    define_method :invocation_strings_for_want_stdout_stderr, -> do
      a = [ 'stcli' ].freeze
      -> do
        a
      end
    end.call

    # --

    module Want_Expression

      class << self

        def [] tcc
          tcc.include self
        end

        def instance_methods_module__
          self
        end
      end  # >>

      include TestSupport_::Want_Stdout_Stderr::Test_Context_Instance_Methods

      # (adpated from [br])

      def invoke * argv
        using_want_stdout_stderr_invoke_via_argv argv
      end

      -> do

        generic_exitstatus = 5  # meh

        define_method :want_errored_generically do
          want_no_more_lines
          @exitstatus.should eql generic_exitstatus
        end

      end.call  # etc

      def want_succeed
        want_no_more_lines
        want_success_result
      end

      def want_success_result
        @exitstatus.should be_zero
      end
    end

    Here_ = self
  end
end
