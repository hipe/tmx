module Skylab::SearchAndReplace

  class String_Edit_Session_::Build_Before_Context_Stream___

    # implement exactly [#013] 'going backwards for more lines of "before" context'

    def initialize rot_buff, mc, target_d
      @match_controller = mc
      @rotating_buffer = rot_buff
      @target_number_of_lines = target_d
    end

    def execute

      __add_lines_from_rotating_buffer

      if @_could_add_more_lines

        if _there_is_a_previous_block
          __go_backwards
        else
          _done
        end
      else
        _done
      end
    end

    def __go_backwards

      @_reverser_array = []
      _init_backwards_stream
      begin
        _there_is_a_next_line or break
        _add_line_to_cache
        @_could_add_more_lines and redo
        done_early = true
        break
      end while nil

      if ! done_early
        begin
          _there_is_a_previous_block or break
          _init_backwards_stream
          begin
            if _there_is_a_next_line
              _add_line_to_cache
              @_could_add_more_lines and redo
              done_early = true
              break
            end
            break
          end while nil
          done_early or redo
        end while nil
      end

      __add_reverser_and_done
    end

    # --

    def __add_lines_from_rotating_buffer

      @_main_array = remove_instance_variable( :@rotating_buffer ).to_a

      @_could_add_N_more_lines =
        remove_instance_variable :@target_number_of_lines

      @_could_add_N_more_lines -= @_main_array.length

      @_could_add_more_lines = @_could_add_N_more_lines.nonzero?

      mc = remove_instance_variable :@match_controller
      if @_could_add_more_lines
        @_current_block = mc.block
      end

      NIL_
    end

    def __add_reverser_and_done

      _a = remove_instance_variable( :@_reverser_array ).reverse

      _a.concat remove_instance_variable :@_main_array

      @_main_array = _a

      _done
    end

    # --

    def _there_is_a_previous_block

      prev_blk = @_current_block.previous_block
      if prev_blk
        @_current_block = prev_blk
        true
      else
        remove_instance_variable :@_current_block
        false
      end
    end

    def _init_backwards_stream

      _cb = remove_instance_variable :@_current_block
      @_stream = _cb.to_backwards_throughput_line_stream_
      NIL_
    end

    def _there_is_a_next_line
      x = @_stream.gets
      if x
        @_current_line = x
        true
      else
        self._B
      end
    end

    def _add_line_to_cache

      @_reverser_array.push remove_instance_variable :@_current_line
      @_could_add_N_more_lines -= 1
      @_could_add_more_lines = @_could_add_N_more_lines.nonzero?
    end

    def _done
      Callback_::Stream.via_nonsparse_array remove_instance_variable :@_main_array
    end
  end
end
