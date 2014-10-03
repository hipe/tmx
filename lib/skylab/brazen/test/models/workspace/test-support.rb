require_relative '../../test-support'

module Skylab::Brazen::TestSupport::Models

  ::Skylab::Brazen::TestSupport[ self ]

end

module Skylab::Brazen::TestSupport::Models::Workspace

  ::Skylab::Brazen::TestSupport::Models[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Brazen_ = Brazen_

  module InstanceMethods

    Brazen_::TestSupport::Expect_Event[ self ]

    def cfn
      Brazen_::Models_::Workspace::CONFIG_FILENAME__
    end

    # ~ tmpdir

    def prepare_ws_tmpdir s=nil
      td = TS_::TestLib_::Tmpdir[]
      if do_debug
        if ! td.be_verbose
          td = td.with :be_verbose, true, :debug_IO, debug_IO
        end
      elsif td.be_verbose
        self._IT_WILL_BE_EASY
      end
      td.prepare
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
