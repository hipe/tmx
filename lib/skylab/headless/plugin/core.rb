module Skylab::Headless

  class Plugin  # [#077] (top half)

    class Dispatcher

      def initialize resources, & oes_p

        @occurrence_a = []
        @on_event_selectively = oes_p
        @plugin_a = []
        @resources = resources

        # ~ for indexing plugins:

        @all_capabilities = {}
        @long_to_short_long_combo = {}
        @short_long_combo_a = []
        @short_long_combo_occurrence_a = []
        @short_long_combo_occurrence_h = {}
        @short_to_short_long_combo = {}
      end

      def state_machine * tuples
        @state_machine = State_Machine___.new tuples
        nil
      end

      def load_plugins_in_module mod

        pu_d = nil

        digraph = @state_machine.digraph

        mod.constants.each do | const |

          pu_d = @plugin_a.length

          pu = mod.const_get( const, false ).new pu_d, @resources,
            & @on_event_selectively

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

            h.fetch( digraph.source_state_of_transition tr_i ) do | k |
              h[ k ] = []
            end.push Step.new( tr_i, pu_d )

            tr.each_ancillary_formal_option do | formal |
              _register_occurrence formal, tr_i, pu_d
            end
          end

          @plugin_a.push pu

        end
        nil
      end

      # ~ ( for collaborators

      attr_reader :all_capabilities, :occurrence_a, :plugin_a

      def digraph
        @state_machine.digraph
      end

      def each_short_long_combo & yld_p
        @short_long_combo_a.each( & yld_p ) ; nil
      end

      # ~ )

      def _register_occurrence formal, tr_i, pu_d, is_catalyst=nil

        # group all occurrences of all formals in all plugins by their
        # short-long combination ensuring there are no conflicts.

        occu_idx = @occurrence_a.length
        occu = Occurrence__.new occu_idx, formal, pu_d, tr_i, is_catalyst

        short_a = formal.short_id_s_a
        long = formal.long_id_s

        if short_a
          __note_any_short_long_combos_that_have_these_shorts short_a
        end

        if long
          __note_any_short_long_combos_that_has_this_long long
        end

        case 1 <=> @short_long_combo_occurrence_a.length
        when  1
          __this_is_a_new_short_long_combo_never_seen_before occu
        when 0
          __maybe_add_this_occurrence_to_the_short_long_combo occu
        else
          self.__TODO_never_OK_this_occurrence_matches_several_existing_SLCs
        end

        @short_long_combo_occurrence_a.clear
        @short_long_combo_occurrence_h.clear

        @occurrence_a[ occu_idx ] = occu
        nil
      end

      Occurrence__ = ::Struct.new :occurrence_index, :formal, :plugin_idx,
        :transition_symbol, :is_catalyst

      def __note_any_short_long_combos_that_have_these_shorts s_a

        h = @short_to_short_long_combo

        s_a.each do | short |

          idx = h[ short ]
          if idx && ! @short_long_combo_occurrence_h[ idx ]
            @short_long_combo_occurrence_a.push idx
            @short_long_combo_occurrence_h[ idx ] = true
          end
        end

        nil
      end

      def __note_any_short_long_combos_that_has_this_long long

        idx = @long_to_short_long_combo[ long ]

        if idx && ! @short_long_combo_occurrence_h[ idx ]
          @short_long_combo_occurrence_a.push idx
          @short_long_combo_occurrence_h[ idx ] = true
        end

        nil
      end

      def __this_is_a_new_short_long_combo_never_seen_before occu

        formal = occu.formal
        shorts = formal.short_id_s_a
        long = formal.long_id_s

        my_index = @short_long_combo_a.length

        slc = Short_Long_Combo___.new(
          my_index, shorts, long, [ occu.occurrence_index ] )

        if shorts
          shorts.each do | short_s |
            @short_to_short_long_combo[ short_s ] = my_index
          end
        end

        if long
          @long_to_short_long_combo[ long ] = my_index
        end

        @short_long_combo_a[ my_index ] = slc

        nil
      end

      Short_Long_Combo___ = ::Struct.new(
        :SLC_index, :shorts, :long, :occurrences )

      def __maybe_add_this_occurrence_to_the_short_long_combo occu

        # assume exactly one existing short long combo is on deck

        slc = @short_long_combo_a.fetch @short_long_combo_occurrence_a.fetch 0

        diff = occu.formal.build_LR_difference_against(
          @occurrence_a.fetch( slc.occurrences.fetch 0 ).formal )

        if diff
          self.__TODO_when_incompatible_differences diff
        else
          slc.occurrences.push occu.occurrence_index
        end
        nil
      end

      def bound_call_via_ARGV input_x

        Plugin_::ARGV__::Produce_bound_call.new(

          input_x, @state_machine, self, & @on_event_selectively ).execute
      end

      # ~ dispatcher ancillaries

      class State_Machine___

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
            Plugin_::When_::Ambiguous_Next_Step.new_with(
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
              Plugin_::When_::Unused_Actuals.new_with(
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
        Plugin_::When_::Express_Help.new( rsc, & oes_p ).execute
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
        nil
      end

      def can transition_symbol, & dsl_p
        tr = Capability__.new transition_symbol
        if dsl_p
          dsl_p[ tr ]
        end
        ( @_cap_a ||= [] ).push tr
        nil
      end
    end  # >>

    # ~ ancillaries for plugin capabilities specification

    class Capability__

      def initialize sym
        @ancillary_formals = nil
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

          ( @ancillary_formals ||= [] ).push op ; nil
        end

        nil
      end

      def my_symbol_
        :capabilities
      end

      def each_option_in_as_ * id_a, op_p, & op_o_p
        op_p[ Formal_Edit_Session___.new( id_a, & op_o_p ) ]
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

    class Formal_Edit_Session___

      def initialize id_prefix_x, & p
        @id_prefix_x = id_prefix_x
        @d = -1
        @op_o_p = p
      end

      def on * a, & any_p
        @op_o_p[ Plugin_::ARGV__::Formal.new a,
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
      a = self.class._reac_a
      if a
        a.each( & yld_p )
      end
      nil
    end

    def each_capability & yld_p
      a = self.class._cap_a
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

    Plugin_ = self

      # ~ legacy below here -- see [#077] (bottom half)

      Host = -> cls do
        cls.extend Host_Module_Methods__
        cls.include Host_Instance_Methods__ ; nil
      end

      Callback = Headless_::Library_::Callback

      module Host_Module_Methods__

        define_method :build_mutable_callback_tree_specification,
          Callback::Tree::Methods::
            Build_mutable_callback_tree_specification

        def plugin_conduit_class
          if const_defined? :Plugin_Conduit, false
            self::Plugin_Conduit
          elsif const_defined? :Plugin_Conduit
            const_set :Plugin_Conduit, ::Class.new( self::Plugin_Conduit )
          else
            const_set :Plugin_Conduit, ::Class.new( Plugin_Conduit_ )
          end
        end
      end

      module Host_Instance_Methods__
      private

        def load_plugins
          @plugin_conduit_h = {}
          init_plugin_callbacks_if_necessary
          shell = plugin_conduit_cls.new @y, self
          box_mod = plugin_box_module
          box_mod.constants.each do |const_i|
            name = Callback_::Name.via_const const_i
            WHITE_SLUG_RX__ =~ name.as_slug or next
            cond = shell.curry name
            plugin = box_mod.const_get( name.as_const, false ).new cond
            cond.plugin = plugin
            idx_plugin cond
          end
          init_plugins
        end ; WHITE_SLUG_RX__ = /\A[a-z]/

        def init_plugin_callbacks_if_necessary
          @callbacks ||= bld_plugin_listener_matrix
        end

        def bld_plugin_listener_matrix
          self.class.const_get( :Callback_Tree__, false ).new
        end

        def plugin_conduit_cls
          self.class.plugin_conduit_class
        end

        def plugin_box_module
          if self.class.const_defined? PLUGIN_BOX__, false
            self.class.const_get PLUGIN_BOX__, false
          else
            vivify_autoloading_plugin_box
          end
        end ; PLUGIN_BOX__ = :Plugins__

        def vivify_autoloading_plugin_box
          mod = self.class.const_set PLUGIN_BOX__, ::Module.new
          Callback::Autoloader[ mod, :boxxy ]
          mod
        end

        def idx_plugin cond
          k = cond.name.as_variegated_symbol ; did = false
          callbacks = @callbacks
          cond.plugin.class.instance_methods( false ).each do |m_i|
            ON_RX__ =~ m_i or next
            did ||= true
            callbacks.add_callback_reference m_i, k
          end
          @plugin_conduit_h[ k ] = cond ; nil
        end
        ON_RX__ = /\Aon_/

        def init_plugins
          init_option_parser_by_aggregating_plugin_options
        end

        def init_option_parser_by_aggregating_plugin_options
          @op = Headless_::Library_::OptionParser.new
          write_plugin_host_option_parser_options  # :+#hook-out
          write_plugin_option_parser_options @op
          write_plugin_host_option_parser_help_option  # :+#hook-out
          PROCEDE__
        end

        def write_plugin_option_parser_options up_op
          call_plugin_listeners :on_build_option_parser do |plugin_i|
            cond = @plugin_conduit_h.fetch plugin_i
            _op = Plugin_Option_Parser_Proxy_.new( a = [] )
            cond.plugin.on_build_option_parser _op
            Plugin_Option_Parser_Playback_.new( @y, up_op, cond, a ).playback
          end
        end

        # read #storypoint-50 intro to "callback tree" event handling patterns

        def call_plugin_listeners m_i, * a, & p
          p = nrmlz_callback_map_args m_i, a, p
          @callbacks.call_listeners_with_map m_i, p
        end

        def call_plugin_shorters m_i, * a, & p  # #storypoint-60
          p = nrmlz_callback_map_args m_i, a, p
          @callbacks.call_shorters_with_map m_i, p
        end

        def attempt_with_plugins m_i, * a, & p  # #storypoint-65
          p = nrmlz_callback_map_args m_i, a, p
          @callbacks.call_attempters_with_map m_i, p
        end

        def nrmlz_callback_map_args m_i, a, p
          a.length.nonzero? and p and raise ::ArgumentError
          p || -> plugin_i do
            @plugin_conduit_h.fetch( plugin_i ).plugin.send m_i, * a
          end
        end

        def call_every_plugin_shorter m_i, * a  # #storypoint-75
          @callbacks.aggregate_any_shorts_with_map m_i, -> plugin_i do
            @plugin_conduit_h.fetch( plugin_i ).plugin.send m_i, * a
          end
        end

        PROCEDE__ = nil
      end

      class Plugin_Conduit_  # see [#sy-005]:#understanding-plugin-shells
        def initialize y, real
          @up_p = -> { real }
          @stderr_line_yielder = y
        end
        attr_accessor :plugin
        attr_reader :stderr_line_yielder
        def curry name
          otr = dup
          otr.initialize_curry name
          otr
        end
        def initialize_copy otr
          @stderr_line_yielder = otr.stderr_line_yielder
        end
        def initialize_curry name
          @name = name
        end
        attr_reader :name

        def get_qualified_stderr_line_yielder
          y = ::Enumerator::Yielder.new do |msg_s|
            msg = Qualifiable_Message_String.new msg_s
            msg.graphic_prefix = graphic_prefix
            msg.agent_prefix = agent_prefix
            @stderr_line_yielder << "#{ msg }"
            y
          end
        end

        def get_qualified_serr
          serr_p = @up_p[].stderr_reference_for_plugin  # :+#hook-out
          Write_Proxy__.new do |s|
            msg = Qualifiable_Message_String.new s
            msg.graphic_prefix = graphic_prefix
            msg.agent_prefix = agent_prefix
            io = serr_p[]
            r = io.write "#{ msg }"
            io.flush
            r
          end
        end
        class Write_Proxy__ < ::Proc
          alias_method :write, :call
        end

      private

        def graphic_prefix
          self.class::GRAPHIC_PREFIX__
        end ; GRAPHIC_PREFIX__ = '  • '.freeze

        def agent_prefix
          "#{ @name.as_human } "
        end

        def up
          @up_p[]
        end
      end

      Qualifiable_Message_String = ::Struct.  # :+[#fa-061] "reparenthesize"
          new :graphic_prefix, :open, :agent_prefix, :body, :close
      class Qualifiable_Message_String
        def initialize msg
          if (( md = PAREN_EXPLODER_RX__.match msg ))
            super nil, md[1], nil, md[2], md[3]
          else
            super nil, nil, nil, msg
          end
        end
        PAREN_EXPLODER_RX__ = /\A(\()(.+)(\)?)\z/
        def to_s
          to_a.join
        end
      end

      class Plugin_Option_Parser_Proxy_
        def initialize a
          @a = a
        end
        def on * a, & p
          @a << [ a, p ] ; nil
        end
      end

      class Plugin_Option_Parser_Playback_
        def initialize y, op, cond, a
          @a = a ; @cond = cond ; @op = op ; @y = y
        end
        def playback
          @a.each do |a, p|
            Transform_Option_.new( @op, @cond, @y, a, p ).transform
          end ; nil
        end
      end

      class Transform_Option_
        def initialize op, cond, y, a, p
          @a = a ; @cond = cond ; @op = op ; @p = p ; @y = y
        end
        def transform
          (( @md = RX__.match @a.first )) ? matched : not_matched ; nil
        end
        RX__ = /\A--[-a-z0-9]*[a-z0-9](?<post_preposition_dash>-)?(?=\z|[= ])/i
        def not_matched
          @y << "(bad option name, skipping - #{ @a.first }" ; nil
        end
        def matched
          @a[ 0 ] = "#{ get_new_name }#{ @md.post_match }"
          @op.on( * @a, & @p )
        end
        def get_new_name
          if @md[ :post_preposition_dash ]
            "#{ @md[0] }#{ @cond.name.as_slug }"
          else
            "#{ @md[0] }-for-#{ @cond.name.as_slug }"
          end
        end
      end

  end
end
