module Skylab::DocTest

  class Magnetics_::LineStream_via_NodeStream < Common_::Actor::Monadic

    # given a stream of nodes (of which each object it produces might be
    # "branchy" or "itemy", but hopefully won't matter), in effect we
    # map-expand this stream to be a single ("flattened") stream of their
    # respective lines while:
    #
    #   • putting a spacer line *between* "groups" of lines
    #     • i.e don't put a spacer before the first group and
    #     • don't put a spacer after the last group
    #
    #   • granting that some of these objects might fail to produce
    #     a stream (by resulting in false-ish instead) and
    #
    #   • some of these objects might produce a stream that produces
    #     no lines (we're not sure). with these two cases it should be
    #     as if the object doesn't exist (i.e never place two spacers
    #     adjacent to each other).
    #
    #   • we're hoping that when the object is "branchy" it will "just
    #     work" but if it does it will probably be because it is calling
    #     the subject recursively.
    #
    #   • (which LTS we use should be determined from the throughput.)
    #
    # maybe this won't be useful in synchronization but then again maybe it
    # will.

    def initialize ns
      @node_stream = ns
    end

    def execute
      @_state = :__first
      Common_.stream do
        send @_state
      end
    end

    def __first

      _find_any_next_collection_of_nonzero_lines

      if @_found_a_line

        __init_frozen_spacer_line_from_first_found_line

        @_state = :_gets_via_line_stream
        remove_instance_variable :@_line
      else
        _done
      end
    end

    def ___gets_line_then_etc
      # assume that on deck is the first line of a non-first group,
      # and the last object we produced was the spacer line
      @_state = :_gets_via_line_stream
      remove_instance_variable :@_line
    end

    def _gets_via_line_stream

      line = @_line_stream.gets
      if line
        line
      else
        _find_any_next_collection_of_nonzero_lines
        if @_found_a_line
          @_state = :___gets_line_then_etc
          @_frozen_spacer_line
        else
          _done
        end
      end
    end

    def _find_any_next_collection_of_nonzero_lines

      @_line = nil
      @_line_stream = nil

      begin
        node = @node_stream.gets
        node || break
        st = node.to_line_stream
        st || redo
        line = st.gets
        line ? break : redo
      end while nil

      if line
        @_found_a_line = true
        @_line = line
        @_line_stream = st
      else
        @_found_a_line = false
        remove_instance_variable :@_line
        remove_instance_variable :@_line_stream
      end
      NIL_
    end

    def __init_frozen_spacer_line_from_first_found_line

      # (the node that produces non-LTS-terminated lines is so misbehaved
      # that if this happens we will just break loudly rather than cover it)

      @_frozen_spacer_line = /[\r\n]+\z/.match( @_line )[ 0 ].freeze ; nil
    end

    def _done
      remove_instance_variable :@_state
      NOTHING_
    end
  end
end
