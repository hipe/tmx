module Skylab::Autonomous_Component_System

  module Operation

    class Node_Parse < Parsing_Session_

      # required reading: [#015]

      class << self
        def begin_for o, & pp  # [ze]
          new.__init_non_optionals_via_parsing_session o, & pp
        end
      end  # >>

      def initialize
        @non_compound = nil
        @stop_if = nil
      end

      alias_method(
        :__init_non_optionals_via_parsing_session,
        :init_via_parsing_session_,
      )

      def init_via_parsing_session_ o

        super  # sets e.g @ACS
        ___init_optionals_with_defaults
        self
      end

      def ___init_optionals_with_defaults  # assume @ACS

        @push = -> qk do
          @stack.push qk
          NIL_
        end

        _ACS = remove_instance_variable :@ACS

        @stack = [ Callback_::Known_Known[ _ACS ] ]

        NIL_
      end

      attr_writer(
        :non_compound,
        :push,
        :stack,
        :stop_if,
      )

      # -- for long-running sessions

      attr_reader(
        :stack,
      )

      # -- for normal use

      def execute

        acs = @stack.last.value_x
        st = @argument_stream
        stop_if = @stop_if || MONADIC_EMPTINESS_
        non_compound = @non_compound || MONADIC_EMPTINESS_

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
            @push[ qk ]
            redo
          end

          non_compound[ asc ]

          break

        end while nil

        @stack
      end

      NO_SUCH_ASSOCIATION___ = nil
    end
  end
end
