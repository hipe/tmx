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
        end

        # -- only for tests [#014] (see)

        def initialize_dup _otr  # assume closed
          if @_has_matches
            @_match_controllers = @_match_controllers.map do | mc |
              mc.dup_for_ self
            end
          end ; nil
        end

        def init_dup_recursive_ prev  # assume closed

          @previous_block = prev
          if @_next_block
            @_next_block.next_block
            @_next_block = @_next_block.dup.init_dup_recursive_ self
          end
          self
        end

        # --

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
          # that is on the same line or the next line (implementing
          # [#010]/figure-1)

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
          _end_at d_a.last + 1  # revisit when investigate #open [#011]
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
          _end_at end_

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

              _become_block_with_matches
              _clean
              @_next_block = nil
              _end_at d + 1
            else

              # the next found newline did *not* end the big string.
              # that means there is at least one static line after the last
              # line of this block ..

              _close_matches_that_is_followed_by_static d
            end
          else
            # there is no newline anywhere after your last match..

            _become_block_with_matches
            @_next_block = nil
            _end_at @_line_scn.string_length
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

          _scanners = @_scanners
          _become_block_with_matches
          _clean
          @_next_block = Self__.via_scanners self, _scanners
          _end_at my_final_newline_d + 1
          NIL_
        end

        def _end_at d
          @_end = d ; nil
        end

        def _become_block_with_matches

          @_has_matches = true
          @_replacement_function = @_scanners.replacement_function
          NIL_
        end

        def _clean

          remove_instance_variable :@_md_scn
          remove_instance_variable :@_scanners

          @_big_string = remove_instance_variable( :@_line_scn ).string

          NIL_
        end

        # --

        def to_output_line_stream__

          if has_matches
            __to_line_stream_when_matches
          else
            __to_line_stream_when_static
          end
        end

        def write_the_previous_N_line_sexp_arrays_in_front_of a, n

          if has_matches
            ___extend_backwards_when_has_matches a, n
          else
            __extend_backwards_when_static a, n
          end
          NIL_
        end

        def ___extend_backwards_when_has_matches a, n

          # slice on to the BEGINNING of `a` up to N of our tail-anchored
          # lines. because replacements can add or remove newlines, we can't
          # know what our trailing N lines are without starting from our
          # beginning. if we still have a deficit when we're done, try
          # recursing backwards.

          rb = Home_.lib_.basic::Rotating_Buffer[ n ]

          st = to_inner_line_sexp_array_stream
          begin
            x = st.gets
            x or break
            rb << x
            redo
          end while nil

          my_a = rb.to_a
          deficit = n - my_a.length
          a[ 0, 0 ] = my_a
          if deficit.nonzero?
            bl = @previous_block
            if bl
              self._PROBABLY_OK
              bl.write_the_previous_N_line_sexp_arrays_in_front_of a, deficit
            end
          end
          NIL_
        end

        def __extend_backwards_when_static a, n

          # OCD optimizations for static blocks. we can use the newline index.

          ___add_own_lines_to_backwards_extension_when_static a, n

          my_d = @_newlines.length
          deficit = n - my_d
          if 0 < deficit  # then we have one
            bl = @previous_block
            if bl
              bl.write_the_previous_N_line_sexp_arrays_in_front_of a, deficit
            end
          end
          NIL_
        end

        def ___add_own_lines_to_backwards_extension_when_static a, n

          # get the last N lines using your newline index

          o = _stream_magnetics::Line_Sexp_Array_Stream_via_Newlines.new
          d_a = @_newlines
          len = d_a.length
          last = len - 1
          surplus = len - n
          if 0 < surplus
            # the number of lines requested is LESS THAN the number of
            # lines in the block so we have some backwards work to do

            d = surplus - 1
            _st = Callback_.stream do
              if d != last
                d += 1
                d_a.fetch d
              end
            end

            _pos = d_a.fetch( d ) + 1  # change this at [#011]

            o.newline_stream = _st
            o.pos = _pos
          else
            # ASSUME the number of lines requested EQUALS
            # the number of lines in the block.
            o.pos = @_pos
            o.newlines = d_a
          end

          o.string = @_big_string
          _st = o.execute
          _xa_a = _st.to_a
          a[ 0, 0 ] = _xa_a
          NIL_
        end

        def write_the_next_N_line_sexp_arrays_into a, n

          st = to_inner_line_sexp_array_stream
          d = 0
          stop = if -1 < n
            -> do
              n == d
            end
          else
            self._ETC
          end

          begin
            if stop[]
              done = true
              break
            end
            x = st.gets
            x or break
            a.push x
            d += 1
            redo
          end while nil

          if done
            a
          else
            nb = @_next_block
            if nb
              _deficit = n - d
              nb.write_the_next_N_line_sexp_arrays_into a, _deficit
            end
          end
        end

        def to_inner_line_sexp_array_stream
          if has_matches
            _to_line_sexp_array_stream_when_matches
          else
            _to_line_sexp_array_stream_when_static
          end
        end

        def __to_line_stream_when_matches

          _ = _to_line_sexp_array_stream_when_matches
          _ = o::Line_stream_via_line_sexp_array_stream[ _ ]
          _
        end

        def _to_line_sexp_array_stream_when_matches

          o = _stream_magnetics
          _ = o::Sexp_stream_via_matches_block[ @_match_controllers, self, @_big_string ]
          _ = o::Line_sexp_array_stream_via_sexp_stream[ _ ]
          _
        end

        def __to_line_stream_when_static

          _ = _to_line_sexp_array_stream_when_static
          o::Line_stream_via_line_sexp_array_stream[ _ ]
        end

        def _to_line_sexp_array_stream_when_static
          o::Line_Sexp_Array_Stream_via_Newlines[ @_newlines, @_pos, @_big_string ]
        end

        def _stream_magnetics
          Here_::Stream_Magnetics_
        end

        alias_method :o, :_stream_magnetics  # eek

        def previous_match_controller_before__ d

          if d.zero?
            pb = @previous_block
            if pb
              pb.lastmost_match_controller_during_or_before
            end
          else
            @_match_controllers.fetch( d - 1 )
          end
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

        def lastmost_match_controller_during_or_before
          if has_matches
            @_match_controllers.last
          elsif @previous_block
            @previous_block.lastmost_match_controller_during_or_before
          else
            NOTHING_
          end
        end

        def next_match_controller
          if has_matches
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

        def replacement_function_  # only to be called..

          # ..by our own child match controllers so
          # assume we are closed and have matches. (MAYBE?)

          @_replacement_function
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
