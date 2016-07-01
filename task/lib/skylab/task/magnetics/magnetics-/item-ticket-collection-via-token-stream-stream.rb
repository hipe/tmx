class Skylab::Task

  module Magnetics

    class Magnetics_::ItemTicketCollection_via_TokenStreamStream < Common_::Actor::Monadic

      def initialize st_st, & oes_p
        @token_stream_stream = st_st
        @on_event_selectively = oes_p
      end

      def execute

        col = Here_::Models_::ItemTicketCollection.begin

        oes_p = method :__when_upstream_fails
        ok = true

        st = remove_instance_variable :@token_stream_stream
        begin
          ts = st.gets
          ts or break
          it = Magnetics_::ItemTicket_via_TokenStream.call ts, & oes_p
          if it
            col.accept_item_ticket it
            redo
          end
          ok = it  # or not..
          break
        end while nil

        if ok
          col.finish
        else
          ok
        end
      end

      def __when_upstream_fails * i_a, & ev_p

        if @on_event_selectively
          @oes_p.call( * i_a, & ev_p )
          UNRELIABLE_
        elsif :expression == i_a[1]
          ::Home._K
        else
          raise ev_p[].to_exception
        end
      end

      UNRELIABLE_ = :__unreliable_from_ta_magnetics__
    end
  end
end
