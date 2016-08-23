module Skylab::DocTest::TestSupport

  module Fixture_Files

    def self.[] tcc
      tcc.include self
    end

    # -

      fixture_file_path = nil
      fixture_tree_path = nil

      def line_stream_via_filename_ file
        _path = path_via_filename_ file
        ::File.open _path, ::File::RDONLY
      end

      define_method :path_via_filename_ do |file|

        ::File.join fixture_file_path[], file
      end

      define_method :fixture_tree_pather do |file|

        dirname = ::File.expand_path file, fixture_tree_path[]

        -> path do
          ::File.expand_path path, dirname
        end
      end

      common = Lazy_.call do
        TS_.dir_pathname.to_path
      end

      fixture_tree_path = -> do
        ::File.join common[], 'fixture-trees'
      end

      fixture_file_path = -> do
        ::File.join common[], 'fixture-files'
      end
    # -
  end
end
# #tombstone: "path cache" that mapped short symbols to paths
