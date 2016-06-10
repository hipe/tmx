module Skylab::DocTest

  module DocTest

    class Output_Adapters_::Quickie

      module View_Controllers_::Raw_Line  # for fun we don't subclass

        class << self

          def view_controller _shared_resources, & _oes_p
            self
          end

          def render line_downstream, _document_context, expression
            line_downstream.puts expression.chomped_line
            nil
          end
        end
      end
    end
  end
end
