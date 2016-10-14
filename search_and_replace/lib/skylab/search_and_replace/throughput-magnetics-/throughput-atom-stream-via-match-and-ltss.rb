module Skylab::SearchAndReplace

  class ThroughputMagnetics_::Throughput_Atom_Stream_via_Match_and_LTSs

    def initialize mc, ltss

      @LTS_stream = ltss
      @match = mc
    end

    # given a current LTS that begins at or before the match begins (and
    # a stream of subsequent LTS's), produce a stream that produces all
    # atoms that compose the match only. advance the LTS stream IFF you
    # express the second half of the LTS.

    def execute

      @_a = [ :match, @match.match_index, :orig ]
      @_cursor = @match.match_charpos
      @_big_string = @match.big_string__
      @_match_end = @match.match_end_charpos

      _populate_cache

      Common_.stream do  # #[#032]
        send @_state
      end
    end

    def __maybe_populate_cache_again_then_gets

      # you get here IFF you have expressed the end of an LTS without having
      # yet expressed the end of the match. IFF there is a next LTS and it
      # starts before the match ends, then repeat our main step method.
      # otherwise just finish expressing the match and you're done.

      if @LTS_stream.unparsed_exists
        # (hi.)
        if @LTS_stream.current_token.charpos < @_match_end
          _yes = true
        end
      end

      if _yes
        @_a = []
        _populate_cache
        send @_state
      else
        @_a = []
        _the_rest_of_the_match_content
        _done
        send @_state
      end
    end

    def _populate_cache

      lts = @LTS_stream.current_token

      lts_begin = lts.charpos
      lts_end = lts.end_charpos

      # (each of the 9 below cases has a counterpart test indicated with
      #  "case N" where N is 1-9, all in "#spot-6"-tagged test files.)

      case lts_begin <=> @_cursor

      when -1  # the LTS begins before the cursor
        case lts_end <=> @_match_end

        when -1  # (1) the LTS ends before the match ends ("L-skewed")
          _LTS_last_half                    #   LL
          _when_LTS_ends_before_match_ends  #    MM

        when 0  # (2) the LTS ends cleanly where the match ends ("L-jutting")
          _LTS_last_half                    #   LL
          _done                             #    M

        when 1  # (3) the LTS ends after the match ends WOAH ("L-enveloping")
             # (nothing at all per spec)    #   LL
          _done                             #  -><-
        end

      when 0  # the LTS begins at the cursor
        case lts_end <=> @_match_end

        when -1  # (4) the LTS ends before the match ends ("M-lagging")
          _whole_LTS                        #    LL
          _maybe_again                      #    MMM

        when 0  # (5) the LTS ends cleanly where the match ends ("same")
          _whole_LTS                        #    LL
          _done                             #    MM

        when 1  # (6) the LTS ends after the match ends ("L-lagging")
          _LTS_first_half                   #    LL
          _done                             #    M

        end
      when 1  # the LTS begins after the cursor

        if @_match_end <= lts_begin  # 10 (oops) the LTS begins after
          # the match ends ("M-kissing", "M cleanly apart")

          _content_until @_match_end
          _done

        else

        _content_until lts_begin

        case lts_end <=> @_match_end

        when -1  # (7) the LTS ends before the match ends ("M-enveloping")
          _whole_LTS                         #    LL
          _when_LTS_ends_before_match_ends   #   MMMM

        when 0  # (8) the LTS ends cleanly where the match ends ("M-jutting")
          _whole_LTS                         #    LL
          _done                              #   MMM

        when 1  # (9) the LTS ends after the match ends ("L-lagging")
          _LTS_first_half                    #    LL
          _done                              #   MM
        end
        end
      end

      # (the above cases all have counterparts in [#005] (an API made for
      #  modeling spatial relationships like this) but we aren't using it
      #  experimentally because perhaps little would be gained (in codesize
      #  reduction) and some is lost (in terms of readability)

      NIL_
    end

    def _LTS_first_half  # leave the LTS on the stream
      d = @_match_end
      @_a.push :LTS_begin, @_big_string[ @_cursor ... d ]
      @_cursor = d
    end

    def _LTS_last_half
      _lts = @LTS_stream.gets_one
      d = _lts.end_charpos
      @_a.push :LTS_continuing, @_big_string[ @_cursor ... d ], :LTS_end
      @_cursor = d
    end

    def _whole_LTS
      lts = @LTS_stream.gets_one
      d = lts.end_charpos
      lts.string == @_big_string[ @_cursor ... d ] or self._SANITY  # #todo
      @_a.push :LTS_begin, lts.string, :LTS_end
      @_cursor = d
    end

    def _when_LTS_ends_before_match_ends

      if @LTS_stream.current_token.charpos < @_match_end
        # if the next LTS begins before the match ends,
        # then it is our problem

        _maybe_again_AGAIN
      else
        # otherwise it is not our problem and we can just finish
        _the_rest_of_the_match_content
        _done
      end
    end

    def _the_rest_of_the_match_content
      _content_until @_match_end
    end

    def _content_until d
      @_a.push :content, @_big_string[ @_cursor ... d ]
      @_cursor = d
    end

    def _maybe_again_AGAIN  # #todo
      _maybe_again
    end

    def _maybe_again
      _transition_to_state_via_cache_stream
      @_state_after = :__maybe_populate_cache_again_then_gets
      NIL_
    end

    def _done
      _transition_to_state_via_cache_stream
      @_state_after = :__nothing
      NIL_
    end

    def _transition_to_state_via_cache_stream

      @_state = :__via_cache_stream
      @_cache_stream = Common_::Stream.via_nonsparse_array(
        remove_instance_variable :@_a )
      NIL_
    end

    def __via_cache_stream
      x = @_cache_stream.gets
      if x
        x
      else
        @_state = remove_instance_variable :@_state_after
        send @_state
      end
    end

    def __nothing
      NOTHING_
    end
  end
end
# #history: replaced genetic ancestor file(s) in a different location
