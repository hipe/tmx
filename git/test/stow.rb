module Skylab::Git::TestSupport

  module Stow

    def self.[] tcc

      TS_::Want_Event[ tcc ]
      tcc.include Instance_Methods___
    end

    module Instance_Methods___

      define_method :git_ls_files_others_, ( -> do
        a = %w( git ls-files --others --exclude-standard )
        -> do
          a
        end
      end ).call

      define_method :stashiz_path_, ( Common_.memoize do

        ::File.join Fixture_trees_[], 'stashiz'
      end )

      def empty_dir_
        TestSupport_::Fixtures.directory :empty_esque_directory
      end

      def mock_system_conduit_where_ chdir, cmd, & three_p

        sy = Home_.lib_.system_lib::Doubles::Stubbed_System::Inline_Static_Based.new
        sy._add_entry_ chdir, cmd, & three_p
        sy
      end

      def real_system_conduit_
        Home_.lib_.open_3
      end
    end
  end
end
