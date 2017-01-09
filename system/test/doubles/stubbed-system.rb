module Skylab::System::TestSupport

  module Doubles::Stubbed_System

    def self.[] tcc
      tcc.include self
    end

    def conduit_for_RW_  # ..
      Subject[]::Readable_Writable_Based_
    end

    def popen3_result_for_RW_  # ..
      Subject[]::Readable_Writable_Based_::Popen3_Result
    end

    def new_string_IO_
      Home_.lib_.string_IO.new
    end

    def subject_
      Subject[]
    end

    Subject = -> do
      Home_::Doubles::Stubbed_System
    end

    _Here = self

    OGDL = -> tcm do

      tcm.send :define_method, :against_ do | s |

        @st = Home_::Doubles::Stubbed_System::Input_Adapters_::
        OGDL.tree_stream_from_lines( Home_.lib_.basic::String.line_stream s )

        NIL_
      end
    end
  end
end
