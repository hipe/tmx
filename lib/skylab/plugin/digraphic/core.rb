module Skylab::Plugin

  class Digraphic  # see [#004]

    class Dispatcher

      def initialize resources, & oes_p

        @occurrence_a = []
        @on_event_selectively = oes_p
        @plugin_a = []
        @resources = resources

        # ~ for indexing plugins:

        @all_capabilities = {}

        @_monitor = Me_::Modality_Adapters_::ARGV::Monitor.new( @occurrence_a )
      end

      def state_machine * tuples
        @state_machine = State_Machine___.new tuples
        nil
      end

      def load_plugins_in_module mod

        _st = Callback_::Stream.via_nonsparse_array mod.constants do | const |

          mod.const_get const, false

        end

        load_plugins_in_prototype_stream _st
      end

      def load_plugins_in_prototype_stream st

        st.each do | plugin_class_like |

          add_plugin_via_prototype plugin_class_like
        end
        NIL_
      end

      def add_plugin_via_prototype plugin_class_like

        pu_d = @plugin_a.length

        pu = plugin_class_like.new_via_plugin_identifier_and_resources(
          pu_d, @resources, & @on_event_selectively )

        _accept_plugin pu_d, pu
        NIL_
      end

      def create_plugin_via_option_parser name_symbol

        pu_d = @plugin_a.length

        pu = Mutable___.new_via_name_and_plugin_identifier_and_resources(
          Callback_::Name.via_variegated_symbol( name_symbol ),
          pu_d,
          @resources )

        reac = Reaction__.new name_symbol

        sess = Formal_Edit_Session__.new [ name_symbol ] do | fo |

          reac.ancillary_formals.push fo
          NIL_
        end

        yield sess

        pu.reactions.push reac

        _accept_plugin pu_d, pu

        pu
      end

      def _accept_plugin pu_d, pu

        pu.each_reaction do | tr |

          tr_i = tr.transition_symbol

          tr.each_catalyzing_formal do | formal |
            _register_occurrence formal, tr_i, pu_d, true
          end

          tr.each_ancillary_formal_option do | formal |
            _register_occurrence formal, tr_i, pu_d
          end
        end

        pu.each_capability do | tr |

          tr_i = tr.transition_symbol
          h = @all_capabilities

          h.fetch( @state_machine.digraph.source_state_of_transition tr_i ) do | k |
            h[ k ] = []
          end.push Step.new( tr_i, pu_d )

          tr.each_ancillary_formal_option do | formal |
            _register_occurrence formal, tr_i, pu_d
          end
        end

        @plugin_a[ pu_d ] = pu
        NIL_
      end

      # ~ ( for collaborators

      attr_reader :all_capabilities, :occurrence_a, :plugin_a

      def digraph
        @state_machine.digraph
      end

      def accept & yld_p
        @_monitor.accept( & yld_p )
        NIL_
      end

      # ~ )

      def _register_occurrence formal, tr_i, pu_d, is_catalyst=nil

        # group all occurrences of all formals in all plugins by
        # however the monitor wants to group them..

        occu_idx = @occurrence_a.length
        occu = Occurrence__.new occu_idx, formal, pu_d, tr_i, is_catalyst

        @_monitor.register_occurrence occu

        @occurrence_a[ occu_idx ] = occu

        NIL_
      end

      Occurrence__ = ::Struct.new :occurrence_index, :formal, :plugin_idx,
        :transition_symbol, :is_catalyst

      def bound_call_via_ARGV input_x

        Me_::Modality_Adapters_::ARGV::Produce_bound_call.new(

          input_x, @state_machine, self, & @on_event_selectively

        ).execute
      end

      # ~ dispatcher ancillaries

      class State_Machine___  # ( :+[#ba-044] mentor )

        def initialize tuples
          @state_symbol = :started
          @digraph = State_Machine_Digraph___.new tuples
        end

        attr_reader :digraph, :state_symbol

        def accept_transition tr_sym
          @state_symbol = @digraph.target_state_of_transition tr_sym
          nil
        end
      end

      class State_Machine_Digraph___

        def initialize tuples
          @a = ::Array.new tuples.length / 3
          @h = {}
          d = -1
          tuples.each_slice 3 do | sym_a |
            d += 1
            tr = Transition___.new d, * sym_a
            @a[ d ] = tr
            @h[ tr.name_symbol ] = tr
          end
        end

        def source_state_of_transition tr_sym
          @h.fetch( tr_sym ).from_symbol
        end

        def target_state_of_transition tr_sym
          @h.fetch( tr_sym ).to_symbol
        end

        def transition tr_sym
          @h.fetch tr_sym
        end
      end

      class Transition___

        def initialize * a
          @transition_index, @from_symbol, @name_symbol, @to_symbol = a
        end

        attr_reader :transition_index, :from_symbol, :name_symbol, :to_symbol

        def name
          @__name__ ||= Callback_::Name.via_variegated_symbol( @name_symbol )
        end
      end

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

        def write_actuals_into_plugin pu
          if @_ast_a
            @_ast_a.each do | ast |
              if ast.arg_cat_s
                pu.instance_exec( * ast.args, & ast.block )
              else
                pu.instance_exec( * ast.args, & ast.block )  # etc
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

              pu = @plugin_a.fetch step.plugin_idx

              pairs.each_slice 2 do | args, formal_path_x |

                fo = pu.formal_via_formal_path_ formal_path_x

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

              pu = @plugin_a.fetch pu_id

              pairs.each_slice 2 do | args, formal_path_x |

                fo = pu.formal_via_formal_path_ formal_path_x

                @formals_used[ fo.local_identifier_x ] and next

                bx ||= Callback_::Box.new

                bx.touch fo.local_identifier_x do
                  []
                end.push Unused___.new( pu.plugin_index, fo )
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

    # ~ plugin exposures for collaborators

    class << self

      def express_help_into rsc, & oes_p
        Me_::Events_::Express_Help.new( rsc, & oes_p ).execute
      end
    end  # >>

    # ~ plugin as base class

    class << self

      def inherited cls
        cls.__inherited
        nil
      end

      protected def __inherited
        @_cap_a = nil
        @_reac_a = nil ; nil
      end

      attr_reader :_cap_a, :_reac_a

      def does transition_symbol, & dsl_p

        tr = Reaction__.new transition_symbol
        dsl_p[ tr ]
        ( @_reac_a ||= [] ).push tr
        NIL_
      end

      def can transition_symbol, & dsl_p
        tr = Capability__.new transition_symbol
        if dsl_p
          dsl_p[ tr ]
        end
        ( @_cap_a ||= [] ).push tr
        nil
      end

      alias_method :new_via_plugin_identifier_and_resources, :new
      private :new
    end  # >>

    # ~ ancillaries for plugin capabilities specification

    class Capability__

      def initialize sym
        @ancillary_formals = []
        @transition_symbol = sym
      end

      attr_reader :ancillary_formals, :transition_symbol

      def each_ancillary_formal_option & yld_p
        a = @ancillary_formals
        if a
          a.each( & yld_p ) ; nil
        end
      end

      def if_transition_is_effected & op_p

        each_option_in_as_(
          :ancillary_formals,
          @transition_symbol,
          my_symbol_,
          op_p
        ) do | op |

          @ancillary_formals.push op ; nil
        end

        NIL_
      end

      def my_symbol_
        :capabilities
      end

      def each_option_in_as_ * id_a, op_p, & op_o_p
        op_p[ Formal_Edit_Session__.new( id_a, & op_o_p ) ]
        nil
      end
    end

    class Reaction__ < Capability__

      def initialize( * )
        @catalyzing_formals = nil
        super
      end

      attr_reader :catalyzing_formals

      def each_catalyzing_formal & yld_p
        a = @catalyzing_formals
        if a
          a.each( & yld_p ) ; nil
        end
      end

      def transition_is_effected_by & op_p

        each_option_in_as_(
          :catalyzing_formals,
          @transition_symbol,
          my_symbol_,
          op_p
        )do | op |

          ( @catalyzing_formals ||= [] ).push op ; nil
        end
        nil
      end

      def my_symbol_
        :reactions
      end
    end

    class Formal_Edit_Session__

      def initialize id_prefix_x, & p
        @id_prefix_x = id_prefix_x
        @d = -1
        @op_o_p = p
      end

      def on * a, & any_p
        @op_o_p[ Me_::Modality_Adapters_::ARGV::Formal.new a,
          [ ( @d += 1 ), * @id_prefix_x ],
          & any_p ]
        nil
      end
    end

    # ~ plugin as base class (instance methods)

    def initialize plugin_index, resources, & oes_p
      @on_event_selectively = oes_p
      @plugin_index = plugin_index
      @resources = resources
    end

    attr_reader :plugin_index

    def name
      @nm ||= Callback_::Name.via_module self.class
    end

    def each_reaction & yld_p
      a = reactions
      if a
        a.each( & yld_p )
      end
      nil
    end

    def each_capability & yld_p
      a = capabilities
      if a
        a.each( & yld_p )
      end
      nil
    end

    def formal_via_formal_path_ formal_path_x

      opt_id, which, tr, c_or_r = formal_path_x

      send( c_or_r ).detect do | cap |
        tr == cap.transition_symbol
      end.send( which ).fetch opt_id  # #sorry
    end

    def reactions
      self.class._reac_a
    end

    def capabilities
      self.class._cap_a
    end

    class Mutable___ < self

      class << self

        alias_method :new_via_name_and_plugin_identifier_and_resources, :new
        public :new_via_name_and_plugin_identifier_and_resources
      end  # >>

      def initialize name, * rest
        @reactions = []
        @name = name
        super( * rest )
      end

      attr_reader :reactions, :name
    end

    Me_ = self
  end
end
