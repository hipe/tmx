module Skylab::GitViz::TestSupport::Test_Lib

  module Mock_System::Support

    OGDL = -> tcm do

      tcm.send :define_method, :against_ do | s |

        @st = Subject_module_[]::Mock_System::Input_Adapters_::
          OGDL.tree_stream_from_lines( LIB_.basic::String.line_stream s )

        NIL_
      end
    end
  end
end
