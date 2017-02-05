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
    end
  end
end
# :#tombstone-A: we're not clear when this [#tab-001.2] help screen was used,
#   because it was apparently not used by the eponymous [ts] quickie plugin
