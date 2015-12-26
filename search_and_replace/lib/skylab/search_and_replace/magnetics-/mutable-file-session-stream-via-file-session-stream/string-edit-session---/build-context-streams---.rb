module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Build_Context_Streams___

        # the underlying system is generally stream- and linked-list-based
        # but this operation is what we might call "output-document-
        # structure-based"; and from this stems the main challenge here,
        # given the OCD premise of our tactics..  (continued at [#013])

        attr_writer(
          :block,
          :match_controller,
          :num_lines_after,
          :num_lines_before,
        )

        def execute

          ok = ___resolve_initial_three
          ok &&= __complete_before
          ok &&= __complete_after
          ok &&= __complete_during
          ok && __final_result
        end

        def ___resolve_initial_three

          match_d = @match_controller.match_index
          beginner = -> sx do

            if :zero_width == sx.first && Is_beginning___[ sx[ 1 ] ]
              match_d == sx.last  # (hi.)
            end
          end

          ender = -> sx do
            if :zero_width == sx.first && Is_ending___[ sx[ 1 ] ]  # waste
              match_d == sx.last  # (hi.)
            end
          end

          line_x = nil

          current_line_contains_beginning_of_match = -> do
            line_x.index( & beginner )
          end

          current_line_contains_end_of_match = -> do
            line_x.index( & ender )  # technically waste
          end

          p = nil

          before_x = nil
          during_x = nil
          after_x = nil

          before = -> do
            if @num_lines_before.zero?
              before = EMPTY_P_
            else
              before_x = Home_.lib_.basic::Rotating_Buffer[ @num_lines_before ]
              before = -> do
                before_x << line_x
                NIL_
              end
              before[]
            end
            NIL_
          end

          more_during = nil ; end_of_during = nil
          during = -> do

            during_x = [ line_x ]

            if current_line_contains_end_of_match[]
              end_of_during[]
            else
              p = more_during
            end
          end

          more_during = -> do

            during_x.push line_x

            if current_line_contains_end_of_match[]
              end_of_during[]
            end
            NIL_
          end

          after = nil ; done = nil
          end_of_during = -> do
            if @num_lines_after.zero?
              done[]
            else
              p = after
            end
            NIL_
          end

          after = -> do  # assume nonzero num lines after desired
            after_x = []
            after = -> do
              after_x.push line_x
              if @num_lines_after == after_x.length
                done[]
              end
              NIL_
            end
            after[]
            NIL_
          end

          p = -> do
            if current_line_contains_beginning_of_match[]
              during[]
            else
              before[]
            end
          end

          stay = true
          done = -> do
            stay = false
          end

          st = @block.to_inner_line_sexp_array_stream
          begin
            line_x = st.gets
            line_x or break
            p[]
            if stay
              redo
            end
            break
          end while nil

          if during_x
            @_before_x = before_x
            @_during_x = during_x
            @_after_x = after_x
            ACHIEVED_
          else
            self._COVER_ME
          end
        end

        def __complete_before

          _x = remove_instance_variable :@_before_x
          ok, mixed = _same _x, @num_lines_before
          if ! ok
            ok = __seek_backwards_into mixed
            if ok
              mixed = _complete_result_from_seek mixed
            end
          end
          if ok
            @_before_result = mixed
            ACHIEVED_
          else
            ok
          end
        end

        def __complete_after

          _x = remove_instance_variable :@_after_x
          ok, mixed = _same _x, @num_lines_after
          if ! ok
            ok = __seek_forwards_into mixed
            if ok
              mixed = _complete_result_from_seek mixed
            end
          end
          if ok
            @_after_result = mixed
            ACHIEVED_
          else
            ok
          end
        end

        def _complete_result_from_seek a
          if a.length.nonzero?
            Callback_::Stream.via_nonsparse_array a
          end
        end

        def _same x, num_lines_desired

          if num_lines_desired.zero?
            ACHIEVED_
          else

            a = if x
              x.to_a
            else
              []
            end

            if num_lines_desired == a.length

              _st = Callback_::Stream.via_nonsparse_array a
              [ ACHIEVED_, _st ]

            else
              [ UNABLE_, a ]
            end
          end
        end

        # -- seek

        def __seek_backwards_into a

          bl = @block.previous_block
          if bl
            _need = @num_lines_before - a.length
            _ = bl.write_the_previous_N_line_sexp_arrays_in_front_of a, _need
            _ # a
          else
            a  # you can't go back any farther
          end
        end

        def __seek_forwards_into a

          bl = @block.next_block
          if bl
            _need = @num_lines_after - a.length
            bl.write_the_next_N_line_sexp_arrays_into a, _need
          else
            a
          end
        end

        # --

        def __complete_during

          _x = remove_instance_variable :@_during_x
          @_during_result = Callback_::Stream.via_nonsparse_array _x
          ACHIEVED_
        end

        def __final_result
          [ @_before_result, @_during_result, @_after_result ]
        end

        Is_beginning___ = {
          disengaged_match_begin: true,
          replacement_begin: true,
        }

        Is_ending___ = {
          disengaged_match_end: true,
          replacement_end: true,
        }
      end
    end
  end
end
