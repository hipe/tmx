require_relative '../../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters_

  ::Skylab::GitViz::TestSupport[ self ]

end

module Skylab::GitViz::TestSupport::VCS_Adapters_::Git

  ::Skylab::GitViz::TestSupport::VCS_Adapters_[ TS__ = self ]

  include CONSTANTS

  GitViz = GitViz ; MetaHell = MetaHell

  extend TestSupport::Quickie

  module InstanceMethods

    def front
      @front ||= build_front
    end

    def build_front
      GitViz::VCS_Adapters_::Git::Front.new TS__::Mocks, listener
    end
  end
end
