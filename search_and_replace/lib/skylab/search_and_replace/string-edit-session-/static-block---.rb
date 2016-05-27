module Skylab::SearchAndReplace

  class StringEditSession_

      class Static_Block___ < Block_

        def initialize
          @_LTSs = []  # line termination sequence (i.e "newline") occurrences
        end

        def push x
          @_LTSs.push x ; nil
        end

        def last
          @_LTSs.last
        end

        def close_static_block__
          @_LTSs.freeze  # sanity
          NIL_
        end

        def lastmost_match_controller_during_or_before
          if @previous_block
            @previous_block.lastmost_match_controller_during_or_before
          else
            NOTHING_
          end
        end

        def next_match_controller
          nb = next_block
          if nb
            nb.next_match_controller
          else
            NOTHING_
          end
        end

        def COVER_write_the_previous_N_line_sexp_arrays_in_front_of a, n

          # OCD optimizations for static blocks. we can use the newline index.

          ___add_own_lines_to_backwards_extension_when_static a, n

          my_d = @_LTSs.length
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

          self._REVIEW_for_011

          # get the last N lines using your newline index

          o = _stream_magnetics::Line_Sexp_Array_Stream_via_Newlines.begin
          d_a = @_LTSs
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

            _pos = d_a.fetch( d ) + 1  # change this at ACTIVE [#011]

            o.newline_stream = _st
            o.charpos = _pos
          else
            # ASSUME the number of lines requested EQUALS
            # the number of lines in the block.
            o.charpos = @block_charpos
            o.nexx = d_a
          end

          o.string = @big_string_
          _st = o.execute
          _xa_a = _st.to_a
          a[ 0, 0 ] = _xa_a
          NIL_
        end

        def to_throughput_atom_stream_  # #testpoint
          Home_::Throughput_Magnetics_::Throughput_Atom_Stream_via_Static_Block.new(
            @block_charpos,
            @_LTSs,
            @big_string_ ).execute
        end

        def block_end_charpos  # see [#010] "deriving the end charpos of a block"
          @_LTSs.last.end_charpos
        end

        def has_matches
          false
        end
      end
  end
end
# #history: distilled as a sub-class from "block"
