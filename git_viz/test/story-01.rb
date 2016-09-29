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
        ::File.join STORY__, 'paths.list'
      end )

      define_method :manifest_path_for_stubbed_system, ( Common_.memoize do
        ::File.join STORY__, 'commands.ogdl'
      end )
    end

    STORY__ = ::File.join TS_.dir_path,
      'vcs-adapters/git/fixture-stories/01-representative-renames'
  end
end
