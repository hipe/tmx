module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Matches_Block___ < Block___  # Block_

        # implement exactly [#012]

        def initialize

          @all_things = []
          @LTS_indexes = []
          @MC_indexes = []
        end

        def initialize_dup _
          self._EEK_revisit_see_notes
        end

        # -- parsing

        def add_both_goofy__ parse  # the match starts midway thru the LTS

          # (this used to be more complicated before [#012] #discussion-B)

          add_LTS__ parse
          add_match_controller__ parse
          NIL_
        end

        def push o

          o.is_line_termination_sequence_ and self._SANITY
          _add_match_controller_for o
        end

        def add_match_controller__ parse

          _add_match_controller_for parse.release_match_
        end

        def _add_match_controller_for match

          mc_d = @MC_indexes.length

          _mc = Here_::Match_Controller___.new mc_d, match, self

          d = @all_things.length

          @all_things[ d ] = _mc

          @MC_indexes[ mc_d ] = d

          NIL_
        end

        def maybe_add_LTS_ parse

          # whether or not to take this LTS depends on the endcap theorem
          # (#decision-B):

          lts = parse.LTS_

          mc = @all_things[ @MC_indexes.last ]

          if lts.end_charpos <= mc.match_end_charpos

            # always take any LTS that ends at or before the last match

            add_it = true
          else
            # this LTS ends after the last match ends (but note
            # this LTS might still overlap with the match.)

            d = @LTS_indexes.last
            if d

              # if this previous LTS is already an "endcap" of the match,
              # then don't add another, otherwise do. (yes we might be
              # calculating this redundantly.)

              _prev_LTS = @all_things[ d ]

              if _prev_LTS.charpos < mc.match_end_charpos
                # then that previous LTS was not an endcap
                add_it = true
              else
                ::Kernel._K_probably_fine
                add_it = false  # (hi.) is endcap
              end
            else

              # since you have no LTS's yet, you should take this one
              # since you must find an endcap.

              add_it = true
            end
          end

          if add_it
            add_LTS__ parse
          end
          NIL_
        end

        def add_LTS__ parse  # called here too

          lts = parse.release_LTS_

          d = @all_things.length
          @all_things[ d ] = lts
          @LTS_indexes.push d

          NIL_
        end

        def close_matches_block_
          @all_things.freeze  # sanity
          @block_is_closed = true
        end

        def block_end_charpos

          o = @all_things.last
          o.is_line_termination_sequence_ or self._SANITY
          o.end_charpos
        end

        def last

          # be careful .. we don't know

          @all_things[ @MC_indexes.last ]
        end

        # --

        def previous_match_controller_before__ d
          ::Kernel._K

          if d.zero?
            pb = @previous_block
            if pb
              pb.lastmost_match_controller_during_or_before
            end
          else
            @_MCs.fetch( d - 1 )
          end
        end

        def next_match_controller_after__ d
          ::Kernel._K

          d_ = d + 1
          if d_ == @_MCs.length
            nb = next_block
            if nb
              nb.next_match_controller
            else
              NOTHING_
            end
          else
            @_MCs.fetch d_
          end
        end

        def lastmost_match_controller_during_or_before
          self._LOOKUP_last_match_controller
        end

        def next_match_controller
          self._GET_first_match_controller
        end

        def COVER_write_the_previous_N_line_sexp_arrays_in_front_of a, n

          # slice on to the BEGINNING of `a` up to N of our tail-anchored
          # lines. because replacements can add or remove newlines, we can't
          # know what our trailing N lines are without starting from our
          # beginning. if we still have a deficit when we're done, try
          # recursing backwards.

          rb = Home_.lib_.basic::Rotating_Buffer[ n ]

          st = to_line_atom_array_stream_
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

        def ___to_throughput_atom_stream  # #testpoint
          Home_::Throughput_Magnetics_::
            Throughput_Atom_Stream_via_Matches_Block.new( self ).execute
        end

        def match_controllers_count___  # #testpoint ONLY
          @MC_indexes.length
        end

        def big_string__
          @big_string_
        end

        attr_reader(
          :all_things,
          :block_is_closed,
          :LTS_indexes,
          :MC_indexes,
        )

        def has_matches
          true
        end
      end
    end
  end
end
# #history: distilled as a sub-class from "block"
