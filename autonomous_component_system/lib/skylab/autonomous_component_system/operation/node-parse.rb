module Skylab::Autonomous_Component_System

  module Operation

    class Node_Parse < Parsing_Session_

      # required reading: [#015]

      def initialize
        @stop_if = nil
      end

      attr_writer(
        :stop_if,
      )

      def execute

        stack = [ Callback_::Known_Known[ @ACS ] ]

        acs = @ACS
        st = @argument_stream
        stop_if = @stop_if || MONADIC_EMPTINESS_

        begin

          if st.no_unparsed_exists
            break
          end

          _asc_reader = Component_Association.reader_for acs

          asc = _asc_reader.call st.current_token do
            NO_SUCH_ASSOCIATION___
          end

          if ! asc
            break
          end

          _stop_now = stop_if[ asc ]
          if _stop_now
            break
          end

          if asc.model_classifications.looks_compound
            qk = Home_::For_Interface::Touch[ asc, acs ]
            acs = qk.value_x
            st.advance_one  # always in lockstep with a stack push (next line)
            stack.push qk
            redo
          end

          break

        end while nil

        stack
      end

      NO_SUCH_ASSOCIATION___ = nil
    end
  end
end
