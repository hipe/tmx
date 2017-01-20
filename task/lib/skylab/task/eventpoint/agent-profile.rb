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

      # ~ dispatcher ancillaries

      class Step

        def initialize sym, pu_d
          @_ast_a = nil
          @plugin_idx = pu_d
          @transition_symbol = sym
        end

        attr_reader :plugin_idx, :transition_symbol

        attr_accessor :does_process_input, :is_last_to_process_input

        def accept_assignments__ ast_a
          @_ast_a = ast_a
        end

        def write_actuals_into_plugin de
          if @_ast_a
            @_ast_a.each do | ast |
              if ast.arg_cat_s
                de.instance_exec( * ast.args, & ast.block )
              else
                de.instance_exec( * ast.args, & ast.block )  # etc
              end
            end
          end
          nil
        end
      end

      # ~ for collaborators

      class Find_plan  # #storypoint-01

        def initialize actuals_known, traversals, state_machine, indexes, & p

          @actuals_known = actuals_known
          @all_capabilities = indexes.all_capabilities
          @on_event_selectively = p
          @plugin_a = indexes.plugin_a
          @state_machine = state_machine
          @traversals = traversals

          # ~ used in calculation:

          @formals_used = {}
          @step_a = []
        end

        def execute
          ok = __resolve_initial_plan
          ok &&= __check_for_unused_actuals
          ok && @step_a
        end

        def __resolve_initial_plan
          ok = true
          sm = @state_machine
          tv = @traversals
          begin

            sym = sm.state_symbol

            if FINISHED___ == sym
              break
            end

            a = tv[ sym ]
            if a
              @found_via_catalysm = true
            else

              a = @all_capabilities[ sm.state_symbol ] || EMPTY_A_
              @found_via_catalysm = false
            end

            case 1 <=> a.length
            when 0
              ok = __into_plan_add_step a.fetch 0
              ok or break
            when 1
              self.__TODO_when_no_step
            when -1
              __when_ambiguous a
              ok = UNABLE_
              break
            end

            redo
          end while nil
          ok
        end

        FINISHED___ = :finished

        def __when_ambiguous a

          @on_event_selectively.call :error, :event, :ambiguous_next_step do
            Me_::Events_::Ambiguous_Next_Step.new_with(
              :steps, a, :plugin_a, @plugin_a, :digraph, @state_machine.digraph )
          end
          nil
        end

        def __into_plan_add_step step

          __prepare_actuals_for_step step

          tr_sym = step.transition_symbol

          sym_ = @state_machine.digraph.target_state_of_transition tr_sym

          if @state_machine.state_symbol == sym_
            self._WAHOO  # remove it from @caps or @x.traversals per
              # @found_via_catalysm
          else
            @state_machine.accept_transition tr_sym
          end

          @step_a.push step

          ACHIEVED_
        end

        def __prepare_actuals_for_step step

          ast_a = nil
          pu_h = @actuals_known[ step.transition_symbol ]
          if pu_h

            pairs = pu_h.delete step.plugin_idx  # delete.

            if pu_h.length.zero?
              @actuals_known.delete step.transition_symbol
            end

            if pairs

              de = @plugin_a.fetch step.plugin_idx

              pairs.each_slice 2 do | args, formal_path_x |

                fo = de.formal_via_formal_path_ formal_path_x

                @formals_used[ fo.local_identifier_x ] = true

                p = fo.block
                p or next

                ast_a ||= []
                ast_a.push Assignment___.new(
                  args, fo.arg_category_string, p )

              end

              step.accept_assignments__ ast_a
            end
          end
          nil
        end

        Assignment___ = ::Struct.new :args, :arg_cat_s, :block

        def __check_for_unused_actuals

          bx = nil  # formal id x to array of plugins

          @actuals_known.each_pair do | tr_sym, pu_id_to_pairs |

            pu_id_to_pairs.each_pair do | pu_id, pairs |

              de = @plugin_a.fetch pu_id

              pairs.each_slice 2 do | args, formal_path_x |

                fo = de.formal_via_formal_path_ formal_path_x

                @formals_used[ fo.local_identifier_x ] and next

                bx ||= Common_::Box.new

                bx.touch_array_and_push fo.local_identifier_x,
                  Unused___.new( de.plugin_index, fo )
              end
            end
          end

          if bx
            @on_event_selectively.call :error, :event, :unused_actuals do
              Me_::Events_::Unused_Actuals.new_with(
                :box, bx, :steps, @step_a, :plugins, @plugin_a )
            end
            UNABLE_
          else
            ACHIEVED_
          end
        end

        Unused___ = ::Struct.new :plugin_idx, :formal

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
        @SOMETHING = []
      end

      def __add_ability_transition_ from_sym, dest_sym
        _ft = AbilityFormalTransition___.new from_sym, dest_sym
        @SOMETHING.push _ft
        NIL
      end

      def __add_required_transition_ from_sym, dest_sym
        _ft = RequiredFormalTransition___.new from_sym, dest_sym
        @SOMETHING.push _ft
        NIL
      end

      def finish
        remove_instance_variable( :@SOMETHING ).freeze
      end
    end

    # -
      def initialize anything_you_want
        @ANYTHING_YOU_WANT = nil
      end
    # -

    AgentProfileFormalTransition__ = ::Class.new

    class RequiredFormalTransition___ < AgentProfileFormalTransition__

    end

    class AbilityFormalTransition___ < AgentProfileFormalTransition__

    end

    class AgentProfileFormalTransition__
      def initialize from_sym, dest_sym
        @destination_symbol = dest_sym
        @from_symbol = from_sym
        freeze
      end
      attr_reader(
        :from_symbol,
        :destination_symbol,
      )
    end
    # ==
  end
end
# :#tombstone-A: (could be temporary) remove legacy code we are about to rewrite
