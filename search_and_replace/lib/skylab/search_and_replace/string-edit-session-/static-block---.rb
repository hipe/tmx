module Skylab::SearchAndReplace

  class StringEditSession_

      class Static_Block___ < Block_

        def initialize( * )
          @_LTSs = []  # line termination sequence (i.e "newline") occurrences
          super
        end

        def init_duplicated_block_for_previous_block_ nxt
          super  # (hi.)
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

        def to_backwards_throughput_line_stream_
          Home_::Throughput_Magnetics_::Reverse_Throughput_Line_Stream_via_Static_Block.new(
            @block_charpos,
            @_LTSs,
            @big_string_ ).execute
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
