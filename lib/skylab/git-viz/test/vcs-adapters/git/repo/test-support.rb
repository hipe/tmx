require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git::Repo

  Parent_TS__ = ::Skylab::GitViz::TestSupport::VCS_Adapters::Git
  Parent_TS__[ TS__ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def repo
      @repo ||= build_repo
    end

    def _SHA s
      _VCS_const( :Repo_ )::SHA_.some_instance_from_string s
    end

    def build_repo
      _pn = mock_repo_argument_pathname
      _VCS_const( :Repo_ ).build_repo _pn, listener do |repo|
        repo.system_conduit = system_conduit
      end
    end

    def mock_repo_argument_pathname
      mock_pathname '/derp/berp'
    end

    def my_fixtures_module
      Parent_TS__::Fixtures
    end

    def system_conduit
      mock_system_conduit
    end

    def expect_event_sequence_and_result_for_noent_SHA sha_s
      expect_next_system_command_emission
      expect %i( unexpected_stderr line ), "fatal: bad revision '#{ sha_s }'"
      expect %i( unexpected exitstatus ) do |em|
        em.payload_x.should eql 128
      end
      expect_no_more_emissions
      @result.should eql false
    end

    def expect_next_system_command_emission
      expect %i( next_system command )
    end
  end
end
