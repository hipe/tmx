module Skylab::System

  class Diff

    class Magnetics::Diff_via_HunkStream < Common_::Monadic
      # -
        def initialize st
          @hunk_stream = st
        end

        def execute
          @_is_empty = :__is_empty_initially
          @_to_hunk_stream = :__DO_NOT_CALL_THIS_UNLESS_YOU_CHECK_IF_IS_EMPTY_FIRST
          self  # can't freeze
        end

        def is_the_empty_diff
          send @_is_empty
        end

        def to_line_stream
          to_hunk_stream.expand_by do |hunk|
            hunk.to_line_stream
          end
        end

        def to_hunk_stream
          send @_to_hunk_stream
        end

        def __is_empty_initially
          x = @hunk_stream.gets
          if x
            @_cached_hunks = [x]
            @_to_hunk_stream = :__to_hunk_stream_midway
            @_is_empty = :__false
          else
            @_to_hunk_stream = :__NO_HUNKS_CHECK_IS_EMPTY_FIRST
            @_is_empty = :__true
            freeze
          end
          send @_is_empty
        end

        def __to_hunk_stream_midway
          # #[#co-056.2] strain: similar hand-written stream concats (presently the only one tagged)
          p = nil
          head_st = nil
          at_tail = -> do
            x = @hunk_stream.gets
            if x
              @_cached_hunks.push x
              x
            else
              remove_instance_variable :@hunk_stream
              @_cached_hunks.freeze
              @_to_hunk_stream = :__to_hunk_stream_at_end
              p = EMPTY_P_
              x
            end
          end
          at_head = -> do
            x = head_st.gets
            if x
              x
            else
              ( p = at_tail )[]
            end
          end
          p = -> do
            head_st = Stream_[ @_cached_hunks ]
            ( p = at_head )[]
          end
          Common_.stream do
            p[]
          end
        end

        def __to_hunk_stream_at_end
          Stream_[ @_cached_hunks ]
        end

        def __true
          TRUE
        end

        def __false
          FALSE
        end

        def release_resource  # THE IDEA
          remove_instance_variable( :@hunk_stream ).release_resource
        end
      # -

      # ==

      # ==
    end
  end
end
# #born
