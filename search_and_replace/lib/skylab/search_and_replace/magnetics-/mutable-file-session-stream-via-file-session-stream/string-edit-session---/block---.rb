module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Block___

        # (somehow "block" ends up doing most of the work of parsing.)
        # delineation algorithm explained at [#010].

        class << self
          alias_method :via_scanners, :new
          private :new
        end  # >>

        def initialize prev=nil, scanners
          @previous_block = prev
          @_open = -> do
            __parse scanners
            NIL_
          end
          self
        end

        def _close
          p = @_open
          @_open = nil
          p[]
          NIL_
        end

        def __parse scanners

          @_scanners = scanners
          @_md_scn, @_line_scn = scanners.to_a

          @_pos = @_line_scn.pos

          if @_md_scn.has_current_matchdata

            md = @_md_scn.current_matchdata

            _beg = md.offset( 0 )[ 0 ]

            d_a = @_line_scn.advance_to_greatest_index_of_newline_less_than _beg

            if d_a
              __subdivide d_a
            else
              ___become_matches_plus
            end
          else
            __become_static
          end
          NIL_
        end

        def ___become_matches_plus

          # assume line scanner is still pointing to your beginning.

          # the current matchdata is yours. as well take each next matchdata
          # that is on the same line or the next line

          md = @_md_scn.current_matchdata

          accept = -> do
            @_md_scn.advance_one
            ___add_match_controller_for md
            NIL_
          end
          @_match_controllers = []
          accept[]

          begin

            if @_md_scn.no_remaining_matchdata
              __close_matches_when_no_more_matches
              break
            end

            _last_end = md.offset( 0 )[ 1 ]
            md = @_md_scn.current_matchdata
            _this_begin, _this_end = md.offset( 0 )

            @_line_scn.pos = _last_end

            # along the span of cels from the first cel after the last match
            # to the first cel before this match; if you find one newline,
            # that's OK - matches on adjacent lines stay in the same block.
            # BUT as soon as you find a second newline, then that delineates
            # a "static" line, which means you need to break appropriately.

            d = @_line_scn.next_newline_before _this_begin
            if d
              d_ = @_line_scn.next_newline_before _this_begin
              if d_
                # you have encountered the deadly second newline..
                __close_matches_when_followed_by_static d
                break
              else
                # there was one but not two newlines in the interceding cels
                @_line_scn.pos = _this_end  # (maybe not used)
                accept[]
                redo
              end
            else
              # there were no newlines in the zero or more interceding cels
              accept[]
              redo
            end
            break
          end while nil
          NIL_
        end

        def ___add_match_controller_for md

          @_last_matchdata = md
          d = @_match_controllers.length
          _ = Here_::Match_Controller___.new d, md, self
          @_match_controllers[ d ] = _
          NIL_
        end

        def __subdivide d_a

          # there is a current match and there are newlines before then.
          # so you become static and ..

          @_newlines = d_a
          @_line_scn.pos = d_a.last + 1

          _scanners = @_scanners
          _clean

          @_has_matches = false
          @_next_block = Self__.via_scanners self, _scanners
          NIL_
        end

        def __become_static

          @_has_matches = false
          @_next_block = nil

          end_ = @_line_scn.string_length
          @_end = end_

          d_a = @_line_scn.advance_to_greatest_index_of_newline_less_than end_
          _clean
          if d_a
            @_newlines = d_a
          end
          NIL_
        end

        def __close_matches_when_no_more_matches

          # you are a matches and you have found the last matchdata.

          md = remove_instance_variable :@_last_matchdata
          @_line_scn.pos = md.offset( 0 )[ 1 ]

          d = @_line_scn.next_newline
          if d
            if @_line_scn.eos?

              # if the next found newline after your last match terminates
              # the big string, include everything as part of your block.

              _clean
              @_has_matches = true
              @_next_block = nil
              @_end = d + 1
            else

              # the next found newline did *not* end the big string.
              # that means there is at least one static line after the last
              # line of this block ..

              _close_matches_that_is_followed_by_static d
            end
          else
            # there is no newline anywhere after your last match..
            @_has_matches = true
            @_next_block = nil
            @_end = @_line_scn.string_length
            _clean
          end
          NIL_
        end

        def __close_matches_when_followed_by_static d

          remove_instance_variable :@_last_matchdata
          @_line_scn.pos = d + 1  # you keep the newline char
          _close_matches_that_is_followed_by_static d
          NIL_
        end

        def _close_matches_that_is_followed_by_static my_final_newline_d

          scanners = @_scanners
          _clean
          @_has_matches = true
          @_next_block = Self__.via_scanners self, scanners
          @_end = my_final_newline_d + 1
          NIL_
        end

        def _clean
          remove_instance_variable :@_line_scn
          remove_instance_variable :@_md_scn
          remove_instance_variable :@_scanners
          NIL_
        end

        # --

        def to_line_stream_for_ es

          if has_matches
            ___to_line_stream_when_matches es
          else
            __to_line_stream_when_static es
          end
        end

        def ___to_line_stream_when_matches es

          o = Here_::Stream_Magnetics_
          _ = o::Sexp_stream_via_matches_block[ self, es.string ]
          _ = o::Line_sexp_array_stream_via_sexp_stream[ _ ]
          _ = o::Line_stream_via_line_sexp_array_stream[ _ ]
          _
        end

        def __to_line_stream_when_static es

          o = Here_::Stream_Magnetics_
          _ = o::Line_Sexp_Array_Stream_via_Newlines[ @_newlines, @_pos, es.string ]
          _ = o::Line_stream_via_line_sexp_array_stream[ _ ]
          _
        end

        def next_match_controller_after__ d

          d_ = d + 1
          if d_ == @_match_controllers.length
            nb = @_next_block
            if nb
              nb.next_match_controller
            else
              NOTHING_
            end
          else
            @_match_controllers.fetch d_
          end
        end

        def next_match_controller
          if @_open
            _close
          end
          if @_has_matches
            @_match_controllers.fetch 0
          elsif @_next_block
            @_next_block.next_match_controller
          else
            NOTHING_
          end
        end

        def next_block
          if @_open
            _close
          end
          @_next_block
        end

        def has_matches
          if @_open
            _close
          end
          @_has_matches
        end

        def offsets
          [ @_pos, @_end ]
        end

        def pos
          @_pos
        end

        def end
          @_end
        end

        attr_reader(
          :previous_block,
        )

        Self__ = self
      end
    end
  end
end
