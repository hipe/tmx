module Skylab::SearchAndReplace

  class String_Edit_Session_::Build_Context_Streams___

    # some axioms/theorems:
    #
    #   • we can only trust line coherence at the block level, so no matter
    #     what Nth match we want to express in the block, we always have to
    #     start by expressing the block's first line and searching downwards.
    #
    # continued at [#013].

    attr_writer(
      :match_controller,
      :num_lines_before,
      :num_lines_after,
    )

    def execute

      __go_forwards_until_you_find_the_line_where_the_match_starts
      __keep_going_until_you_find_the_line_where_the_match_ends
      __go_forwards_further_if_necessary
      __go_backwards_if_necessary

      [ @_before_stream, @_during_stream, @_after_stream ]
    end

    def __go_forwards_until_you_find_the_line_where_the_match_starts

      rot_buff = __build_rotating_buffer_ish

      st = @match_controller.block.to_throughput_line_stream_

      target_d = @match_controller.match_index

      begin
        line = st.gets
        line or break
        if line.has_start_of_match target_d
          break
        end
        rot_buff << line
        redo
      end while nil

      @_rotating_buffer = rot_buff
      @_line_where_the_match_starts = line
      @_line_stream = st

      NIL_

    end

    def __build_rotating_buffer_ish

      d = @num_lines_before
      if d.zero?
        ::Enumerator::Yielder.new do |_|
          NOTHING_
        end
      else
        Home_.lib_.basic::Rotating_Buffer[ d ]
      end
    end

    def __keep_going_until_you_find_the_line_where_the_match_ends

      st = @_line_stream
      line = remove_instance_variable :@_line_where_the_match_starts

      a = [ line ]

      target_d = @match_controller.match_index

      begin
        if line.has_end_of_match target_d
          break
        end
        line = st.gets
        a.push line
        redo
      end while nil

      @_during_stream = Common_::Stream.via_nonsparse_array a
      NIL_
    end

    def __go_forwards_further_if_necessary  # NOTE - not streaming but could be

      a = []

      remaining_d = @num_lines_after
      if remaining_d.nonzero?

        st = remove_instance_variable :@_line_stream
        current_block = @match_controller.block

        begin
          line = st.gets
          if line
            a.push line
            remaining_d -= 1
            remaining_d.zero? ? break : redo
          end

          current_block = current_block.next_block
          current_block or break
          st = current_block.to_throughput_line_stream_
          redo
        end while nil
      end

      @_after_stream = Common_::Stream.via_nonsparse_array a

      NIL_
    end

    def __go_backwards_if_necessary

      # see 'going backwards for more lines of "before" context'

      target_d = @num_lines_before

      if target_d.zero?
        st = Common_::Stream.the_empty_stream
      else

        st = Home_::String_Edit_Session_::Build_Before_Context_Stream___.new(
          remove_instance_variable( :@_rotating_buffer ),
          @match_controller,
          target_d,
        ).execute
      end

      @_before_stream = st ; nil
    end
  end
end
# #history - third full rewrite
