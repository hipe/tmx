module Skylab::GitViz::TestSupport

  module VCS_Adapters::Git::Support

    module Commit_Support

      class << self

        def [] tcc

          TS_::Expect_Event[ tcc ]
          TS_::Stubbed_filesystem[ tcc ]
          TS_::Mock_System[ tcc ]
          VCS_Adapters::Git::Support[ tcc ]

          tcc.include self
        end
      end  # >>

      def expect_event_sequence_for_noent_SHA_ sha_s

        expect_next_system_command_emission_

        expect_not_OK_event :bad_revision do | ev |

          ev.exitstatus.should eql GENERAL_ERROR___

          black_and_white( ev ).should eql(
            "unrecognized revision '#{ sha_s }'" )
        end
      end

      def expect_next_system_command_emission_
        # ..
      end

      GENERAL_ERROR___ = 128
    end
  end
end
