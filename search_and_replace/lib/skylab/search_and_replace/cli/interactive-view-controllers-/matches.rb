module Skylab::SearchAndReplace

  module CLI

    class Interactive_View_Controllers_::Matches

      # (this is the frontier for [#ze-010] custom view controllers. an
      #  alternative is discussed near this same tag elsewhere in sidesys.)

      def initialize st, main_vc, ent_ada

        event_loop = ent_ada.event_loop
        expag = Home_::CLI.highlighting_expression_agent_instance__
        serr = main_vc.serr
        _sout = event_loop.sout

        @_p = -> do

          begin
            match = st.gets
            match or break

            st_ = match.to_line_stream_under expag
            begin
              line = st_.gets
              line or break
              serr.write "#{ match.path }:#{ match.lineno }:#{ line }"
              redo
            end while nil

            redo
          end while nil

          event_loop.pop_me_off_of_the_stack ent_ada
          event_loop.redo

          NIL_
        end
      end

      def call
        @_p.call
      end

      def end_UI_frame
        NIL_
      end
    end
  end
end