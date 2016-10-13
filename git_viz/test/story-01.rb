module Skylab::GitViz::TestSupport

  module Story_01

    class << self

      def [] tcc

        TS_::Stubbed_filesystem[ tcc ]
        TS_::Stubbed_system[ tcc ]

        tcc.include Instance_Methods___
      end
    end  # >>

    module Instance_Methods___

      define_method :manifest_path_for_stubbed_FS, ( Common_.memoize do
        Fixture_file__[ 'paths.list' ]
      end )

      define_method :manifest_path_for_stubbed_system, ( Common_.memoize do
        Fixture_file__[ 'commands.ogdl' ]
      end )
    end

    Fixture_file__ = -> do
      p = -> tail0 do
        _ = TS_.at_ :GIT_FIXTURE_STORIES_
        head = ::File.join _, '01-representative-renames'
        p = -> tail do
          ::File.join head, tail
        end
        p[ tail0 ]
      end
      -> tail do
        p[ tail ]
      end
    end.call
  end
end
