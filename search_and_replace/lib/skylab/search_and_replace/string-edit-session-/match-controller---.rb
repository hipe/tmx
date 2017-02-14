module Skylab::SearchAndReplace

  class StringEditSession_

      class Match_Controller___

        # e.g turn on or off the replacement expression for a match.
        # this is described and depicted in context in [#010]/figure-1.

        def initialize d, mo, block

          @block = block
          @match_charpos = mo.charpos
          @match_end_charpos = mo.end_charpos
          @match_index = d
          @_match_ocurrence = mo
          @matchdata = mo.matchdata
          @replacement_is_engaged = false
        end

        # -- [#014] only for tests

        def dup_match_controller_for__ block
          dup.___init_dup block
        end

        def ___init_dup block
          @block = block
          self
        end

        # -- parsing

        def charpos  # when parsing, this is this
          @match_charpos
        end

        def end_charpos  # ditto
          @match_end_charpos
        end

        # -- c15n (contextualization)

        def to_contexted_throughput_line_streams_ num_lines_before, num_lines_after

          o = Here_::Build_Context_Streams___.new
          o.match_controller = self
          o.num_lines_before = num_lines_before
          o.num_lines_after = num_lines_after
          o.execute
        end

        # -- engagement

        def engage_replacement & oes_p

          _proc_like = @block.replacement_function__

          presumably_string = _proc_like.call(
            @matchdata,  # (#we-might pass a custom structure instead..)
            & oes_p )

          if presumably_string

            # #we-might emit something here announcing the change

            engage_replacement_via_string presumably_string
            ACHIEVED_
          else
            # #not-covered (i.e #open [#034])
            oes_p.call :error, :expression, :invalid_replacement_value do |y|
              y << "got strange result from replace function: #{ presumably_string.inspect }"
            end
            UNABLE_
          end
        end

        def engage_replacement_via_string s
          @replacement_is_engaged = true  # ok if redundant
          @_replacement = Common_::Known_Known[ s ]
          NIL_
        end

        def disengage_replacement  # assume is engaged

          remove_instance_variable :@_replacement
          @replacement_is_engaged = false
          ACHIEVED_
        end

        def replacement_value  # assume is engaged
          @_replacement.value_x
        end

        # -- navigation & intrinsics

        def previous_match_controller
          @block.previous_match_controller_before__ @match_index
        end

        def next_match_controller
          @block.next_match_controller_after_match_index__ @match_index
        end

        def big_string__  # for one actor
          @block.big_string_
        end

        attr_reader(
          :block,
          :match_charpos,
          :match_index,
          :match_end_charpos,
          :matchdata,
          :replacement_is_engaged,
        )
      end
  end
end
