module Skylab::GitViz::TestSupport

  module VCS_Adapters::Git

    class << self

      def [] tcc
        tcc.include Instance_Methods__
      end

      def at_ const
        CONSTANTS__.lookup const
      end
    end  # >>

    module Instance_Methods__

      def front_
        @front ||= __build_front
      end

      def __build_front
        subject_VCS::Front.via_system_conduit(
          stubbed_system_conduit, & handle_event_selectively_ )
      end

      def subject_VCS
        Home_::VCS_Adapters_::Git
      end

      def want_result_for_failure  # #hook-out
        expect( @result ).to eql false
      end

      def at_ sym
        CONSTANTS__.lookup sym
      end
    end

    # ~ bundles

    Repository = -> tcc do

      TS_::Want_Event[ tcc ]
      TS_::Stubbed_filesystem[ tcc ]
      TS_::Stubbed_system[ tcc ]
      tcc.include Instance_Methods__

      tcc.send :define_method, :init_respository_via_path_ do | path |

        x = front_.new_repository_via(
          path,
          stubbed_system_conduit,
          stubbed_filesystem,
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

    Bundles = -> tcm do

      tcm.include Instance_Methods__  # for when nodes from outside our graph come in

      Repository[ tcm ]

      tcm.send :define_method, :bundle_against_ do | abs |

        init_respository_via_path_ abs

        repo = @repository

        if repo
          a = []
          a.push repo.relative_path_of_interest
          a.push repo
          a.push CONSTANTS__.lookup :__mock_resources
          a.push stubbed_filesystem

          _p = handle_event_selectively_

          x = subject_VCS::Models_::Bundle.build_bundle_via( * a, & _p )

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

    class CONSTANTS__ < TestSupport_::Lazy_Constants

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
        TS_::CLI_lib_[].mock_stderr_instance
      end
    end
  end
end
