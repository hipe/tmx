module Skylab::Autonomous_Component_System

  class Parameter

    class ValueSource_for_ArgumentStream

      # NOTE  - this means "argument stream" as in the API modality ..
      # notes in [#028].

      def initialize st
        @argument_stream = st
      end

      def to_controller_against__ fo_bx  # [#]:#"head parse"

        if 1 == fo_bx.length
          When_Single_Formal___.new fo_bx.at_position( 0 ), @argument_stream
        else
          When_Not_Single_Formal___.new fo_bx, @argument_stream
        end
      end

      def __is_not_known_to_be_empty
        ! is_known_to_be_empty
      end

      def is_known_to_be_empty

        # the experimental name leaves room for PVS's that
        # don't know when they're empty..

        @argument_stream.no_unparsed_exists
      end

      class Controller__

        def initialize st
          @current_argument_stream = st
        end

        attr_reader(
          :consuming_formal_parameter_stream,
          :current_argument_stream,
        )
      end

      class When_Single_Formal___ < Controller__

        # when one formal, the syntax is different: no named parameters

        def initialize fo, st

          p = -> do
            p = EMPTY_P_
            if st.no_unparsed_exists
              self._COVER_ME_probably_fine_to_just_finish_with_nothing
            else
              fo
            end
          end
          @consuming_formal_parameter_stream = Callback_.stream do
            p[]
          end
          super st
        end
      end

      class When_Not_Single_Formal___ < Controller__

        def initialize fo_bx, st
          fo_h = fo_bx.h_
          p = nil
          stop = -> do
            p = EMPTY_P_ ; NOTHING_
          end
          p = -> do
            if st.no_unparsed_exists
              stop[]
            else
              fo = fo_h[ st.current_token ]
              if fo
                st.advance_one
                fo
              else
                stop[]
              end
            end
          end
          @consuming_formal_parameter_stream = Callback_.stream do
            p[]
          end
          super st
        end
      end
    end
  end
end
