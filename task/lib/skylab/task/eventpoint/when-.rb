class Skylab::Task

  class Eventpoint

    module When_

      # ==

      module AmbiguousNextStep  # #borrow-coverage from [#ts-008.3]

        def self.[] d_a, up
          up.listener.call :error, :expression, :ambiguous do |y|
            simple_inflection do
              extend Here_::Event_::ExpressionMethods
              extend AmbiguousNextStep
              init_for_wonderful_expression_hack_( y, d_a, up ).express
            end
          end
        end

        def express

          exe_a = @up.all_pending_executions
          fot_a = @up.all_formal_transitions

          primary_total = 0

          h = __formal_transitions_by_common_destination

          _line = oxford_join_do_not_store_count scanner_ h.keys do |sym|

            _d_a = h.fetch sym

            _this_and_this = oxford_join scanner_( _d_a ) do |d|

              primary_total += 1

              _pending_exe = exe_a.fetch fot_a.fetch( d ).pending_execution_offset
              say_pending_execution_ickily_ _pending_exe
            end

            _to_this = oper sym  # ick

            s = "#{ both_ }#{ _this_and_this } #{ all_ }#{ v "transition" } to #{ _to_this }"
            clear_count_for_inflection
            s
          end

          @y << _line
          @y << "so you can't have #{ both_or_all primary_total } of them at the same time."
        end

        def __formal_transitions_by_common_destination

          h = ::Hash.new(){ |h_, k| h_[k] = [] }
          fot_a = @up.all_formal_transitions
          @offsets.each do |d|
            h[ fot_a.fetch( d ).formal_transition.destination_symbol ].push d
          end
          h
        end
      end

      # ==

      module UnutilizedPendingExecution

        # a custom #[#hu-002] EN expression of aggregation
        # one line per pending execution

        def self.call d_a, up
          up.listener.call :error, :expression, :unutilized_pending_execution do |y|
            simple_inflection do
              extend Here_::Event_::ExpressionMethods
              extend UnutilizedPendingExecution
              init_for_wonderful_expression_hack_( y, d_a, up ).express
            end
          end
          NIL
        end

        def express

          __to_thing_stream.each do |exe|

              buffer = "#{ say_pending_execution_ickily_ exe } #{
                }will have no effect because the system does not reach "

              seen = {}
              _wow = exe.to_formal_transition_stream.map_by do |fo_trans|
                fo_trans.from_symbol
              end.reduce_by do |sym|
                seen.fetch(sym) { seen[sym] = false ; true }
              end.map_by do |sym|
                say_state_ sym
              end.flush_to_scanner

            oxford_join_do_not_store_count buffer, _wow, " or "
            @y << buffer
          end

          @y
        end

        def __to_thing_stream
          exe_a = @up.all_pending_executions
          Common_::Stream.via_nonsparse_array( @offsets ).map_by do |exe_d|
            exe_a.fetch exe_d
          end
        end
      end

      # ==

      module UnmetImperativeTransitions

        # "FOO" and "BAR" {rely|relies} on 'zing zang'

        def self.call d_a, up
          up.listener.call :error, :expression, :unmet_imperatives do |y|
            simple_inflection do
              extend Here_::Event_::ExpressionMethods
              extend UnmetImperativeTransitions
              init_for_wonderful_expression_hack_( y, d_a, up ).express
            end
          end
        end

        def express

          # "fizz and buzz rely on A and bazz relies on B and A and B aren't reached

          h = __pending_executions_via_source_sym
          not_reached = []

          big_buff = oxford_join scanner_ h.keys do |from_sym|

            _scn = scanner_ h.fetch from_sym  # an array of exe offsets

            buff = oxford_join _scn do |d|

              say_pending_execution_ickily_ @up.all_pending_executions.fetch d
            end

            s = say_state_ from_sym

            not_reached.push s

            buff << SPACE_ << v( 'rely' ) << " on " << s

            clear_count_for_inflection

            buff
          end

          clear_count_for_inflection

          big_buff << " and #{ oxford_join scanner_ not_reached }"

          big_buff << " #{ v false, :is } reached."  # isn't reached / aren't reached

          @y << big_buff
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

      module NoTransitionFound  # 1 X

        # totally new techniques.
        # one line or two.

        def self.[] up
          up.listener.call :error, :expression, :no_transition_found do |y|
            simple_inflection do
              extend Here_::Event_::ExpressionMethods
              extend NoTransitionFound
              init_for_wonderful_expression_hack_( y, up ).express
            end
          end
        end

        def express

          if there_are_none_in_the_pool_

            if there_were_no_pending_executions_at_all_

              # "there are no state transitions so nothing brings the system [to a close]"

              write_count_for_inflection 0
              lem = "state transition"

            else

              # "none of the 3 pending executions brings the system [to a close]"
              # "the only pending execution fails to bring the system [to a close]"

              write_count_for_inflection @_remaining_pool_exe_offsets.length
              lem = "pending execution"
            end

            _object = "the system from #{ say_current_state_ } to a finished state."

            @y << "#{ the_only } #{ n lem } #{ no_double_negative "bring" } #{ _object }"
          else
            __the_fun_one
          end
        end

        def there_are_none_in_the_pool_
          @_remaining_pool_exe_offsets = @up.pending_execution_pool_hash.keys
          @_remaining_pool_exe_offsets.length.zero?
        end

        def there_were_no_pending_executions_at_all_
          @up.all_pending_executions.length.zero?
        end

        def __the_fun_one

          # y << %("-run-files" requires "files stream")
          # y << %("-run-files" and "-doc-only" require things like "beginning" and "files stream".)
          # y << %(none of them transition from the state you are in, which is "the beginning state")
          # y << %(it does not transition from the state you are in, which is "the beginning state")

          # two buckets: the switches and the graph state nodes. hearing
          # duplicates of the second bucket is not interesting so we de-dup
          # it (set not list) but if there are repeats of the same switch,
          # we want this staed explicitly (list not set).

          source_node_set = {}

          _scn = scanner_ @_remaining_pool_exe_offsets

          buff = oxford_join _scn do |d|

            exe = @up.all_pending_executions.fetch d

            exe.agent_profile.formal_transitions.each do |ft|
              source_node_set[ ft.from_symbol ] = true
            end

            say_pending_execution_ickily_ exe
          end

          if 1 == source_node_set.length
            s = both_or_all and buff << " #{ s }"
          end

          buff << SPACE_ << v( "require" )

          if 1 < source_node_set.length
            buff << " things like"  # (as in, "not respectively")
          end

          buff << SPACE_

          _scn = scanner_ source_node_set.keys

          oxford_join_do_not_store_count buff, _scn, " and " do |sym|
            say_state_ sym
          end

          buff << DOT_

          @y << buff

          @y << "#{ none_of_them "transition" } #{
            }from the state you are in, which is #{ say_current_state_ }."
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
        s << DOT_
      end

      # ==

      DOT_ = '.'

      # ==
    end
  end
end
# #tombstone-B: rewrote all for simplified modules hack
# :#tombstone-A: we're not clear when this [#tab-001.2] help screen was used,
#   because it was apparently not used by the eponymous [ts] quickie plugin
