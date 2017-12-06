module Skylab::SearchAndReplace

  class ThroughputMagnetics_::Throughput_Atom_Stream_via_Matches_Block

    def initialize o

      @_a = nil
      @_big_string = o.big_string__
      @_cursor = o.block_charpos
      @_in_static_mode = false
      @_state = nil

      a = o.all_things

      @_LTS_stream = Stream_[ o.LTS_indexes ].map_by do |d|
        a.fetch d
      end.flush_to_scanner

      @_match_stream = Stream_[ o.MC_indexes ].map_by do |d|
        a.fetch d
      end
    end

    def execute

      _reorient

      Common_.stream do
        send @_state
      end
    end

    def _reorient_then_gets_THIRD  # #todo
      _reorient
      send @_state
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

      @_match ||= @_match_stream.gets  # leave it if it is there for #here
      if @_match
        if @_LTS_stream.unparsed_exists
          if @_LTS_stream.head_as_is.charpos < @_match.charpos
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
        @_state = :_nothing
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

      @_atom_stream = if @_match.replacement_is_engaged
        Home_::ThroughputMagnetics_::Throughput_Atom_Stream_via_Replacement_and_LTSs.
          new( @_match, @_LTS_stream ).execute
      else
        Home_::ThroughputMagnetics_::Throughput_Atom_Stream_via_Match_and_LTSs.
          new( @_match, @_LTS_stream ).execute
      end

      @_match = nil  # for #here, you consumed it above

      @_in_static_mode = false
      @_state = :_via_atom_stream
      @_state_after = :_reorient_then_gets

      NIL_
    end

    def __transition_to_LTS_then_match

      # the LTS starts before the match starts (and might also start before
      # the cursor). does it also end before the match starts?

      @_a = nil

      lts = @_LTS_stream.head_as_is

      if lts.end_charpos <= @_match.match_charpos

        # if the end boundary of the LTS is before or meets the beginning
        # boundary of the match, express the some remaining fragment of the
        # LTS in full then reorient on this SAME (#here) match again.

        @_LTS_stream.advance_one
        _any_content_before lts.charpos  # not sure if nec.
        __the_rest_of_the_LTS lts
        @_a or self._SANITY
        _transition_to_cache
        @_state_after = :_reorient_then_gets_THIRD

      else
        # then it starts before but ends after the match starts

        _any_content_before lts.charpos
        __any_first_part_of_LTS
        if @_a
          _transition_to_cache
          @_state_after = :_transition_to_match_and_LTS_then_gets
        else
          _transition_to_match_and_LTS
        end
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

        _finish_already_started_LTS lts

      when 0  # LTS starts where cursor starts

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

    def __any_first_part_of_LTS  # because cursor might be after LTS begin

      d = @_match.match_charpos

      if d != @_cursor
        _push_static :LTS_begin, @_big_string[ @_cursor ... d ]
        @_cursor = d ; nil
      end
    end

    def __the_rest_of_the_LTS lts
      if @_cursor == lts.charpos
        _full_LTS lts
      else
        _finish_already_started_LTS lts  # case 10 of #spot-6
      end
    end

    def _finish_already_started_LTS lts
      d = lts.end_charpos
      _push_static :LTS_continuing, @_big_string[ @_cursor ... d ], :LTS_end
      @_cursor = d
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

      @_atom_stream = Stream_[ @_a ]
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
      @_state_after = :_nothing
    end

    def _nothing
      NOTHING_
    end
  end
end
# #history: replaced genetic ancestor file(s) in a different location
