module Skylab::SearchAndReplace

  class ThroughputMagnetics_::Throughput_Atom_Stream_via_Replacement_and_LTSs

    def initialize mc, ltss

      @LTS_stream = ltss
      @match = mc
    end

    def execute
      __just_completely_ignore_whatever_LTSS_we_cover
      __make_that_stream
    end

    def __just_completely_ignore_whatever_LTSS_we_cover

      # any LTS that ends at or before the ending of the replacement
      # (same as match) span, just disregard that LTS fully.

      d = @match.match_end_charpos

      st = remove_instance_variable :@LTS_stream
      begin

        if st.no_unparsed_exists
          break
        end

        # if the LTS ends after we end (even if it overlaps with us), it is
        # out of our jurisdiction. we must leave it on the queue

        if d < st.head_as_is.end_charpos
          break
        end

        st.advance_one
        redo
      end while nil
      NIL_
    end

    def __make_that_stream

      # first we make an "introductory chunk" that declares match attributes

      _transition_to_cache [ :match, @match.match_index, :repl ]

      # when the above chunk (cache) is exhausted, then do one-off state:

      @_next_state = :___some_or_none_then_gets

      Common_.stream do  # #[#032]
        send @_state
      end
    end

    def ___some_or_none_then_gets

      s = @match.replacement_value
      d = s.length
      if d.zero?
        # (it may or may not be necessary to handle this edge case explicitly)
        _transition_to_done_then_gets
      else
        @_cursor = 0
        @_end_charpos = d
        @_LTS_stream = Home_::StringEditSession_::Line_Scanner_.new s
        @_replacement_string = s
        @_state = :_next_line_or_done
        send @_state
      end
    end

    def _this_AGAIN  # #todo
      _next_line_or_done
    end

    def _next_line_or_done

      # reminder: *this* LTS stream is our *own* stream, it is not that of
      # the real document. assume we are guaranteed an [#011] "endcap" LTS
      # that is possibly zero-width.. (see #here .. there is a lurking issue)

      lts = @_LTS_stream.gets
      if lts
        ___transition_to_cache_then_gets lts
      else
        _transition_to_done_then_gets
      end
    end

    def ___transition_to_cache_then_gets lts

      # load a cache array up with the atoms for one line, then change
      # your mode so you are reading from this array. when the array is
      # exhausted, gets the next line [fragment] or you're done

      a = []
      d = lts.charpos

      orig_cursor = @_cursor

      if @_cursor < d
        a.push :content, @_replacement_string[ @_cursor ... d ]
        @_cursor = d
      end

      if lts.sequence_width.nonzero?  # FOR NOW :#here
        a.push :LTS_begin, lts.string, :LTS_end
        @_cursor = lts.end_charpos
      end

      if orig_cursor == @_cursor
        # (then `a`'s presence was "wasted" here)
        # (we are not sure this can ever be triggered .. #todo)
        ::Kernel._K_change_state_to_nothing_and_cover_this
      else
        @_next_state = :_this_AGAIN
        _transition_to_cache a
        send @_state
      end
    end

    def _transition_to_cache a

      @_atom_stream = Stream_[ a ]
      @_state = :___gets_via_cache ; nil
    end

    def ___gets_via_cache
      x = @_atom_stream.gets
      if x
        x
      else
        @_state = remove_instance_variable :@_next_state
        send @_state
      end
    end

    def _transition_to_done_then_gets
      remove_instance_variable :@_state
      NOTHING_
    end
  end
end
# #history: rename & full rewrite of Sexp_Stream_via_String
