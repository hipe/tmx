require_relative '../../../test-support'

module Skylab::GitViz::TestSupport::Test_Lib::IA_OGDL

  ::Skylab::GitViz::TestSupport::Test_Lib[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def against s

      @st = GitViz_::Test_Lib_::Mock_Sys::Input_Adapters_::
        OGDL.tree_stream_from_lines( GitViz_.lib_.basic::String.line_stream s )

      NIL_
    end

  end

  GitViz_ = GitViz_
  NIL_ = NIL_
end
