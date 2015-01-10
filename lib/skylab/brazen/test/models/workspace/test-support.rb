require_relative '../../test-support'

module Skylab::Brazen::TestSupport::Models

  ::Skylab::Brazen::TestSupport[ self ]

end

module Skylab::Brazen::TestSupport::Models::Workspace

  ::Skylab::Brazen::TestSupport::Models[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Brazen_ = Brazen_

  module InstanceMethods

    Constants::TestLib_::Expect_event[ self ]

    # ~ tmpdir

    def prepare_ws_tmpdir s=nil
      td = prepared_tmpdir
      if s
        td.patch s
      end
      @ws_tmpdir = td ; nil
    end

    def ws_tmpdir  # hacks only
      TS_::TestLib_::Tmpdir[]
    end

    def subject_API
      Brazen_::API
    end
  end
end
