module Skylab::Zerk

  module Invocation_

    class Frame_Index___  # see [#013]

      def initialize frame, _NOT_USED_parent_index, resource_x

        @frame_ = frame
        # @_next = parent_index
        @__once = nil
        @__resource_x = resource_x
      end

      def to_node_stream__

        remove_instance_variable :@__once

        h = {}
        st = @frame_.to_node_stream_for_invocation_

        p = -> do
          no = st.gets
          if no
            h[ no.name_symbol ] = no
            no
          else
            @_h = h
            @_cache = {}
            p = EMPTY_P_ ; no
          end
        end

        Callback_.stream do
          p[]
        end
      end

      def touch_state__ par
        k = par.name_symbol
        en = @_cache[k]
        if en
          if en.in_progress
            self._NO
          end
        else
          bs = _begin_build_state k
          @_cache[ k ] = bs
          en = bs.execute
          @_cache[ k ] = en
        end
        en
      end

      def begun_session_for__ par

        _bs = _begin_build_state par.name_symbol
        _bs.begin_session__
      end

      def _begin_build_state k
        _no = @_h.fetch k
        Here_::Build_state___.new _no, self, @__resource_x
      end

      attr_reader(
        :frame_,
      )
    end
  end
end
# #history - broke out of the sibling file that builds the state structure
# #tombstone - no more early ..
