module Skylab::GitViz::TestSupport

  module VCS_Adapters::Git

    module Commits

      class << self

        def [] tcc

          TS_::Want_Event[ tcc ]
          TS_::Stubbed_filesystem[ tcc ]
          TS_::Stubbed_system[ tcc ]
          VCS_Adapters::Git[ tcc ]

          tcc.include self
        end
      end  # >>

      def want_event_sequence_for_noent_SHA_ sha_s

        want_next_system_command_emission_

        want_not_OK_event :bad_revision do | ev |

          expect( ev.exitstatus ).to eql GENERAL_ERROR___

          expect( black_and_white ev ).to eql(
            "unrecognized revision \"#{ sha_s }\"" )
        end
      end

      def want_next_system_command_emission_
        # ..
      end

      GENERAL_ERROR___ = 128
    end
  end
end
