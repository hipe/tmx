module Skylab::GitViz::TestSupport

  module Story_01

    class << self

      def [] ctx

        GitViz_::Test_Lib_::Mock_FS[ ctx ]
        GitViz_::Test_Lib_::Mock_System[ ctx ]

        ctx.include Instance_Methods___
      end
    end  # >>

    module Instance_Methods___

      define_method :manifest_path_for_mock_FS, ( Callback_.memoize do
        ::File.join STORY__, 'paths.list'
      end )

      define_method :manifest_path_for_mock_system, ( Callback_.memoize do
        ::File.join STORY__, 'commands.ogdl'
      end )
    end

    STORY__ = ::File.join TS_.dir_pathname.to_path,
      'vcs-adapters/git/fixture-stories/01-representative-renames'
  end
end
