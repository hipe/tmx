module Skylab::SearchAndReplace

  class StringEditSession_

      class Matches_Block___ < Block_

        # implement exactly [#012]

        def initialize( * )

          @all_things = []
          @LTS_indexes = []
          @MC_indexes = []
          super
        end

        def init_duplicated_block_for_previous_block_ prev
          a = @all_things
          a_ = ::Array.new a.length
          @MC_indexes.each do |d|
            a_[ d ] = a[ d ].dup_match_controller_for__ self
          end
          @LTS_indexes.each do |d|
            a_[ d ] = a[ d ]
          end
          a.frozen? or ::Kernel._SANITY
          a_.freeze
          @all_things = a_
          super
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

        def next_match_controller_after_match_index__ d

          d_ = d + 1

          if @MC_indexes.length == d_
            nb = next_block
            if nb
              nb.next_match_controller
            else
              NOTHING_
            end
          else
            @all_things.fetch @MC_indexes.fetch d_
          end
        end

        def lastmost_match_controller_during_or_before
          self._LOOKUP_last_match_controller
        end

        def next_match_controller  # always the first match controller
          @all_things.fetch @MC_indexes.first
        end

        def to_backwards_throughput_line_stream_

          # [#013] "we reverse over matches blocks the expensive way, not the hard way"

          lt_a = to_throughput_line_stream_.to_a

          Common_::Stream.via_range( ( lt_a.length - 1 ) .. 0 ) do |d|
            lt_a.fetch d
          end
        end

        def to_throughput_atom_stream_  # #testpoint
          Home_::ThroughputMagnetics_::
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
# #history: distilled as a sub-class from "block"
