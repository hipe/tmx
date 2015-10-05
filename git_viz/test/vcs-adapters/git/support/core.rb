module Skylab::GitViz::TestSupport

  module VCS_Adapters::Git::Support

    class << self

      def [] tcc

        tcc.include Instance_Methods__
      end
    end  # >>

    module Instance_Methods__

      def front_
        @front ||= __build_front
      end

      def __build_front
        subject_VCS::Front.new_via_system_conduit(
          mock_system_conduit, & handle_event_selectively )
      end

      def subject_VCS
        Home_::VCS_Adapters_::Git
      end

      def expect_result_for_failure  # #hook-out
        @result.should eql false
      end

      def black_and_white_expression_agent_for_expect_event
        Home_.lib_.brazen::API.expression_agent_instance
      end

      def at_ sym

        CONSTANTS__.lookup sym
      end
    end

    # ~ bundles

    Repository_Support = -> tcc do

      TS_::Expect_Event[ tcc ]
      TS_::Mock_Filesystem[ tcc ]
      TS_::Mock_System[ tcc ]
      tcc.include Instance_Methods__

      tcc.send :define_method, :init_respository_via_path_ do | path |

        x = front_.new_repository_via(
          path,
          mock_system_conduit,
          mock_filesystem,
        )

        if x
          @result = nil
          @repository = x
        else
          @result = x
          @repository = x
        end
        NIL_
      end
      NIL_
    end

    Bundle_Support = -> tcm do

      tcm.include Instance_Methods__  # for when nodes from outside our graph come in

      Repository_Support[ tcm ]

      tcm.send :define_method, :bundle_against_ do | abs |

        init_respository_via_path_ abs

        repo = @repository

        if repo
          a = []
          a.push repo.relative_path_of_interest
          a.push repo
          a.push CONSTANTS__.lookup :__mock_resources
          a.push mock_filesystem

          _oes_p = handle_event_selectively

          x = subject_VCS::Models_::Bundle.build_bundle_via( * a, & _oes_p )

          if x
            @bundle = x
          else
            @result = x
          end
        else
          @result = repo
        end

        NIL_
      end

      NIL_
    end

    # ~

    class CONSTANTS__ < Lazy_Constants_

      def __mock_resources

        Mock_Resources___.new
      end

      define_method :SHORT_SHA_LENGTH_ do
        7
      end

      define_method :STORY_02_PATHS_ do

        ::File.join(
          TS_.at_( :GIT_FIXTURE_STORIES_ ),
          '02-path-of-interest/paths.list' )
      end

      define_method :STORY_02_COMMANDS_ do

        ::File.join(
          TS_.at_( :GIT_FIXTURE_STORIES_ ),
          '02-path-of-interest/commands.ogdl' )
      end

      define_method :STORY_03_PATHS_ do
        TS_.at_ :GIT_STORY_03_PATHS_
      end

      define_method :STORY_03_COMMANDS_ do
        TS_.at_ :GIT_STORY_03_COMMANDS_
      end

      define_method :STORY_04_PATHS_ do
        TS_.at_ :GIT_STORY_04_PATHS_
      end

      define_method :STORY_04_COMMANDS_ do
        TS_.at_ :GIT_STORY_04_COMMANDS_
      end
    end

    class Mock_Resources___

      def stderr
        TS_::Expect_CLI_lib_[].mock_stderr_instance
      end
    end
  end
end
