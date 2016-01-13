module Skylab::Zerk::TestSupport

  module Non_Interactive_CLI

    def self.[] tcc
      TS_::Expect_Stdout_Stderr[ tcc ]
      tcc.extend Module_Methods___
      tcc.include self
    end

    module Module_Methods___

      def given & p
        did = false ; x = nil
        define_method :_invocation_state do
          if did
            x
          else
            x = __build_invocation_state_by( & p )
            did = true
            x
          end
        end
      end
    end

    TestSupport_::Memoization_and_subject_sharing[ self ]

    # -
      # --

      def exitstatus
        _invocation_state.exitstatus
      end

      def first_line
        _lines_tuple.fetch 0
      end

      def second_line
        _lines_tuple.fetch 1
      end

      def third_and_final_line
        a = _lines_tuple
        3 == a.length or fail
        a.fetch 2
      end

      def _lines_tuple
        _invocation_state.lines_tuple
      end

      def __build_invocation_state_by & p

        @_DSL_receiver = DSL_Argument_Receiver___.new
        instance_exec( & p )
        argv, = remove_instance_variable( :@_DSL_receiver ).to_a

        using_expect_stdout_stderr_invoke_via_argv argv

        _es = remove_instance_variable :@exitstatus
        _sg = remove_instance_variable :@IO_spy_group_for_expect_stdout_stderr
        _lines = _sg.release_lines

        Invocation_State___.new _es, _lines
      end

      DSL_Argument_Receiver___ = ::Struct.new :argv

      Invocation_State___ = ::Struct.new :exitstatus, :lines_tuple

      def argv * argv
        @_DSL_receiver.argv = argv ; nil
      end

      memoize :invocation_strings_for_expect_stdout_stderr do
        [ 'xyzi' ]
      end

      # --

      def result_for_failure_for_expect_stdout_stderr
        Home_::GENERIC_ERROR_EXITSTATUS
      end
  end
end
