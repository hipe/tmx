module Skylab::Headless

  class Plugin  # [#077] (top half)

    module ARGV__

      class Formal

        def initialize a, x, & any_p
          @arg_category_string = nil
          @args = a
          @block = any_p
          @formal_path_x = x
          @_long_d = nil
          @long_id_s = nil
          @_short_d_a = nil
          @short_id_s_a = nil
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

      class Produce_bound_call

        # #storypoint-11, #storypoint-21

        def initialize input_x, state_machine, indexes, & oes_p

          @digraph = state_machine.digraph
          @indexes = indexes
          @input_x = input_x
          @occurrence_a = indexes.occurrence_a
          @on_event_selectively = oes_p
          @plugin_a = indexes.plugin_a
          @state_machine = state_machine

          # ~ written to when the parse happens:

          @actuals_known = {}
          @traversals = {}
        end

        def execute

          __init_canary_option_parser
          ok = __via_canary_parser_parse_options
          ok &&= __via_normal_input_resolve_steps
          ok && __via_steps_decide_who_gets_ARGV
          ok && __deliver_the_goods
        end

        def __init_canary_option_parser

          op = Headless_::Library_::OptionParser.new

          @indexes.each_short_long_combo do | slc |

            formal = @occurrence_a.fetch( slc.occurrences.fetch( 0 ) ).formal

            op.define( * formal.barebones_arguments,

              & __callback_for( formal, slc ) )

          end
          @canary_option_parser = op
          nil
        end

        def __callback_for formal, slc

          if formal.arg_category_string  # ick
            -> x do
              _receive_knowledge_of slc, [ x ]
              nil
            end
          else
            -> _ do
              true == _ or self._SANITY  # #todo remove after :+#dev
              _receive_knowledge_of slc
              nil
            end
          end
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

        def _receive_knowledge_of slc, args=nil

          slc.occurrences.each do | occurrence_idx |

            occu = @occurrence_a.fetch occurrence_idx

            if occu.is_catalyst

              # key this invocation to the source node

              h = @traversals

              h.fetch(
                @digraph.source_state_of_transition occu.transition_symbol
              ) do | k |
                h[ k ] = []
              end.push( Plugin_::Dispatcher::Step.
                new( occu.transition_symbol, occu.plugin_idx ) )

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

        def __via_normal_input_resolve_steps

          @step_a = Plugin_::Dispatcher::Find_plan.new(
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

          Callback_::Bound_Call.new( nil,

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
            _when_unprocessed_input
            ok = UNABLE_
          else

            @step_a.each do | step |

              pu = @plugin_a.fetch step.plugin_idx

              step.write_actuals_into_plugin pu

              if step.does_process_input
                ok = pu.send @input_method_name, input_x
                ok or break

                if step.is_last_to_process_input && input_x.length.nonzero?
                  _when_unprocessed_input
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
      end
    end
  end
end
