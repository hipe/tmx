module Skylab::Task::TestSupport

  module Eventpoint

    def self.[] tcc
      tcc.include self
    end

    # -

      def expect_failure_and_emission_from_trying_to_find_path_ pool, graph

        log = Common_.test_support::Expect_Emission::Log.for self

        _x = subject_module_::Path_via_PendingExecutionPool_and_Graph.call_by do |o|
          o.pending_execution_pool = pool
          o.graph = graph
          o.listener = log.handle_event_selectively
        end

        em = log.gets
        em_ = log.gets
        em_ && fail
        em
      end

      def find_path_ pool, graph

        subject_module_::Path_via_PendingExecutionPool_and_Graph.call_by do |o|
          o.pending_execution_pool = pool
          o.graph = graph
          o.listener = :xx
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
