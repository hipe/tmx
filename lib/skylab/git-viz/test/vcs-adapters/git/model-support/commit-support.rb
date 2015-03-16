require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git::Repo

  ::Skylab::GitViz::TestSupport::VCS_Adapters::Git[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def repo
      @repo ||= __build_repo
    end

    def _SHA s
      _VCS_const( :Repo_ )::SHA_.some_instance_from_string s
    end

    def __build_repo
      _pn = mock_repo_argument_pathname
      _VCS_const( :Repo_ ).build_repo _pn, listener_x do |repo|
        repo.system_conduit = system_conduit
      end
    end

    def mock_repo_argument_pathname  # local #hook-out
      mock_pathname '/derp/berp'
    end

    def system_conduit
      mock_system_conduit
    end

    def expect_event_sequence_and_result_for_noent_SHA_ sha_s

      expect_next_system_command_emission_

      expect_not_OK_event :unexpected_stderr do | ev |
        black_and_white( ev ).should eql(
          "fatal: bad revision '#{ sha_s }'\n" )
      end

      expect_not_OK_event :unexpected_exitstatus do | ev |
        black_and_white( ev ).should eql '128'
      end

      expect_no_more_events

      @result.should eql false
    end

    def expect_next_system_command_emission_
      expect_OK_event :next_system_command
      nil
    end
  end
end
