module Skylab::SearchAndReplace

  module CLI

    class Interactive_View_Controllers_::Matches

      # (this is the frontier for [#ze-010] custom view controllers. a
      # simpler but less compelling alternative is discussed at this
      # same tag at one more location in this sidesystem.)

      def initialize st, _

        event_loop = _.event_loop
        serr = _.serr

        expag = Home_::CLI.highlighting_expression_agent_instance__

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

          event_loop.pop_me_off_of_the_stack _.operation_frame
          event_loop.loop_again

          NIL_
        end
      end

      def call
        @_p.call
      end
    end
  end
end
