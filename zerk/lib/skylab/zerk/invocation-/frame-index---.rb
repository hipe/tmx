module Skylab::Zerk

  module Invocation_

    class Frame_Index___  # see [#013]

      def initialize frame, parent_index=nil, & node

        @frame_ = frame
        @_my_bx = Callback_::Box.new
        @_next = parent_index
        @_node = node

        st = frame.to_node_stream_
        begin
          no = st.gets
          no or break
          send no.category, no
          redo
        end while nil

        @_cache = {}
      end

      # --
    private

      def compound no
        # (hi.)
        _index_this_node no
      end

      def operation no
        # (hi.)
        _index_this_node no
      end

      def association no
        send no.association.model_classifications.category_symbol, no
      end

      def primitivesque no
        # (hi.)
        _index_this_node no
      end

      def _index_this_node no

        @_node[ no ]
        @_my_bx.add no.name_symbol, no
        NIL_
      end

    public

      def lookup_knownness__ par
        _sta = ___touch_state par
        _sta.knownness_
      end

      def ___touch_state par
        k = par.name_symbol
        en = @_cache[k]
        if en
          if en.in_progress
            self._NO
          end
        else
          bs = Here_::Build_state___.new @_my_bx.h_.fetch( k ), self
          @_cache[ k ] = bs
          en = bs.execute
          @_cache[ k ] = en
        end
        en
      end

      attr_reader(
        :frame_,
      )
    end
  end
end
# #history - broke out of the sibling file that builds the state structure
