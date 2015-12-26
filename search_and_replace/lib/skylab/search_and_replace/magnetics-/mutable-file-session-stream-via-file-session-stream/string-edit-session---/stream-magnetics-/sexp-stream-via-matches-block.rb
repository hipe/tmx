module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Stream_Magnetics_::Sexp_stream_via_matches_block < Callback_::Actor::Dyadic

        # given a [#010] block that has one or more matches, produce a
        # stream of [#012] sexp nodes representing the content with
        # replacements applied.

        def initialize x, s
          @_block = x
          @_the_big_string = s
        end

        def execute

          @_current_pos, @_block_end = @_block.offsets
          @_match_controller_stream = __build_match_controller_stream
          @_mc = @_match_controller_stream.gets  # assume one
          _on_unclassified_match
          Callback_.stream do
            @_p[]
          end
        end

        def _seek_next_match

          @_mc = @_match_controller_stream.gets
          if @_mc  # then we have another match ..
            _on_unclassified_match
          else
            # (hi.)
            if @_block_end == @_current_pos
              self._FINE_EASY_JUST_END_IT
            else
              _ = _sexp_stream_for_static_run @_current_pos, @_block_end
              @_p = _ ; nil
            end
          end
        end

        def _on_unclassified_match

          d = @_mc.pos
          if @_current_pos == d  # then render this match now
            _on_match
          else  # else the block starts with some static
            _on_static_then @_current_pos, d do
              @_current_pos = d
              _on_match
            end
          end
        end

        def _on_match

          if @_mc.replacement_is_engaged
            _on_engaged_match
          else
            _on_disengaged_match
          end
        end

        def _on_engaged_match
          @_p = -> do
            ___on_engaged_match_body
            # before we output the content, we will output meta-data:
            [ :zero_width, :replacement_begin, @_mc.match_index ]
          end ; nil
        end

        def ___on_engaged_match_body
          s = @_mc.replacement_value
          if s
            ___on_trueish_replacement s
          else
            self._DESIGN_ME_replacement_value_was_falseish_dot_dot_
            # .. is this an error or do we take it to mean "no content"
            # (i.e the empty string)? we'll decide when it comes up.
          end
        end

        def ___on_trueish_replacement s
          # produce a gets-proc that produces sexp nodes for the replacement.
          sexp_st = Stream_Magnetics_::Sexp_Stream_via_String[ :repl_str, s ]
          @_p = -> do
            x = sexp_st.gets
            if x
              x  # you got a[nother] sexp from the replacement value
            else
              d = @_mc.match_index
              _after_match
              [ :zero_width, :replacement_end, d ]
            end
          end ; nil
        end

        def _on_disengaged_match
          @_p = -> do
            d = @_mc.match_index
            ___on_disengaged_match_body
            [ :zero_width, :disengaged_match_begin, d ]
          end ; nil
        end

        def ___on_disengaged_match_body

          _on_static_then( * @_mc.offsets ) do

            @_p = -> do

              d = @_mc.match_index
              _after_match
              [ :zero_width, :disengaged_match_end, d ]
            end ; nil
          end
        end

        def _after_match

          # when you have reached the end of either sort of match

          @_current_pos = @_mc.end

          if @_block_end == @_current_pos  # end of match is also end of block
            @_p = EMPTY_P_
          else
            _seek_next_match
          end
          NIL_
        end

        def _on_static_then d, d_, & after_p

          st = _sexp_stream_for_static_run d, d_
          @_p = -> do
            x = st.gets
            if x
              x
            else
              @_p = nil
              _ = after_p[]
              _ and self._SANITY
              @_p[]
            end
          end ; nil
        end

        def _sexp_stream_for_static_run beg, end_

          o = Stream_Magnetics_::Sexp_Stream_via_String.new
          o.string = @_the_big_string
          o.pos = beg
          o.end = end_
          o.sexp_symbol_for_context_strings = :orig_str
          o.execute
        end

        def __build_match_controller_stream
          curr = @_block
          Callback_.stream do
            curr = curr.next_match_controller
            curr
          end
        end
      end
    end
  end
end
