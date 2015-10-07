module Skylab::Plugin

  class Digraphic

    Modality_Adapters_ = ::Module.new

    module Modality_Adapters_::ARGV

      class Monitor

        def initialize occurrence_a

          @_long_to_short_long_combo = {}
          @occurrence_a = occurrence_a
          @_short_long_combo_a = []
          @_short_long_combo_occurrence_a = []
          @_short_long_combo_occurrence_h = {}
          @_short_to_short_long_combo = {}
        end

        def accept & yld_p
          @_short_long_combo_a.each( & yld_p )
          NIL_
        end

        def register_occurrence occu

          # group all occurrences of all formals in all plugins by their
          # short-long combination ensuring there are no conflicts.

          formal = occu.formal

          short_a = formal.short_id_s_a
          long = formal.long_id_s

          if short_a
            __note_any_short_long_combos_that_have_these_shorts short_a
          end

          if long
            __note_any_short_long_combos_that_has_this_long long
          end

          case 1 <=> @_short_long_combo_occurrence_a.length
          when  1
            __this_is_a_new_short_long_combo_never_seen_before occu
          when 0
            __maybe_add_this_occurrence_to_the_short_long_combo occu
          else
            self.__TODO_never_OK_this_occurrence_matches_several_existing_SLCs
          end

          @_short_long_combo_occurrence_a.clear
          @_short_long_combo_occurrence_h.clear

          NIL_
        end

        def __note_any_short_long_combos_that_have_these_shorts s_a

          h = @_short_to_short_long_combo

          s_a.each do | short |

            idx = h[ short ]
            if idx && ! @_short_long_combo_occurrence_h[ idx ]
              @_short_long_combo_occurrence_a.push idx
              @_short_long_combo_occurrence_h[ idx ] = true
            end
          end

          nil
        end

        def __note_any_short_long_combos_that_has_this_long long

          idx = @_long_to_short_long_combo[ long ]

          if idx && ! @_short_long_combo_occurrence_h[ idx ]
            @_short_long_combo_occurrence_a.push idx
            @_short_long_combo_occurrence_h[ idx ] = true
          end

          nil
        end

        def __this_is_a_new_short_long_combo_never_seen_before occu

          formal = occu.formal
          shorts = formal.short_id_s_a
          long = formal.long_id_s

          my_index = @_short_long_combo_a.length

          slc = Short_Long_Combo___.new(
            my_index, shorts, long, [ occu.occurrence_index ] )

          if shorts
            shorts.each do | short_s |
              @_short_to_short_long_combo[ short_s ] = my_index
            end
          end

          if long
            @_long_to_short_long_combo[ long ] = my_index
          end

          @_short_long_combo_a[ my_index ] = slc

          NIL_
        end

        Short_Long_Combo___ = ::Struct.new(
          :SLC_index, :shorts, :long, :occurrences )

        def __maybe_add_this_occurrence_to_the_short_long_combo occu

          # assume exactly one existing short long combo is on deck

          slc = @_short_long_combo_a.fetch @_short_long_combo_occurrence_a.fetch 0

          diff = occu.formal.build_LR_difference_against(
            @occurrence_a.fetch( slc.occurrences.fetch 0 ).formal )

          if diff
            self.__TODO_when_incompatible_differences diff
          else
            slc.occurrences.push occu.occurrence_index
          end
          nil
        end
      end

      class Formal

        def initialize * args, & x_p
          if args.length.zero?
            instance_exec( & x_p )
          else
            __init( * args, & x_p )
          end
        end

        def __init a, x, & any_p
          @args = a
          @block = any_p
          @formal_path_x = x
          __index
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

          # based on the syntax [ short [..]] [ long ] [ other [..]]
          # init these ivars:
          #
          #     @_short_d_a, @short_id_s_a,
          #     @_long_d, @long_id_s, @arg_category_string
          #

          args = @args
          st = Callback_::Stream.via_times args.length
          d = nil ; s = nil

          gets = -> do
            d = st.gets
            if d
              s = args.fetch d
              true
            else
              s = nil
              false
            end
          end

          local_short_d_a = nil
          local_short_id_s_a = nil

          add_short = -> do
            local_short_d_a = []
            local_short_id_s_a = []
            add_short = -> do
              local_short_d_a.push d
              local_short_id_s_a.push s
              NIL_
            end
            add_short[]
          end

          gets[]  # assume at least one

          begin

            md = SHORT_RX___.match s
            if md
              last_cat_s = md[ :arg ]
              add_short[]
              _yes = gets[]
              if _yes
                redo
              end
            end
            break
          end while nil

          local_long_d = nil
          local_long_id_s = nil

          if d  # if one unprocessed line
            md = LONG_RX___.match s
            if md

              last_cat_s = md[ :arg ]

              local_long_d = d
              local_long_id_s = s

              if gets[] and LONG_RX___.match s
                self._COVER_ME
              end
            end
          end

          @arg_category_string = last_cat_s

          @_short_d_a = local_short_d_a
          @short_id_s_a = local_short_id_s_a

          @_long_d = local_long_d
          @long_id_s = local_long_id_s

          NIL_
        end

        arg_rsx = '(?<arg> \\[? [ =] )?'  # just enough to categorize

        SHORT_RX___ = /\A (?<id> -(?!-) [^ =\[] )  #{ arg_rsx }/x

        LONG_RX___ = /\A (?<id> --(?!-) [^ =\[]* )  #{ arg_rsx }/x

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

      class Aggregate_Parse_Session

        def initialize input_x, indexes, & oes_p

          @indexes = indexes
          @input_x = input_x
          @occurrence_a = indexes.occurrence_a
          @on_event_selectively = oes_p
          @plugin_a = indexes.plugin_a

          # ~ written to when the parse happens:

          @actuals_known = {}
          @traversals = {}
        end

        def _build_option_parser_and_parse_options

          __init_canary_option_parser
          __via_canary_parser_parse_options
        end

        def __via_canary_parser_parse_options

          arg2 = @input_x.dup  # this is only a plan - don't mutate orig yet
          @canary_option_parser.parse! arg2
          @argv_2 = arg2

          ACHIEVED_
        rescue ::OptionParser::ParseError => e

          @on_event_selectively.call :error, :exception, :optparse_parse do
            e
          end
          UNABLE_
        end

        def __init_canary_option_parser

          op = Home_.lib_.stdlib_option_parser.new

          @indexes.accept do | slc |

            formal = @occurrence_a.fetch( slc.occurrences.fetch( 0 ) ).formal

            op.define( * formal.barebones_arguments,

              & __callback_for( formal, slc ) )

          end
          @canary_option_parser = op
          NIL_
        end

        def __callback_for formal, slc

          if formal.arg_category_string  # ick
            -> x do
              _receive_knowledge_of slc, [ x ]
              NIL_
            end
          else
            -> _=true do
              true == _ or self._SANITY  # #todo remove after :+#dev
              _receive_knowledge_of slc
              NIL_
            end
          end
        end

        def _receive_knowledge_of slc, args=nil

          slc.occurrences.each do | occurrence_idx |

            occu = @occurrence_a.fetch occurrence_idx

            if occu.is_catalyst
              __receive_knowledge_of_catalyst occu
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

            NIL_
          end
          NIL_
        end

        def __receive_knowledge_of_catalyst occu

          # key this invocation to the source node

          h = @traversals

          h.fetch(
            @digraph.source_state_of_transition occu.transition_symbol
          ) do | k |
            h[ k ] = []
          end.push( Me_::Dispatcher::Step.
            new( occu.transition_symbol, occu.plugin_idx ) )

          NIL_
        end
      end

      class Produce_bound_call < Aggregate_Parse_Session

        # #storypoint-11, #storypoint-21

        def initialize input_x, state_machine, indexes, & oes_p

          @digraph = state_machine.digraph
          @state_machine = state_machine

          super( input_x, indexes, & oes_p )
        end

        def execute

          ok = _build_option_parser_and_parse_options
          ok &&= __via_normal_input_resolve_steps
          ok && __via_steps_decide_who_gets_ARGV
          ok && __deliver_the_goods
        end

        def __via_normal_input_resolve_steps

          @step_a = Me_::Dispatcher::Find_plan.new(
            @actuals_known, @traversals, @state_machine, @indexes,
            & @on_event_selectively ).execute

          @step_a && ACHIEVED_
        end

        def __via_steps_decide_who_gets_ARGV

          step_index_of_last_one_to_get_argv = nil

          @step_a.each_with_index do | step, d |
            if @plugin_a.fetch( step.plugin_idx ).respond_to? :process_ARGV
              step.does_process_input = true
              step_index_of_last_one_to_get_argv = d
            end
          end

          if step_index_of_last_one_to_get_argv
            @step_a.fetch( step_index_of_last_one_to_get_argv ).
              is_last_to_process_input = true
          end

          @prcs_argv_meth_name =
            step_index_of_last_one_to_get_argv && :process_ARGV

          ACHIEVED_
        end

        def __deliver_the_goods

          Callback_::Bound_Call.via_receiver_and_method_name(

            Plan___.new(
              @argv_2, @input_x, @prcs_argv_meth_name,
              @step_a, @indexes,
              & @on_event_selectively ),

            :execute_the_plan )
        end
      end

      class Plan___

        def initialize working_argv, real_argv, input_method_name, step_a, idxs, & oes_p

          @input_method_name = input_method_name
          @on_event_selectively = oes_p
          @plugin_a = idxs.plugin_a
          @real_ARGV = real_argv
          @step_a = step_a
          @working_ARGV = working_argv
        end

        def execute_the_plan

          # arbitrary plugins may rely on arbitrary outside services to parse
          # additional ARGV at any point (or conversely, the outside services
          # may rely on ARGV being empty) so we must transfer it over now.

          @real_ARGV.replace @working_ARGV
          @working_ARGV = nil
          input_x = @real_ARGV

          ok = true

          if input_x.length.nonzero? && ! @input_method_name
            _when_unprocessed_input input_x
            ok = UNABLE_
          else

            @step_a.each do | step |

              pu = @plugin_a.fetch step.plugin_idx

              step.write_actuals_into_plugin pu

              if step.does_process_input
                ok = pu.send @input_method_name, input_x
                ok or break

                if step.is_last_to_process_input && input_x.length.nonzero?
                  _when_unprocessed_input input_x
                  ok = UNABLE_
                  break
                end
              end

              ok = pu.send :"do__#{ step.transition_symbol }__"
              ok or break
            end
          end

          ok
        end

        def _when_unprocessed_input input_x
          @on_event_selectively.call :error, :expression do | y |
            y << "unhandled argument: #{ input_x.first.inspect }"
          end
          NIL_
        end
      end
    end
  end
end
