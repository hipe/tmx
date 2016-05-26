module Skylab::SearchAndReplace

  class StringEditSession_

      class Build_Context_Streams___

        # (in avoidance of a third full rewrite, lots of comments this time..)
        #
        # result is a three-tuple of mixed's, each value corresponding to
        # the (any) "before", "during", and "after" run of [#010] lines as
        # expressed by the arguments.
        #
        # each component value is either falseish or a stream that produces
        # at least one line-sexp; based on how many lines are in the run:
        #
        # the "during" section is those lines that encompass the match
        # inside the argument match controller.
        #
        # the lines in the "before" and "after" runs are a function of
        # business state (document and matches) and particular arguments:
        #
        #   • for each such run there is a required argument N which
        #     determines the *maximum* number of lines that will be
        #     produced for that section.
        #
        #   • the lines in the run are the (up to) N lines that abut the
        #     "during" lines (immediately above or below them respectively).
        #
        #   • if there are not enough lines in the file above or below
        #     (respectively) the lines in the "during" run, the number
        #     of lines in that section will be less than N by some
        #     knowable amount.
        #
        #   • e.g it is possible that zero lines express the run (IFF the
        #     match lines are anchored at the beginning and/or end of the
        #     file, respectively).
        #

        # the underlying system is generally stream- and linked-list-based
        # but this operation is what we might call "output-document-
        # structure-based"; and from this stems the main challenge here,
        # given the OCD premise of our approach..  (continued at [#031])

        attr_writer(
          :block,
          :match_controller,
          :num_lines_after,
          :num_lines_before,
        )

        # (none of the below will make sense without understanding all of
        # [#010]/figure-1.)
        #
        # assume one block with one or more matches. matches can span
        # multiple lines. the match of interest is not necessarily the first
        # match. ergo there are zero or more lines before and after the
        # lines of the match of interest that we may need when determining
        # the target component values.
        #
        # thru an ad-hoc state machine, effectively classify perhaps every
        # line of the lines of the block. we do this thru stream-centric
        # parsing rather than giving ourselves arbitrary lookahead, with
        # the justification that we don't necessarily need to parse every
        # line in the block for certain N maxinum number of "after" lines
        # for certain blocks and certain matches.
        #
        # as such in a "brute force" way we search for when we hit the line
        # that (variously per state) begins then ends the match of interest
        # (which is possibly (and often) the same line). at these evenpoints
        # we change state so we handle each incoming line appropriately:
        #
        # for all cases of N except the case of wanting 0 lines of "before",
        # for each incoming line that is known to be before the first line
        # in of interest we store it in a rotating buffer: we won't know
        # until we hit that line whether or not we needed to keep each
        # encountered line previous to it.
        #
        # for needing more than zero of the "after" lines, it is easier:
        # gets each item off the stream until you run out of stream or you
        # hit your limit, whichever comes first.
        #
        # for the (frequent) cases that you do *not* reach your N, you will
        # have to seek backwards and forwards on respectively previous and
        # next blocks (if any) to try and fill the limit, which is its own
        # thing..

        def execute
          __init_detection_methods
          __prepare_state_machine
          __init_three_arrays
          __maybe_extend_lines_backwards
          __maybe_extend_lines_forwards
          __produce_final_three_values
        end

        # -- phase 3 - final assembly

        def __produce_final_three_values

          _any_before_st = _final_result @num_lines_before, :@_before_buffer

          _any_after_st = _final_result @num_lines_after, :@_after_buffer

          _during_st = _stream_for @_during_buffer

          [ _any_before_st, _during_st, _any_after_st ]
        end

        def _final_result target_d, ivar

          if target_d.zero?
            NOTHING_  # give the client the ability to "peek" that it's zero
          else
            x = instance_variable_get ivar
            if x
              _stream_for x
            else
              NOTHING_  # again, same
            end
          end
        end

        def _stream_for x
          Callback_::Stream.via_nonsparse_array x.to_a  # `to_a` for rotbuff
        end

        # -- phase 2 - extend into other blocks

        def __maybe_extend_lines_backwards

          _maybe_extend(
            @num_lines_before,
            :@_before_buffer,
            :previous_block,
            :write_the_previous_N_line_sexp_arrays_in_front_of,
          )
        end

        def __maybe_extend_lines_forwards

          _maybe_extend(
            @num_lines_after,
            :@_after_buffer,
            :next_block,
            :write_the_next_N_line_sexp_arrays_into,
          )
        end

        def _maybe_extend target_d, ivar, block_m, write_m

          if target_d.nonzero?

            x = instance_variable_get ivar

            deficit = target_d - ___effective_length_of( x )
            if deficit.nonzero?

              block = @block.send block_m
              if block

                __try_extend block, deficit, x, ivar, write_m
                NIL_
              end
            end
          end
        end

        def ___effective_length_of x
          if x
            x.length
          else
            0
          end
        end

        def __try_extend block, deficit, x, ivar, write_m

          if x
            a = x
          else
            made = true
            a = []
          end

          len = a.length
          block.send write_m, a, deficit
          if len != a.length && made
            instance_variable_set ivar, a
          end
          NIL_
        end

        # -- phase 1 - init three arrays

        def __init_three_arrays

          st = @block.to_line_atom_array_stream_
          __consume_state :initial_state
          @_is_done = false

          begin
            @_line_x = st.gets
            @_line_x or break
            @_state[]
            if @_is_done
              break
            end
            redo
          end while nil
          NIL_
        end

        def __init_detection_methods

          match_d = @match_controller.match_index

          beginning_of_interest = -> sx do

            if :zero_width == sx.first && Is_beginning___[ sx[ 1 ] ]
              match_d == sx.last  # (hi.)
            end
          end

          ending_of_interest = -> sx do
            if :zero_width == sx.first && Is_ending___[ sx[ 1 ] ]  # waste
              match_d == sx.last  # (hi.)
            end
          end

          @_current_line_contains_beginning_of_match = -> do
            @_line_x.index( & beginning_of_interest )
          end

          @_current_line_contains_end_of_match = -> do
            # (technically there is waste in this search..)
            @_line_x.index( & ending_of_interest )
          end

          NIL_
        end

        def __prepare_state_machine

          o = {}
          o[ :initial_state ] = method :__initial_state
          o[ :move_to_before_state ] = method :__move_to_before_state
          o[ :move_to_during_state ] = method :__move_to_during_state
          o[ :move_to_after_state ] = method :__move_to_after_state
          o[ :done ] = method :__move_to_done_state
          @_states = o
          NIL_
        end

        def __initial_state

          if @_current_line_contains_beginning_of_match[]

            if @num_lines_before.nonzero?
              # (because you're skipping the whole "before" state:)
              @_before_buffer = nil
            end

            _once :move_to_during_state
          else
            _once :move_to_before_state
          end
        end

        def __move_to_before_state

          # assume a current line that is known to be the first known line
          # that is before the line of interest (i.e first line of the block)

          if @num_lines_before.zero?

            # then we don't event set the ivar - the state we are in
            # is a state of waiting for the first line of interest.

            @_state = -> do
              if @_current_line_contains_beginning_of_match[]
                _once :move_to_during_state
              end
              NIL_
            end
          else

            # you might want this line (and every line after it until etc.)
            # but you won't know when until you get there so:

            rb = Home_.lib_.basic::Rotating_Buffer[ @num_lines_before ]
            @_before_buffer = rb
            rb << @_line_x
            @_state = -> do
              if @_current_line_contains_beginning_of_match[]
                _once :move_to_during_state
              else
                rb << @_line_x
              end
              NIL_
            end
          end
          NIL_
        end

        def __move_to_during_state

          # assume current line that is the first line of interest..

          a = [ @_line_x ]
          @_during_buffer = a

          if @_current_line_contains_end_of_match[]
            _once :move_to_after_state
          else
            @_state = -> do
              a.push @_line_x
              if @_current_line_contains_end_of_match[]
                _once :move_to_after_state
              end
              NIL_
            end
          end
          NIL_
        end

        # because of the way in which building the "after" lines is easier
        # than building the "before" lines, for the "after" stream of the
        # final result we could instead result in a stream that calculates
        # each next line "lazily" in real-time rather than doing all the
        # calculation up front (as we do for the "before").
        #
        # such a techinque would hypothetically achieve a different
        # "distribution of latency", one that PERHAPS would be more
        # desireable for some output modalities (those where it is better
        # to have more "stream-y" output).
        #
        # however, this technique would have at least two costs:
        #
        #   • currently there is *full* logical symmetry: whether extending
        #     forwards or backwards into adjacent blocks, the logic (and
        #     code) is the same. we would lose this, meaning more code to
        #     debug, test & maintain.
        #
        #   • currently we produce (internally) the full "after" content
        #     as an array before resulting it as a stream. this array may
        #     be more convenient for deubugging than working with a true
        #     stream.
        #
        # BUT NOTE that our final result is streams (when there is content)
        # and not arrays so that we are not locked into the above decision.

        def __move_to_after_state

          # assume current line that is classified as "during". you know
          # that the current line contains the end of the match but you
          # don't know if you will encounter any lines after that.

          if @num_lines_after.zero?

            # then don't even set the ivar, you're done
            _once :done

          else

            # you want more lines but don't know if you will find them.
            @_after_buffer = nil

            @_state = -> do

              # if you got here it means it's on the first "after" line ..
              a = []
              @_after_buffer = a
              # ..so for this line and every line after:

              @_state = -> do
                a.push @_line_x
                if @num_lines_after == a.length
                  _once :done
                end
              end
              @_state.call
              NIL_
            end
            NIL_
          end
        end

        def __move_to_done_state

          # (because of the way we conditionally nil'd things out and how
          # rotbuffs work, there is no finalization to do. ivars are set.)
          @_is_done = true
          remove_instance_variable :@_states
          remove_instance_variable :@_state
          NIL_
        end

        # ~

        def _once sym
          @_state = nil  # sanity
          _p = _remove_state sym
          _p.call
          NIL_
        end

        def __consume_state sym

          @_state = _remove_state sym
          NIL_
        end

        def _remove_state sym
          x = @_states.fetch sym
          @_states.delete sym
          x
        end

        Is_beginning___ = {
          disengaged_match_begin: true,
          replacement_begin: true,
        }

        Is_ending___ = {
          disengaged_match_end: true,
          replacement_end: true,
        }
      end
  end
end
