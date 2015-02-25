module Skylab

  module Headless

    class Plugin  # [#077] (top half)

      class Dispatcher

        def initialize resources, & oes_p
          @cap_h = ::Hash.new { |h, k| h[k] = [] }
          @on_event_selectively = oes_p
          @pu_a = []
          @reac_h = ::Hash.new { |h, k| h[k] = [] }
          @resources = resources
        end

        def state_machine * tuples
          @sm = State_Machine___.new tuples
          nil
        end

        def process_input_against_plugins_in_module input_x, mod

          __init_index_of_plugins_in_module mod

          cp = Canary_Parser___.new( @pu_a, @sm ).
            begin_parse input_x, & @on_event_selectively

          cp and begin

            plan = cp.find_plan
            plan and begin

              if plan.argv.length.nonzero?
                self._WAHOO  # fun ..
              end

              ok = true
              plan.steps.each do | step |

                pu = @pu_a.fetch step.plugin_idx

                step.write_actuals_into_plugin pu

                ok = pu.send :"do__#{ step.transition_symbol }__"
                ok or break
              end
              ok
            end
          end
        end

        def __when_no_plugins_for_current_state
          self._NO_PLUGIN_AVAILABLE_TO_TRANSITION_FROM_STATE
        end

        def __when_ambiguous pu_a
          self._YAY_IT_IS_AN_AMBIGUITY
        end

        def __init_index_of_plugins_in_module mod

          gr = @sm.digraph

          reac_h = @reac_h
          cap_h = @cap_h

          mod.constants.each do | const |

            pu = mod.const_get( const, false ).new(
              @pu_a.length, @resources, & @on_event_selectively )

            cap_a = pu.capabilities
            if cap_a
              cap_a.each do | tr |
                cap_h[ gr.source_state_of_transition( tr.transition_symbol ) ].
                  push pu.plugin_index
              end
            end
            reac_a = pu.reactions
            if reac_a
              reac_a.each do | tr |
                reac_h[ gr.source_state_of_transition( tr.transition_symbol ) ].
                  push pu.plugin_index
              end
            end
            @pu_a.push pu

          end

          nil
        end

        # ~ dispatcher adjunct methods

        def plugins
          @pu_a
        end

        def digraph
          @sm.digraph
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

        class Canary_Parser___  # #storypoint-21

          def initialize pu_a, sm
            @caps = {}
            @occu_a = []
            @pu_a = pu_a
            @SLC_a = []
            @SLC_idx_via_short_ID_h = {}
            @SLC_idx_via_long_ID_h = {}
            @sm = sm
          end

          def begin_parse input_x, & oes_p
            _ok = __index_plugins
            _ok and Canary_Parse___.new(
              input_x, @SLC_a, @occu_a, @caps, @pu_a, @sm, & oes_p
            )
          end

          def __index_plugins
            ok = true
            slc_d_a = []

            see_d = -> d do
              if slc_d_a
                if ! slc_d_a.include? d
                  slc_d_a.push d
                end
              else
                slc_d_a = [ d ]
              end ; nil
            end

            occu_d = -1
            __each_occurrence do | occu |

              @occu_a[ occu.occurrence_index = ( occu_d += 1 ) ] = occu

              fo = occu.formal
              id_s_a = fo.short_id_s_a
              if id_s_a
                seen = true
                id_s_a.each do | id_s |
                  d = @SLC_idx_via_short_ID_h[ id_s ]
                  d or next
                  see_d[ d ]
                end
              end
              s = fo.long_id_s
              if s
                seen = true
                d = @SLC_idx_via_long_ID_h[ s ]
                if d
                  see_d[ d ]
                end
              end

              if ! seen
                self.__TODO_when_no_short_or_long_hacked_identifiers
                ok = false
                break
              end

              ok = __reconcile_SLC slc_d_a, occu
              ok or break
              slc_d_a.clear  # BE CAREFUL

            end
            ok
          end

          def __reconcile_SLC slc_d_a, occu
            case 1 <=> slc_d_a.length
            when  1 ; __add_to_SLC_list occu
            when  0 ; __compare_to_existing slc_d_a.first, occu
            when -1 ; self.__TODO_when_matches_multiple_existing_SLC slc_d_a, occu
            end
          end

          def __add_to_SLC_list occu

            d = @SLC_a.length
            @SLC_a[ d ] = [ occu.occurrence_index ]

            fo = occu.formal

            sh_id_s_a = fo.short_id_s_a
            if sh_id_s_a
              sh_id_s_a.each do | s |
                @SLC_idx_via_short_ID_h[ s ] = d
              end
            end
            s = fo.long_id_s
            if s
              @SLC_idx_via_long_ID_h[ s ] = d
            end
            ACHIEVED_
          end

          def __compare_to_existing slc_d, occu

            diff = occu.formal.build_LR_difference_against(
              @occu_a.fetch( @SLC_a.fetch( slc_d ).first ).formal )

            if diff
              self.__TODO_when_incompatible_differences diff
            else
              ACHIEVED_
            end
          end

          def __each_occurrence  # side effects too

            @pu_a.each_with_index do | pu, d |

              pu.each_reaction do | tr |

                tr.each_catalyzing_formal do | op |
                  yield( Occurrence__.new op, d, tr.transition_symbol, true )
                end

                tr.each_ancillary_formal_option do | op |
                  yield( Occurrence__.new op, d, tr.transition_symbol )
                end
              end

              pu.each_capability do | tr |

                sym = tr.transition_symbol
                h = @caps

                h.fetch( @sm.digraph.source_state_of_transition sym ) do |k|
                  h[ k ] = []
                end.push Step__.new( sym, d )

                tr.each_ancillary_formal_option do | op |
                  yield( Occurrence__.new op, d, sym )
                end
              end
            end
            nil
          end

          Occurrence__ = ::Struct.new :formal, :plugin_idx,
            :transition_symbol, :is_catalyst, :occurrence_index

          class Step__

            def initialize sym, d
              @_ast_a = nil
              @plugin_idx = d
              @transition_symbol = sym
            end

            attr_reader :plugin_idx, :transition_symbol

            def accept_assignments__ ast_a
              @_ast_a = ast_a
            end

            def write_actuals_into_plugin pu
              if @_ast_a
                @_ast_a.each do | ast |
                  if ast.arg_cat_s
                    self._COOL_AND_EASY
                  else
                    pu.instance_exec( * ast.args, & ast.block )
                  end
                end
              end
              nil
            end
          end

          class Canary_Parse___

            def initialize input_x, slc_a, occu_a, caps, pu_a, sm, & oes_p
              @actuals_known = {}
              @caps = caps
              @digraph = sm.digraph
              @input_x = input_x
              @occu_a = occu_a
              @on_event_selectively = oes_p
              @formals_used = {}
              @pu_a = pu_a
              @SLC_a = slc_a
              @sm = sm
              @traversals = {}
            end

            def find_plan
              __normalize_input &&
              __via_normal_input_find_plan
            end

            def __normalize_input  # #storypoint-11
              __init_option_parser
              arg2 = @input_x.dup  # this is only a plan - don't mutate orig yet
              @op.parse! arg2

              @argv_2 = arg2

              @x = Result___.new @actuals_known, @traversals
              ACHIEVED_
            rescue ::OptionParser::ParseError => e

              @on_event_selectively.call :error, :exception, :optparse_parse do
                e
              end
              UNABLE_
            end

            Result___ = ::Struct.new :actuals_known, :traversals

            def __init_option_parser
              @op = Headless_::Library_::OptionParser.new do | op |
                @SLC_a.each_with_index do | occu_id_a, d |
                  occu = @occu_a.fetch occu_id_a.fetch 0
                  op.define( * occu.formal.barebones_arguments,
                    & __callback_for( occu, d ) )

                end
              end ; nil
            end

            def __callback_for _OCCU, slc_d
              if _OCCU.formal.arg_category_string  # ick
                -> x do
                  _receive_invocation_for slc_d, [ x ]
                  nil
                end
              else
                -> _ do
                  true == _ or self._SANITY  # #todo remove after :+#dev
                  _receive_invocation_for slc_d
                  nil
                end
              end
            end

            def _receive_invocation_for slc_d, args=nil

              @SLC_a.fetch( slc_d ).each do | occu_d |
                occu = @occu_a.fetch occu_d
                if occu.is_catalyst

                  # key this invocation to the source node

                  h = @traversals

                  h.fetch(
                    @digraph.source_state_of_transition occu.transition_symbol
                  ) do | k |
                    h[ k ] = []
                  end.push Step__.new( occu.transition_symbol, occu.plugin_idx )  # #here

                  nil
                end

                # when traversing this arc with this plugin, give it the
                # list of formal-args pairs including this one

                h = @actuals_known
                h = h.fetch occu.transition_symbol do | k |
                  h[ k ] = {}
                end
                h.fetch occu.plugin_idx do | k |
                  h[ k ] = []
                end.push args, occu.formal.formal_path_x  # etc

                nil
              end
              nil
            end

            # ~ (might become new class)

            def __via_normal_input_find_plan  # #storypoint-01
              @step_a = []

              ok = true

              tv = @x.traversals

              begin

                sym = @sm.state_symbol

                if FINISHED___ == sym
                  break
                end

                a = tv[ sym ]
                if a
                  @found_via_catalysm = true
                else
                  a = __when_no_catalyst_try_capabilities
                  @found_via_catalysm = false
                end

                case 1 <=> a.length
                when 0
                  ok = __into_plan_add_step a.fetch 0
                  ok or break
                when 1
                  ok = self.__TODO_when_no_step
                  ok or break
                when -1
                  self.__TODO_when_ambiguous
                  ok = UNABLE_
                  break
                end

                redo
              end while nil

              ok &&= __check_for_unused_actuals
              ok && Plan___.new( @argv_2, @step_a )
            end

            FINISHED___ = :finished

            Plan___ = ::Struct.new :argv, :steps

            def __when_no_catalyst_try_capabilities
              @caps[ @sm.state_symbol ] || EMPTY_A_
            end

            def __into_plan_add_step step

              __prepare_actuals_for_step step

              tr_sym = step.transition_symbol

              sym_ = @sm.digraph.target_state_of_transition tr_sym

              if @sm.state_symbol == sym_
                self._WAHOO  # remove it from @caps or @x.traversals per
                  # @found_via_catalysm
              else
                @sm.accept_transition tr_sym
              end

              @step_a.push step

              ACHIEVED_
            end

            def __prepare_actuals_for_step step
              # need: pu, plan

              ast_a = nil
              pu_h = @actuals_known[ step.transition_symbol ]
              if pu_h

                pairs = pu_h.delete step.plugin_idx  # delete.

                if pu_h.length.zero?
                  @actuals_known.delete step.transition_symbol
                end

                if pairs

                  pu = @pu_a.fetch step.plugin_idx

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

                  pu = @pu_a.fetch pu_id

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
                    :box, bx, :steps, @step_a, :plugins, @pu_a )
                end
                UNABLE_
              else
                ACHIEVED_
              end
            end

            Unused___ = ::Struct.new :plugin_idx, :formal


          end   # Canary_Parse___
        end   # Canary_Parser___
      end  # Dispatcher

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
          op_p[ Formal_Recorder___.new( id_a, & op_o_p ) ]
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

      # ~~ a specialization of :+[#003] rewritten for insulation

      class Formal_Recorder___

        def initialize id_prefix_x, & p
          @id_prefix_x = id_prefix_x
          @d = -1
          @op_o_p = p
        end

        def on * a, & any_p
          x = [ ( @d += 1 ), * @id_prefix_x ]
          @op_o_p[ Formal___.new do
            @formal_path_x = x
            @args = a
            @block = any_p
            __index
          end ]
          nil
        end
      end

      class Formal___

        def initialize & edit_p
          @_short_d_a = nil
          @short_id_s_a = nil
          @_long_d = nil
          @long_id_s = nil
          @arg_category_string = nil
          instance_exec( & edit_p )
        end

        attr_reader :short_id_s_a, :long_id_s, :arg_category_string, :block

        attr_reader :args, :formal_path_x

        def full_pedagogic_moniker_rendered_under _expag
          barebones_arguments * ', '
        end

        def to_description_line_stream_rendered_under _expag

          _d = if @_long_d
            @_long_d + 1
          else
            @_short_d_a.last + 1  # etc
          end

          Callback_::Stream.via_nonsparse_array @args[ _d .. -1 ]  # empty OK
        end

        def barebones_arguments

          if @_short_d_a
            d = @_short_d_a.first
            d_ = @_short_d_a.last
          end

          if @_long_d
            d ||= @_long_d
            d_ = @_long_d
          end

          if d
            @args[ d .. d_ ]
          end
        end

        def local_identifier_x
          if @_short_d_a
            @short_id_s_a.fetch 0
          else
            @long_id_s
          end
        end

        def __index
          a = @args

          d = 0 ; len = a.length

          last_sep_s = nil

          begin
            len == d and break
            md = SHORT_RX___.match a.fetch d
            md or break
            @short_id_s_a ||= begin
              @_short_d_a = []
              []
            end
            @_short_d_a.push d
            @short_id_s_a.push md[ :id ]
            s = md[ :arg ]
            s and last_sep_s = s

            d += 1
            redo
          end while nil

          long_md_a = []
          last_long_d = nil
          begin
            len == d and break
            md = LONG_RX___.match a.fetch d
            md or break
            long_md_a.push md
            last_long_d = d
            d += 1
            redo
          end while nil

          if 1 == long_md_a.length
            md = long_md_a.first
            @_long_d = last_long_d
            @long_id_s = md[ :id ]
            s = md[ :arg ]
            s and last_sep_s = s
          end

          @arg_category_string = s

          nil
        end

        SHORT_RX___ = /\A (?<id> -(?!-) [^ =\[] )  (?<arg> [ =\[]+ )? /x

        LONG_RX___ = /\A (?<id> --(?!-) [^ =\[]* )  (?<arg> [ =\[]+ )? /x

          # our goal is only to capture enough for equality comparison: we
          # must know the identifying string of the switch and we must know
          # which of no arg, optional arg or required arg it is, but we must
          # be insensitive to the arbitrary moniker used for any arg. the
          # above may certainly match strings that not valid for vendor o.p

        def build_LR_difference_against fo

          sids_a = @short_id_s_a
          sids_a_ = fo.short_id_s_a
          if sids_a
            if sids_a_
              a = sids_a - sids_a_
              a_ = sids_a_ - sids_a
              if a.length.nonzero?
                left_s_a = a
              end
              if a_.length.nonzero?
                right_s_a = a_
              end
            else
              left_s_a = sids_a
            end
          elsif sids_a_
            right_s_a = sids_a_
          end

          s = @long_id_s
          s_ = fo.long_id_s
          if s
            if s_
              if s != s_
                left_s = s
                right_s = s_
              end
            else
              left_s = s
            end
          elsif s_
            right_s = s_
          end

          s = @arg_category_string
          s_ = fo.arg_category_string
          if s
            if s_
              if s != s_
                left_arg_cat_s = s
                right_arg_cat_s = s_
              end
            else
              left_arg_cat_s = s
            end
          elsif s_
            right_arg_cat_s = s_
          end

          if left_s || left_s_a || left_arg_cat_s
            left_diff = self.class.new do
              @short_id_s_a = left_s_a
              @long_id_s = left_s
              @arg_category_string = left_arg_cat_s
            end
          end

          if right_s || right_s_a || right_arg_cat_s
            right_diff = self.class.new do
              @short_id_s_a = right_s_a
              @long_id_s = right_s
              @arg_category_string = right_arg_cat_s
            end
          end

          if left_diff || right_diff
            [ left_diff, right_diff ]
          end
        end
      end

      # ~ instance methods for plugin as base class

      def initialize plugin_index, resources, & oes_p
        @on_event_selectively = oes_p
        @plugin_index = plugin_index
        @resources = resources
      end

      attr_reader :plugin_index

      def name
        @nm ||= Callback_::Name.via_module self.class
      end

      def formal_via_formal_path_ formal_path_x

        opt_id, which, tr, c_or_r = formal_path_x

        send( c_or_r ).detect do | cap |
          tr == cap.transition_symbol
        end.send( which ).fetch opt_id  # #sorry
      end

      def each_reaction & yld_p
        a = reactions
        if a
          a.each( & yld_p )
        end
        nil
      end

      def reactions
        self.class._reac_a
      end

      def each_capability & yld_p
        a = capabilities
        if a
          a.each( & yld_p )
        end
        nil
      end

      def capabilities
        self.class._cap_a
      end

      # ~ example plugin:

      class Express_Help < self

        does :finish do | st |

          st.transition_is_effected_by do | op |

            op.on '--help', 'show this screen'

          end
        end

        def do__finish__
          Plugin_::When_::Express_Help.new(
            @resources, & @on_event_selectively ).execute
        end
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

      class Plugin_Conduit_  # see [#031]:#understanding-plugin-shells
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
end
