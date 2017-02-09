class Skylab::Task

  class Eventpoint::AgentProfile

    # ==

    Base_Dispatcher___ = ::Class.new  # (dusted, here for now to keep the below legacy)

    class Dispatcher < Base_Dispatcher___

      def initialize resources, & oes_p

        @all_capabilities = {}

        a = []
        @_monitor = Me_::Modality_Adapters_::ARGV::Monitor.new a
        @occurrence_a = a

        super
      end

      def state_machine * tuples
        @state_machine = State_Machine___.new tuples
        nil
      end

      def receive_plugin pu_d, de

        de.each_reaction do | tr |

          tr_i = tr.transition_symbol

          tr.each_catalyzing_formal do | formal |
            _register_occurrence formal, tr_i, pu_d, true
          end

          tr.each_ancillary_formal_option do | formal |
            _register_occurrence formal, tr_i, pu_d
          end
        end

        de.each_capability do | tr |

          tr_i = tr.transition_symbol
          h = @all_capabilities

          h.fetch( @state_machine.digraph.source_state_of_transition tr_i ) do | k |
            h[ k ] = []
          end.push Step.new( tr_i, pu_d )

          tr.each_ancillary_formal_option do | formal |
            _register_occurrence formal, tr_i, pu_d
          end
        end

        super
      end

      def bound_call_via_ARGV input_x  # [pl]

        Me_::Modality_Adapters_::ARGV::Produce_bound_call.new(

          input_x, @state_machine, self, & @on_event_selectively

        ).execute
      end
    end  # Dispatcher

    # ==

    # ~ plugin exposures for collaborators

    class << self

      def express_help_into rsc, & oes_p
        Me_::Events_::Express_Help.new( rsc, & oes_p ).execute
      end
    end  # >>

    # ==

    class << self

      def define
        centrus = DefineTimeAgentProfileFormalTransitionIndex___.new
        yield Definition___.new centrus
        new centrus.finish
      end

      private :new
    end  # >>

    class PendingExecutionPool < Common_::SimpleModel  # (might move to its own file if it's prudent)

      def initialize
        @pending_executions = []
        yield self
        @pending_executions.freeze
      end

      def add_pending_task task_id_x, profile
        @pending_executions.push PendingExecution.new( task_id_x, profile )
        NIL
      end

      attr_reader(
        :pending_executions,
      )
    end

    # ==

    class PendingExecution  # 1x outside of file, by a sibling

      def initialize mixed_task_identifier, agent_profile
        @agent_profile = agent_profile
        @mixed_task_identifier = mixed_task_identifier
      end

      def to_formal_transition_stream
        Stream_[ @agent_profile.formal_transitions ]  # #here-1
      end

      attr_reader(
        :agent_profile,
        :mixed_task_identifier,
      )
    end

    # ==

    class Definition___

      def initialize centrus
        @centrus = centrus
      end

      def can_transition_from_to from_sym, dest_sym
        @centrus.__add_ability_transition_ from_sym, dest_sym
      end

      def must_transition_from_to from_sym, dest_sym
        @centrus.__add_required_transition_ from_sym, dest_sym
      end
    end

    class DefineTimeAgentProfileFormalTransitionIndex___

      def initialize
        @_formal_transitions = []  # :#here-1 there must always be some array
      end

      def __add_ability_transition_ from_sym, dest_sym
        _ft = AbilityFormalTransition___.new from_sym, dest_sym
        @_formal_transitions.push _ft
        NIL
      end

      def __add_required_transition_ from_sym, dest_sym
        _ft = RequiredFormalTransition___.new from_sym, dest_sym
        @_formal_transitions.push _ft
        NIL
      end

      def finish
        remove_instance_variable( :@_formal_transitions ).freeze
      end
    end

    # -
      def initialize a
        @formal_transitions = a
      end

      attr_reader(
        :formal_transitions,
      )
    # -

    AgentProfileFormalTransition__ = ::Class.new

    class RequiredFormalTransition___ < AgentProfileFormalTransition__

      def imperative_not_optional
        true
      end
    end

    class AbilityFormalTransition___ < AgentProfileFormalTransition__

      def imperative_not_optional
        false
      end
    end

    class AgentProfileFormalTransition__

      def initialize from_sym, dest_sym

        @destination_symbol = dest_sym
        @from_symbol = from_sym
        @is_stationary = from_sym == dest_sym
        freeze
      end

      attr_reader(
        :from_symbol,
        :destination_symbol,
        :is_stationary,
      )
    end
    # ==
  end
end
# :#tombstone-A: (could be temporary) remove legacy code we are about to rewrite
