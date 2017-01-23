class Skylab::Task

  class Eventpoint

    module When_

      # ==

      class AmbiguousNextStep < Common_::Dyadic

        def initialize d_a, up
          @all_formal_transitions = up.all_formal_transitions
          @all_pending_executions = up.all_pending_executions
          @listener = up.listener
          @offsets = d_a
        end

        def execute

          and_buff_proto = Eventpoint::Event_::And_buffer[]

          exe_a = @all_pending_executions
          fot_a = @all_formal_transitions

          and_buff_proto = Eventpoint::Event_::JoinerBuffer.new ' and '

          buffer = and_buff_proto.dup_by do |o|
            o.initial_buffer = "ambiguous: "
          end

          me = self
          @listener.call :error, :expression, :ambiguous do |y|
            me.__formal_transitions_by_common_destination.each_pair do |sym, d_a|
              buff = and_buff_proto.dup
              d_a.map do |d|
                _pending_exe = exe_a.fetch fot_a.fetch( d ).pending_execution_offset
                buff << "'#{ _pending_exe.mixed_task_identifier.intern }'"  # ..
              end
              _subj = buff.finish || 'multiple'
              _yes = 1 == d_a.length
              buffer << "#{ both d_a }#{ _subj } transition#{ 's' if _yes } to '#{ sym }'"
            end
            y << buffer.finish
          end
          UNABLE_
        end

        def __formal_transitions_by_common_destination

          h = ::Hash.new(){ |h_, k| h_[k] = [] }
          fot_a = @all_formal_transitions
          @offsets.each do |d|
            h[ fot_a.fetch( d ).formal_transition.destination_symbol ].push d
          end
          h
        end
      end

      # ==

      class UnutilizedPendingExecution < Common_::Dyadic

        # a custom #[#hu-002] EN expression of aggregation

        def initialize d_a, up
          @offsets = d_a
          @up = up
        end

        def execute

          me = self
          lib = Eventpoint::Event_

          @up.listener.call :info, :expression, :unutilized_pending_executio do |y|

            me.__to_thing_stream.each do |exe|

              buffer = "#{ lib::Say_pending_execution[ exe ] } #{
                }will have no effect because the system does not reach "

              seen = {}
              _wow = exe.to_formal_transition_stream.map_by do |fo_trans|
                fo_trans.from_symbol
              end.reduce_by do |sym|
                seen.fetch(sym) { seen[sym] = false ; true }
              end.map_by do |sym|
                lib::Say_state[ sym ]
              end.join_into_with_by "", " or ", & IDENTITY_

              buffer << _wow
              y << buffer
            end
            y  # important
          end
          NIL
        end

        def __to_thing_stream
          exe_a = @up.all_pending_executions
          Common_::Stream.via_nonsparse_array( @offsets ).map_by do |exe_d|
            exe_a.fetch exe_d
          end
        end
      end

      # ==

      class UnmetImperativeTransitions < Common_::Dyadic

        # "FOO" and "BAR" {rely|relies} on 'zing zang'

        def initialize d_a, up
          @offsets = d_a
          @up = up
        end

        def execute
          me = self
          @up.listener.call :error, :expression, :unmet_imperatives do |y|
            _big_line = me.__big_line
            y << _big_line
          end
          NIL
        end

        def __big_line

          _pending_executions_via_source_sym = __pending_executions_via_source_sym

          lib = Eventpoint::Event_
          say_state = lib::Say_state
          and_buff_proto = lib::And_buffer[]
          buffer = and_buff_proto.dup

          exe_a = @up.all_pending_executions
          and_me = []
          _pending_executions_via_source_sym.each_pair do |from_sym, exe_d_a|

            buff = and_buff_proto.dup

            exe_d_a.each do |d|
              buff << lib::Say_pending_execution[ exe_a.fetch( d ) ]
            end

            _v = 1 == exe_d_a.length ? 'relies' : 'rely'

            s = say_state[ from_sym ]
            buffer << "#{ buff.finish } #{ _v } on #{ s }"
            and_me.push s
          end

          big_line = buffer.finish

          _v = 1 == and_me.length ? "isn't" : "aren't"
          big_line << " and #{ Common_::Oxford_and[ and_me ] } #{ _v } reached."
        end

        def __pending_executions_via_source_sym

          # 1. group the things by the source node they needed but didn't have

          fot_a = @up.all_formal_transitions

          pending_executions_via_source_sym = {}
          @offsets.each do |d|
            reg_trans = fot_a.fetch d
            _sym = reg_trans.formal_transition.from_symbol
            ( pending_executions_via_source_sym[ _sym ] ||= [] ).push(
              reg_trans.pending_execution_offset )
          end
          pending_executions_via_source_sym
        end
      end

      # ==

      class NoTransitionFound < Common_::Monadic

        def initialize up
          @up = up
        end

        def execute
          me = self
          @up.listener.call :error, :expression, :no_transition_found do |y|
            me.__express_into_under y, self
          end
        end

        def __express_into_under y, expag
          @y = y ; @expression_agent = expag
          if __zero
            __express_zero
          else
            __express_one_or_more
          end
        end

        def __zero

          @_lib = Eventpoint::Event_
          @all_pending_executions = @up.all_pending_executions
          @all_pending_executions.length.zero?
        end

        def __express_zero

          # "there are no pending executions"
          o = @_lib

          o::SentencePhrase.define do |sp|

            sp.noun_phrase = o::Exist[ :present, EMPTY_A_ ]

            sp.verb_phrase = _pending_executions :inclusive

          end.express_into_under @y, @expression_agent

          # "so nothing brings the system from the A state to a finished state"

          o::SentencePhrase.define do |sp|

            sp.conjunctive_phrase = o::Therefor[]

            sp.noun_phrase = o::Nothing[]

            sp.verb_phrase = _finish

          end.express_into_under @y, @expression_agent
        end

        def __express_one_or_more

          # "none of the 3 pending executions [..]"
          # "the only pending execution [..]"

          o = @_lib

          o::SentencePhrase.define do |sp|

            sp.noun_phrase = _pending_executions :exclusive

            sp.verb_phrase = _finish

          end.express_into_under @y, @expression_agent
        end

        def _pending_executions which
          @_lib::PendingExecutions[ which, @all_pending_executions ]
        end

        def _finish
          @_lib::Finish.call(
            @up.current_state_symbol,
            :exclusive,
            @all_pending_executions,
          )
        end
      end

      # ==

      Say_invalid_transition = -> ft, pe, eventpoint do

        s = "'#{ ft.from_symbol }' cannot transition to '#{ ft.destination_symbol }'."

        a = eventpoint.can_transition_to
        if a
          _a = a.map( & :id2name )
          s << " it can transition to #{ Common_::Oxford_or[ _a ] }"
        else
          s << " it is an endpoint, and so has no transitions"
        end
        mti = pe.mixed_task_identifier
        if mti.respond_to? :intern
          s << " (in '#{ mti.intern }')"
        end
        s << '.'  # DOT_
      end

      # ==

      class WAS_Express_Help < Common_::Event

        # (although this is no longer used we're keeping it around until
        # that loop is closed :[#ze-022.4]: help screen for [ts] quickie
        # using [ze] microservices (somehow).. probably move this code there)

        class << self
          public :new
        end  # >>

        def initialize resources, & oes_p
          self._NOT_USED__readme__
          @rsc = resources
          @on_event_selectively = oes_p
        end

        def execute
          @on_event_selectively.call :help, :event do
            self
          end
        end

        def message_proc
          oes_p = @on_event_selectively
          -> y, o do
            Render___.new( y, o.__dsp, o.rsc, self, & oes_p ).execute
          end
        end

        attr_reader :rsc

        def __dsp
          @on_event_selectively.call :for_plugin, :dispatcher  # experimental
        end

        class Render___

          def initialize into_y, dsp, rsc, expag, & oes_p
            @content_has_been_displayed = false
            @dg = dsp.digraph
            @expag = expag
            @on_event_selectively = oes_p
            @plugins = dsp.plugin_a
            @y = into_y
          end

          def execute
            __init_args_list_and_options_box
            __render
          end

          def __init_args_list_and_options_box

            a = nil
            bx = Common_::Box.new

            @plugins.each do |de|

              if de.respond_to? :process_ARGV
                ( a ||= [] ).push de
              end

              de.each_reaction do |tr|

                tr.each_catalyzing_formal do |fo|

                  bx.touch_array_and_push fo.local_identifier_x, [ fo, de ]
                end

                tr.each_ancillary_formal_option do |fo|

                  bx.touch_array_and_push fo.local_identifier_x, [ fo, de ]
                end
              end

              de.each_capability do |tr|

                tr.each_ancillary_formal_option do |fo|

                  bx.touch_array_and_push fo.local_identifier_x, [ fo, de ]
                end
              end
            end

            @takes_ARGV_pu_a = a
            @bx = bx ; nil
          end

          def __render

            if @takes_ARGV_pu_a
              __render_usage_and_arguments
            end

            __render_options
          end

          def __render_usage_and_arguments

            _pn = @on_event_selectively.call :for_plugin, :program_name

            s_a = @takes_ARGV_pu_a.reduce [] do | m, de |
              s = de.description_for_ARGV_syntax_under @expag
              s and m.push s
              m
            end

            if s_a.length.nonzero?
              _args = " #{ s_a * SPACE_ }"
            end

            y = @y
            @expag.calculate do
              y << "#{ hdr( 'usage:' ) } #{ _pn } [opts]#{ _args }\n"
            end

            @content_has_been_displayed = true

            nil
          end

          def __render_options

            self._NOT_COVERED__and_when_you_do_you_need_to_modernize_the_table__  # #open [#pl-011]

            y = @y

            @content_has_been_displayed and y << "\n"

            @expag.calculate do
              y <<  "#{ hdr( 'options:' ) }\n"
            end

            @mat_a = []

            @bx.each_value do | fo_a |
              __write_to_matrix_formal_group_under fo_a
            end

            Home_.lib_.brazen::CLI_Support::Table::Actor.call(

              :left, '  ',
              :right, SPACE_,
              :sep, '  ',
              :field, :right,
              :field, :left,
              :header, :none,

              :read_rows_from, @mat_a,
              :write_lines_to, y,
            )

            ACHIEVED_
          end

          def __write_to_matrix_formal_group_under fo_a

            __write_to_matrix_first_formal fo_a

            __write_to_matrix_nonfirst_formals fo_a

            nil
          end

          def __write_to_matrix_first_formal fo_a

            fo, de = fo_a.first
            s = fo.full_pedagogic_moniker_rendered_under @expag

            st = fo.to_description_line_stream_rendered_under @expag

            line = st.gets

            @mat_a.push [ s ]
            if line
              _maybe_add_thing line, fo, de
              _flush_into_matrix_stream st, fo, de
            else
              _maybe_add_thing line, fo, de
            end
            nil
          end

          def __write_to_matrix_nonfirst_formals fo_a

            fo_a[ 1 .. -1 ].each do | fo, de |

              _st = fo.to_description_line_stream_rendered_under @expag

              _flush_into_matrix_stream _st, fo, de
            end

            nil
          end

          def _flush_into_matrix_stream st, fo, de

            begin
              line = st.gets
              line or break
              _maybe_add_thing line, fo, de
              redo
            end while nil
          end

          def _maybe_add_thing line, fo, de

            # massive hacking ahead. everything is a proof of concept.
            # none of this is real.

            pth_x = fo.formal_path_x

            if :catalyzing_formals == pth_x[ 1 ]

              if line
                _add_cel "#{ line }."

              else
                # (it can be fun to do both this branch and the above one,
                # but in practice, this generated language is usually less
                # specific than and otherwise redundant with the above.)

                _s = @expag.calculate do
                  third_person de.name.as_human
                end
                _add_cel "#{ _s }."
              end

            elsif :ancillary_formals == pth_x[ 1 ]

              _s = @expag.calculate do
                "while #{ progressive_verb de.name.as_human },"
              end

              _add_cel _s

              if line
                _add_cel "#{ line }."
              end
            end
            nil
          end

          def _add_cel cel_s
            row = @mat_a.last
            if 1 == row.length
              row.push cel_s
            else
              @mat_a.push [ nil, cel_s ]
            end ; nil
          end
        end
      end

      # ==
    end
  end
end
