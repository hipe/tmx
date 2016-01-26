module Skylab::Autonomous_Component_System

  module Intent

    class Streamer

      def initialize st
        @node_stream = st
      end

      def exclude name_sym
        @_m_tail = :via_blackpool
        ( @_black_name_symbols ||= [] ).push name_sym
        name_sym
      end

      def include_if= p
        @_m_tail = :via_include_if
        @_include_if = p
        p
      end

      def to_qualified_knownness_stream

        send :"__qualified_knownness_stream__#{ @_m_tail }__"
      end

      def to_node_stream
        send :"__node_stream__#{ @_m_tail }__"
      end

      def __node_stream__via_blackpool__

        # only check against the blackpool while there is any black items left

        h = ::Hash[ @_black_name_symbols.map { |i| [ i, true ] } ]

        st = @node_stream
        p = -> do
          begin
            no = st.gets
            no or break
            _is_black = h.delete no.name_symbol
            _is_black or break
            if h.length.zero?
              p = st.method :gets
              no = p[]
              break
            end
            redo
          end while nil
          no
        end

        Callback_.stream do
          p[]
        end
      end

      def __qualified_knownness_stream__via_include_if__

        p = @_include_if

        @node_stream.map_reduce_by do |no|

          _yes = p[ no ]
          if _yes
            no.qualified_knownness
          end
        end
      end
    end
  end
end
