module Skylab::Autonomous_Component_System

  class Parameter

    class ValueSource_for_ArgumentScanner

      # NOTE  - this means "argument stream" as in the API modality ..
      # notes in [#028].

      class << self

        def the_empty_value_source  # 1x, [ze]

          # (the singleton is found here (and is here for now) only because
          # of the prominence of this node. the singleton is no-modality.)

          Empty___[]
        end
      end  # >>

      def initialize scn
        @argument_scanner = scn
      end

      def to_controller_against fo_bx  # [#]:#"Head parse". [ze]

        if 1 == fo_bx.length
          When_Single_Formal___.new fo_bx.at_offset( 0 ), @argument_scanner
        else
          When_Not_Single_Formal___.new fo_bx, @argument_scanner
        end
      end

      def is_known_to_be_empty

        # the experimental name leaves room for PVS's that
        # don't know when they're empty..

        @argument_scanner.no_unparsed_exists
      end

      class Controller__

        def initialize scn
          @current_argument_scanner = scn
        end

        attr_reader(
          :consuming_formal_parameter_stream,
          :current_argument_scanner,
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
          @consuming_formal_parameter_stream = Common_.stream do
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
              fo = fo_h[ st.head_as_is ]
              if fo
                st.advance_one
                fo
              else
                stop[]
              end
            end
          end
          @consuming_formal_parameter_stream = Common_.stream do
            p[]
          end
          super st
        end
      end

      Empty___ = Lazy_.call do

        module EMPTY____ ; class << self

          def is_known_to_be_empty
            true
          end

          def to_empty
            self
          end

        end ; self end
      end
    end
  end
end
