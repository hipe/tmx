module Skylab::DocTest

  module DocTest

    class Output_Adapters_::Quickie

      class View_Controllers_::Let_Assignment < View_Controller_

        def render line_downstream, doc_context, node

          st = line_downstream

          st.puts "let :#{ node.variable_name } do"
          st.puts "  #{ node.rhs }"
          st.puts "end"

          ACHIEVED_
        end
      end
    end
  end
end
