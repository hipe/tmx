module Skylab::DocTest::TestSupport

  module Fixture_Files

    def self.[] tcc
      tcc.include self
    end

    # -

      def test_document_via_line_stream_ st  # (imperfect fit here, might move)
        Home_::OutputAdapters_::Quickie::Models::TestDocument.via_line_stream st
      end

      def the_noent_directory_
        TestSupport_::Fixtures.directory :not_here
      end

      def line_stream_via_filename_ file

        ::File.open fixture_file_( file ), ::File::RDONLY
      end

      def fixture_tree_pather path

        dirname = ::File.expand_path path, _fixture_trees_directory

        -> path_ do
          ::File.expand_path path_, dirname
        end
      end

      def tree_path_via_dir_ dir
        ::File.join _fixture_trees_directory, dir
      end

      def fixture_file_ file
        ::File.join _fixture_files_directory, file
      end

      common = Lazy_.call do
        TS_.dir_path
      end

      define_method :_fixture_trees_directory, ( Lazy_.call do
        ::File.join common[], 'fixture-trees'
      end )

      define_method :_fixture_files_directory, ( Lazy_.call do
        ::File.join common[], 'fixture-files'
      end )
    # -

    Here___ = self
  end
end
# #tombstone: "path cache" that mapped short symbols to paths
