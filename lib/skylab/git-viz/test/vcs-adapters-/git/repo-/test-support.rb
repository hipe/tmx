require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters_::Git::Repo_

  Parent_TS__ = ::Skylab::GitViz::TestSupport::VCS_Adapters_::Git
  Parent_TS__[ TS__ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module InstanceMethods

    def repo
      @repo ||= build_repo
    end

    def _SHA s
      _VCS_adapter_module::Repo_::SHA_.some_instance_from_string s
    end

    def build_repo
      _pn = mock_pathname '/derp/berp'
      _VCS_adapter_module::Front.class
      _VCS_adapter_module::Repo_[ _pn, listener ] or fail
    end

    def my_fixtures_module
      Parent_TS__::Fixtures
    end
  end
end
