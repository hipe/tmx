module Skylab::System

  class Diff

    class Magnetics::HunkStream_via_FileDiffProcess < Common_::MagneticBySimpleModel

      # a state machine for parsing a unified diff of two files

      # -

        attr_writer(
          :do_result_in_line_stream,
          :process,
        )

        def initialize
          @do_result_in_line_stream = false
          super
        end

        def execute
          if @do_result_in_line_stream
            __flush_to_line_stream
          else
            __flush_to_hunk_stream
          end
        end

        def __flush_to_hunk_stream
          @_gets_hunk = :__gets_first_hunk
          Common_.stream do
            send @_gets_hunk
          end
        end

        def __flush_to_line_stream
          out = @process.out
          p = nil
          main = -> do
            line = out.gets
            if line
              line
            else
              @_expected_exitstatus = 1
              _check_and_close
            end
          end
          p = -> do
            line = out.gets
            if line
              p = main
              line
            else
              p = nil
              @_expected_exitstatus = 0
              _check_and_close
            end
          end
          Common_.stream do
            p[]
          end
        end

        def __gets_first_hunk

          out = @process.out
          line_scn = Common_.stream do
            out.gets
          end.flush_to_scanner

          # if we can peek now that the output from the diff command is no
          # output, then we save ourselves the trip to the state macine.

          if line_scn.no_unparsed_exists
            @_expected_exitstatus = 0
            _check_and_close
          else
            @_expected_exitstatus = 1
            __gets_first_hunk_normally line_scn
          end
        end

        def __gets_first_hunk_normally line_scn

          @__hunk_stream = HunkStream_via_LineScanner___[ line_scn ]
          @_gets_hunk = :__gets_hunk
          send @_gets_hunk
        end

        def __gets_hunk
          hunk = @__hunk_stream.gets
          if hunk
            hunk
          else
            remove_instance_variable :@__hunk_stream
            remove_instance_variable :@_gets_hunk
            _check_and_close
          end
        end

        def _check_and_close
          ok = __check_err
          ok &&= __check_exitstatus
          ok && __close
        end

        def __check_err
          s = @process.err.gets
          if s
            self._COVER_ME__unexpected_stderr_output__
          else
            ACHIEVED_
          end
        end

        def __check_exitstatus
          act_d = @process.wait.value.exitstatus
          exp_d = remove_instance_variable :@_expected_exitstatus
          if exp_d == act_d
            ACHIEVED_  # normal result for diff when there is a difference
          else
            self._COVER_ME__exitstatus_was_unexpected__
          end
        end

        def __close
          @_gets_hunk = :__NOTHING
          remove_instance_variable :@process
          freeze
          send @_gets_hunk
        end

        def __NOTHING
          NOTHING_
        end
      # -

      # ==

      HunkStream_via_LineScanner___ = -> line_scn do

        # (we would normally memoize the state machine but at the last
        # minute we had to flip the script to accomodate storing those
        # first two lines we parse in a structure that is not a hunk.
        # this required that we alter what class we use for the downstream
        # mid-parse, a stunt that is not covered.)

        o = Home_.lib_.basic::StateMachine.begin_definition

        o.add_state(
          :beginning,
          :can_transition_to, :minus_minus_minus,
        )

        appropriate_downstream_normally = -> do
          Hunk___.new
        end

        appropriate_downstream = -> do
          appropriate_downstream = nil  # sanity
          DiffHeader___.new
        end

        o.add_state(
          :minus_minus_minus,
          :entered_by_regex, %r(\A---[ ]),
          :on_entry, -> sm do
            sm.downstream.__receive_diff_header_line_one_ sm.user_matchdata
            :plus_plus_plus
          end,
        )

        o.add_state(
          :plus_plus_plus,
          :entered_by_regex, %r(\A\+\+\+[ ]),
          :on_entry, -> sm do
            sm.downstream.__receive_diff_header_line_two_ sm.user_matchdata
            appropriate_downstream = appropriate_downstream_normally
            sm.TURN_PAGE_OVER
            NIL
          end,
          :can_transition_to, :first_ever_hunk_header,
        )

        hunk_rx = %r(\A@@ -\d+,\d+ \+\d+,\d+ @@$)
        hunk_transitions = [
          :context_line,
          :minus_line,
          :plus_line,
        ]

        o.add_state(
          :first_ever_hunk_header,
          :entered_by_regex, hunk_rx,
          :on_entry, -> sm do
            sm.downstream._receive_hunk_header_ sm.user_matchdata
            NIL
          end,
          :can_transition_to, hunk_transitions
        )

        these = [
          * hunk_transitions,
          :A_NONFIRST_hunk_header,
          :my_end,
        ]

        o.add_state(
          :context_line,
          :entered_by_regex, %r(\A[ ]),
          :on_entry, -> sm do
            sm.downstream.__receive_context_line_ sm.user_matchdata
            NIL
          end,
          :can_transition_to, these,
        )

        o.add_state(
          :minus_line,
          :entered_by_regex, %r(\A-),
          :on_entry, -> sm do
            sm.downstream.__receive_remove_line_ sm.user_matchdata
            NIL
          end,
          :can_transition_to, these,
        )

        o.add_state(
          :plus_line,
          :entered_by_regex, %r(\A\+),
          :on_entry, -> sm do
            sm.downstream.__receive_add_line_ sm.user_matchdata
            NIL
          end,
          :can_transition_to, these,
        )

        o.add_state(
          :A_NONFIRST_hunk_header,
          :entered_by_regex, hunk_rx,
          :on_entry, -> sm do
            sm.TURN_PAGE_OVER
            sm.downstream._receive_hunk_header_ sm.user_matchdata
            NIL
          end,
          :can_transition_to, hunk_transitions,
        )

        o.add_state(
          :my_end,
          :entered_by, -> st do
            # (you can enter the 'end' state IFF the upstream is empty)
            st.no_unparsed_exists
          end,
          :on_entry, -> sm do
            sm.receive_end_of_solution_when_paginated
          end,
        )

        _sm_definition = o.finish

        _sm_definition.begin_passive_session_by do |sess|

          sess.upstream = line_scn

          sess.downstream_by = -> do
            appropriate_downstream[]
          end
        end
      end

      # ==

      class DiffHeader___
        def initialize
          @__mutex_1 = @__mutex_2 = nil
        end
        def __receive_diff_header_line_one_ md
          remove_instance_variable :@__mutex_1
          @_line_1_matchdata = md ; nil
        end
        def __receive_diff_header_line_two_ md
          remove_instance_variable :@__mutex_2
          @_line_2_matchdata = md
          freeze ; nil
        end
        def to_line_stream
          Stream_[ [ @_line_1_matchdata.string, @_line_2_matchdata.string ] ]
        end
        def finish_when_paginated
          self
        end
        def category_symbol___
          :diff_header
        end
      end

      class Hunk___

        def initialize
          NOTHING_
        end

        def _receive_hunk_header_ md
          @_runs = [ Header___.new( md ) ]
        end

        def __receive_context_line_ md
          _add( :context,  md ) { ContextRun__ }
        end

        def __receive_remove_line_ md
          _add( :remove,  md ) { RemoveRun__ }
        end

        def __receive_add_line_ md
          _add( :add,  md ) { AddRun__ }
        end

        def _add sym, md
          run = @_runs.last
          if run.category_symbol != sym
            run.close
            run = yield.new
            @_runs.push run
          end
          run.accept md
          NIL
        end

        def finish_when_paginated
          @_runs.freeze
          freeze
        end

        def to_line_stream
          to_run_stream.expand_by do |run|
            run.to_line_stream
          end
        end

        def to_run_stream
          Stream_[ @_runs ]
        end

        def category_symbol___
          :hunk
        end
      end

      Run__ = ::Class.new

      class Header___
        def initialize md
          @_md = md
        end
        def category_symbol
          :header
        end
        def close
          NOTHING_
        end
        def to_line_stream
          Common_::Stream.via_item @_md.string
        end
      end

      class ContextRun__ < Run__
        def category_symbol
          :context
        end
      end

      class RemoveRun__ < Run__
        def category_symbol
          :remove
        end
      end

      class AddRun__ < Run__
        def category_symbol
          :add
        end
      end

      class Run__
        def initialize
          @_matchdata_array = []
        end
        def accept md
          @_matchdata_array.push md ; nil
        end
        def close
          @_matchdata_array.freeze
          freeze ; nil
        end
        def to_line_stream
          Stream_[ @_matchdata_array ].map_by do |md|
            md.string
          end
        end
      end

      # ==

    end
  end
end
# #history-B.1: inject experimental line-based option (needs coverage)
# #history: full rewrite of ancient [tm] thing
