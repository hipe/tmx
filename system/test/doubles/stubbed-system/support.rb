module Skylab::System::TestSupport

  module Doubles::Stubbed_System::Support

    OGDL = -> tcm do

      tcm.send :define_method, :against_ do | s |

        @st = Home_::Doubles::Stubbed_System::Input_Adapters_::
        OGDL.tree_stream_from_lines( Home_.lib_.basic::String.line_stream s )

        NIL_
      end
    end
  end
end
