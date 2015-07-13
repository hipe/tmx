module Skylab::GitViz::TestSupport::VCS_Adapters::Git

  Model_Support = ::Module.new

  module Model_Support::Commit_support

    class << self

      def [] tcm
        tcm.include self
      end
    end  # >>

    def expect_event_sequence_for_noent_SHA_ sha_s

      expect_next_system_command_emission_

      expect_not_OK_event :bad_revision do | ev |

        ev.exitstatus.should eql GENERAL_ERROR_

        black_and_white( ev ).should eql(
          "unrecognized revision '#{ sha_s }'" )
      end
    end

    def expect_next_system_command_emission_
      # ..
    end
  end
end
