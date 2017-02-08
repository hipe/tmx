module Skylab::Task::TestSupport

  module Eventpoint

    def self.[] tcc
      tcc.include self
    end

    # -

      def against_path_expect_steps_ path
        @STEP_SCANNER = Common_::Scanner.via_array path.steps
        yield
        @STEP_SCANNER.no_unparsed_exists or fail __say_extra_step
        remove_instance_variable :@STEP_SCANNER
      end

      def expect_step_ mixed_id_x, from_sym, dest_sym
        if @STEP_SCANNER.no_unparsed_exists
          fail __say_missing_step mixed_id_x
        else
          step = @STEP_SCANNER.head_as_is
          step.mixed_task_identifier == mixed_id_x || fail
          fo_trans = step.formal_transition
          fo_trans.from_symbol == from_sym || fail
          fo_trans.destination_symbol == dest_sym || fail
          @STEP_SCANNER.advance_one
        end
      end

      def __say_missing_step x
        "expected step '#{ x }' had no more steps"
      end

      def __say_extra_step
        _ = @STEP_SCANNER.head_as_is
        "expected no more steps, had '#{ _.mixed_task_identifier }'"
      end

      def expect_failure_and_emission_when_find_path_by_

        _pool = build_pending_execution_pool_ do |o|
          yield o
        end

        expect_failure_and_emission_from_trying_to_find_path_ _pool, graph_
      end

      def find_path_by_

        _pool = build_pending_execution_pool_ do |o|
          yield o
        end

        find_path_ _pool, graph_
      end

      def expect_failure_and_emission_from_trying_to_find_path_ pool, graph

        log = build_event_log_

        _x = subject_module_::Path_via_PendingExecutionPool_and_Graph.call_by do |o|

          o.say_plugin_by = -> mixed_x, _ba_API_expag do

            # (this is a minimal example; clients will probably be more sophisticated)

            "'#{ mixed_x }'"
          end

          o.pending_execution_pool = pool
          o.graph = graph
          o.listener = log.handle_event_selectively
        end

        _x == false || fail

        em = log.gets
        em_ = log.gets
        em_ && fail
        em
      end

      def build_event_log_
        Common_.test_support::Expect_Emission::Log.for self
      end

      def find_path_ pool, graph

        subject_module_::Path_via_PendingExecutionPool_and_Graph.call_by do |o|
          o.pending_execution_pool = pool
          o.graph = graph
          o.say_plugin_by = -> * { TS_._NOT_USED_HERE }
          o.listener = :_NO_LISTENER_ta_
        end
      end

      def build_pending_execution_pool_ & p
        subject_module_::AgentProfile::PendingExecutionPool.define( & p )
      end

      def define_agent_ & p
        subject_module_::AgentProfile.define( & p )
      end

      def define_graph_ & p
        subject_module_.define_graph( & p )
      end

      def subject_module_
        Home_::Eventpoint
      end

    # -
  end
end
# #history: the last of the old code gone during major rewrite
