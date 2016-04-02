module Skylab::Autonomous_Component_System

  module Intent

    class Streamer

      class << self
        alias_method :via_streamer__, :new
        private :new
      end  # >>

      def initialize smr
        @node_ticket_streamer = smr
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

        st = @node_ticket_streamer.call

        p = -> do
          begin
            nt = st.gets
            nt or break
            _is_black = h.delete nt.name_symbol
            _is_black or break
            if h.length.zero?
              p = st.method :gets
              nt = p[]
              break
            end
            redo
          end while nil
          nt
        end

        Callback_.stream do
          p[]
        end
      end

      def __qualified_knownness_stream__via_include_if__

        p = @_include_if

        _st = @node_ticket_streamer.call

        _st.map_reduce_by do |no|

          _yes = p[ no ]
          if _yes
            no.to_qualified_knownness
          end
        end
      end
    end
  end
end
