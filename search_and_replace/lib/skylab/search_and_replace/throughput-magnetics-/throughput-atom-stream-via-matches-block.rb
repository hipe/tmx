module Skylab::SearchAndReplace

  class Throughput_Magnetics_::Throughput_Atom_Stream_via_Matches_Block

    def initialize o

      @_a = nil
      @_big_string = o.big_string__
      @_cursor = o.block_charpos
      @_in_static_mode = false
      @_state = nil

      a = o.all_things

      @_LTS_stream = Callback_::Stream.via_nonsparse_array o.LTS_indexes do |d|
        a.fetch d
      end.flush_to_polymorphic_stream

      @_match_stream = Callback_::Stream.via_nonsparse_array o.MC_indexes do |d|
        a.fetch d
      end
    end

    def execute

      _reorient

      Callback_.stream do
        send @_state
      end
    end

    def _reorient_then_gets_AGAIN  # #todo
      _reorient
      send @_state
    end

    def _reorient_then_gets
      _reorient
      send @_state
    end

    def _reorient

      remove_instance_variable :@_state

      @_match = @_match_stream.gets
      if @_match
        if @_LTS_stream.unparsed_exists
          if @_LTS_stream.current_token.charpos < @_match.charpos
            __transition_to_LTS_then_match
          else
            __transition_to_any_static_then_match_and_LTS
          end
        else
          self._WHEN_no_more_LTS
        end
      elsif @_LTS_stream.unparsed_exists
        _transition_to_remaining_LTSs_only
      else
        self._done
      end
      NIL_
    end

    def __transition_to_any_static_then_match_and_LTS

      # assume the head LTS starts at or after the head match starts. but
      # if the cursor lies anywhere before the start of the head match,
      # its our responsibility (not its) to express that static conten span.

      d = @_match.match_charpos
      if @_cursor < d
        _content_before d
        @_state_after = :_transition_to_match_and_LTS_then_gets_AGAIN
        _transition_to_cache
      else
        _transition_to_match_and_LTS
      end
    end

    def _transition_to_match_and_LTS_then_gets_AGAIN
      _transition_to_match_and_LTS
      send @_state
    end

    def _transition_to_match_and_LTS_then_gets
      _transition_to_match_and_LTS
      send @_state
    end

    def _transition_to_match_and_LTS

      @_cursor = @_match.match_end_charpos

      @_atom_stream = Home_::Throughput_Magnetics_::
        Throughput_Atom_Stream_via_Match_and_LTSs.new(
          @_match, @_LTS_stream ).execute

      @_in_static_mode = false
      @_state = :_via_atom_stream
      @_state_after = :_reorient_then_gets

      NIL_
    end

    def __transition_to_LTS_then_match

      # the LTS starts before the match (and might also start before
      # the cursor.) does it end before the match?

      @_a = nil

      lts = @_LTS_stream.current_token

      if lts.end_charpos <= @_match.match_charpos
        @_state_after = :SOMETHING
        self._A
      else
        # then it starts before but ends after the match starts

        _any_content_before lts.charpos
        _any_first_part_of_LTS
        if @_a
          _transition_to_cache
          @_state_after = :_transition_to_match_and_LTS_then_gets
        else
          _transition_to_match_and_LTS
        end
      end
    end

    def _any_first_part_of_LTS  # because cursor migth be after LTS begin

      d = @_match.match_charpos

      if d != @_cursor
        _push_static :LTS_begin, @_big_string[ @_cursor ... d ]
        @_cursor = d ; nil
      end
    end

    def __this_again
      _transition_to_remaining_LTSs_only
      send @_state
    end

    def _transition_to_remaining_LTSs_only

      lts = @_LTS_stream.gets_one

      case lts.charpos <=> @_cursor

      when -1  # we are in the middle of the LTS

        d = lts.end_charpos
        _push_static :LTS_continuing, @_big_string[ @_cursor ... d ], :LTS_end

        @_cursor = d

      when 0  # LTS starts where cursor starts
        ::Kernel._K

        _full_LTS lts

      when 1  # some content, then LTS

        _content_before lts.charpos
        _full_LTS lts
      end

      _transition_to_cache

      if @_LTS_stream.unparsed_exists
        @_state_after = :__this_again
      else
        _done
      end
      NIL_
    end

    def _full_LTS lts
      d = lts.end_charpos
      @_big_string[ @_cursor ... d ] == lts.string or self._SANITY  # #todo
      _push_static :LTS_begin, lts.string, :LTS_end
      @_cursor = d
    end

    def _any_content_before d
      if @_cursor < d
        _content_before d
      end
    end

    def _content_before d

      _push_static :content, @_big_string[ @_cursor ... d ]
      @_cursor = d ; nil
    end

    def _push_static * a
      if ! @_a
        @_a = []
        if ! @_in_static_mode
          @_in_static_mode = true
          @_a.push :static
        end
      end
      @_a.concat a ; nil
    end

    def _transition_to_cache

      @_atom_stream = Callback_::Stream.via_nonsparse_array @_a
      @_a = nil
      @_state = :_via_atom_stream ; nil
    end

    def _via_atom_stream
      x = @_atom_stream.gets
      if x
        x
      else
        @_state = remove_instance_variable :@_state_after
        send @_state
      end
    end

    def _done
      @_state_after = :___nothing
    end

    def ___nothing
      NOTHING_
    end
  end
end
# #history: replaced genetic ancestor file(s) in a different location
