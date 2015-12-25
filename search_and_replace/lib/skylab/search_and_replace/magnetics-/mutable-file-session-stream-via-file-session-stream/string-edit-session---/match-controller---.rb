module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Match_Controller___

        # e.g turn on or off the replacement expression for a match.
        # this is described and depicted in context in [#010]/figure-1.

        def initialize d, md, block
          @_block = block
          @_index = d
          @replacement_is_engaged = false
          @matchdata = md
          @offsets = md.offset( 0 ).freeze
        end

        # -- c15n (contextualization)

        def to_contextualized_sexp_line_streams num_lines_before, num_lines_after

          self._HMMM__how_to_etc
          o = Home_::Build_Context_Scanners___.new
          o.match_controllers = self
          o.num_lines_before = num_lines_before
          o.num_lines_after = num_lines_after
          o.execute
        end

        # -- engagement

        def engage_replacement_via_string s
          @replacement_is_engaged = true  # ok if redundant
          @_replacement = Callback_::Known_Known[ s ]
          NIL_
        end

        def replacement_value  # assume is engaged
          @_replacement.value_x
        end

        # -- navigation & intrinsics

        def next_match_controller
          @_block.next_match_controller_after__ @_index
        end

        def pos
          @offsets.fetch 0
        end

        def end
          @offsets.fetch 1
        end

        attr_reader(
          :replacement_is_engaged,
          :matchdata,
          :offsets,
        )
      end
    end
  end
end
