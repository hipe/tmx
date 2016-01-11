module Skylab::Zerk

  module View_Controllers_::Primitive_Frame

    class << self

      def default_instance
        common_instance
      end

      def common_instance
        Common_Instance___
      end
    end  # >>

    class Common_Instance___

      class << self
        alias_method :[], :new
        private :new
      end  # >>

      def initialize params

        @expression_agent = params.expression_agent
        @main_view_controller = params.main_view_controller
        @serr = params.serr
        @stack = params.stack
        freeze
      end

      def call y

        ada = @stack.last
        x = ada.button_frame
        if x
          self._K
          @main_view_controller.express_buttonesques x
        else
          ___express_longwinded_prompt y, ada
        end
        y
      end

      def ___express_longwinded_prompt y, ada

        if ada.is_listy
          ___explain_how_to_enter_lists y, ada
        end
        @serr.write "enter #{ ada.name.as_slug }: "
        NIL_
      end

      def ___explain_how_to_enter_lists y, ada

        plural = ada.name.as_human

        @expression_agent.calculate do

          y << "multiple #{ plural } can be expressed by separating them #{
            }with spaces."

          y << "certain characters will require that the #{
            }#{ singularize plural } use quotes and backslashes."
        end

        y << NEWLINE_  # the line boundarizer won't help use here b.c `write`
      end
    end
  end
end
