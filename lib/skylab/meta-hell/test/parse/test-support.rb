require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Parse

  ::Skylab::MetaHell::TestSupport[ TS_ = self ]

  include Constants

  MetaHell_ = MetaHell_

  extend TestSupport_::Quickie

  module InstanceMethods

    def against * s_a
      against_input_array s_a
    end

    def against_input_array s_a
      subject.output_node_via_input_stream input_stream_via_array s_a
    end

    def input_stream_via_array s_a
      Subject_[]::Input_Streams_::Array.new s_a
    end
  end

  LIB_ = ::Object.new
  class << LIB_

    def DSL_DSL
      MetaHell_::DSL_DSL
    end
  end

  Subject_ = -> do
    MetaHell_::Parse
  end

  Constants::LIB_ = LIB_

  Constants::Subject_ = Subject_

end

module Skylab::MetaHell::TestSupport::Parse::Functions

  ::Skylab::MetaHell::TestSupport::Parse[ self ]

  module Constants

    Parse_lib_ = -> do
      MetaHell_::Parse
    end
  end
end
