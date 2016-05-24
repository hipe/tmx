module Skylab::SearchAndReplace

  class Throughput_Magnetics_::Throughput_Atom_Stream_via_Match_and_LTSs

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

      _populate_cache

      Callback_.stream do
        send @_state
      end
    end

    def _populate_cache

      lts = @LTS_stream.current_token

      lts_begin = lts.charpos
      lts_end = lts.end_charpos
      match_begin = @match.match_charpos
      match_end = @match.match_end_charpos

      case lts_begin <=> match_begin

      when -1  # the LTS begins before the match begins
        case lts_end <=> match_end

        when -1  # the LTS ends before the match ends (1) ("L-skewed")
          _LTS_last_half                 #   LL
          __after_LTS_ends               #    MM

        when 0  # the LTS ends cleanly where the match ends (2) ("L-jutting")
          ::Kernel._K
          self._LTS_last_half            #   LL
          self._done                     #    M

        when 1  # the LTS ends after the match ends WOAH (3) ("L-enveloping")
          ::Kernel._K                    #     LL
          self._done                     #    -><-
        end

      when 0  # the LTS and match begin at the same cel
        case lts_end <=> match_end

        when -1  # the LTS ends before the match ends (4) ("M-lagging")
          ::Kernel._K
          self._whole_LTS                #    LL
          self._again                    #    MMM

        when 0  # the LTS ends cleanly where the match ends (5) ("same")
          ::Kernel._K
          self._whole_LTS                #    LL
          self._done                     #    MM

        when 1  # the LTS ends after the match ends (6) ("L-lagging")
          ::Kernel._K
          self._LTS_first_half           #    LL
          self._done                     #    M

        end
      when 1  # the LTS begins after the match begins

        _content_until lts_begin

        case lts_end <=> match_end

        when -1  # the LTS ends before the match ends (7) ("M-enveloping")
          ::Kernel._K
          _whole_LTS                      #    LL
          self._QUE                       #   MMMM

        when 0  # the LTS ends cleanly where the match ends (8) ("M-jutting")
          ::Kernel._K
          _whole_LTS                      #    LL
          _done                           #   MMM

        when 1  # the LTS ends after the match ends (9) ("L-lagging")
          _LTS_first_half                 #    LL
          _done                           #   MM
        end
      end

      NIL_
    end

    def _LTS_first_half  # leave the LTS on the stream
      d = @match.match_end_charpos
      @_a.push :LTS_begin, @_big_string[ @_cursor ... d ]
      @_cursor = d
    end

    def _LTS_last_half
      _lts = @LTS_stream.gets_one
      d = _lts.end_charpos
      @_a.push :LTS_continuing, @_big_string[ @_cursor ... d ], :LTS_end
      @_cursor = d
    end

    def __after_LTS_ends

      # NOTE for now we're assuming there's always another LTS
      # per [#011] #decision-A

      if @LTS_stream.current_token.charpos < @match.end_charpos
        # if the next LTS begins before the match ends,
        # then it is our problem

        ::Kernel._K
        _transition_to_state_via_cache_stream
        @_state_after = :_again
      else
        # otherwise it is not our problem and we can just finish
        _content_until @match.end_charpos
        _done
      end
    end

    def _content_until d
      @_a.push :content, @_big_string[ @_cursor ... d ]
      @_cursor = d
    end

    def _done

      _transition_to_state_via_cache_stream
      @_state_after = :__nothing
      NIL_
    end

    def _transition_to_state_via_cache_stream

      @_state = :__via_cache_stream
      @_cache_stream = Callback_::Stream.via_nonsparse_array(
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
