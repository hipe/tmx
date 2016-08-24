module Skylab::TestSupport

  module FileCoverage  # (one paragraph in [#012])

    module API

      class << self

        def call * x_a, & oes_p

          Require_zerk_[]

          Zerk_::API.call x_a, root_ACS_ do |_|
            oes_p
          end
        end

        def root_ACS_
          # for now we're daemonizing this just because we can. it makes
          # little impact either way, but it's one less object per test to
          # build. see #here for one gotcha we don't have to worry about.
          @___daemon ||= __build_root_ACS
        end

        def __build_root_ACS
          Root_Autonomous_Component_System__.by_filesystem do
            Home_.lib_.system.filesystem
          end
        end
      end  # >>
    end

    class Root_Autonomous_Component_System__

      class << self
        def by_filesystem & p
          new p
        end
        private :new
      end  # >>

      def initialize filesystem_p
        @_filesystem_p = filesystem_p
      end

      def __file_coverage__component_operation

        yield :parameter, :test_directory_filename, :optional
        yield :parameter, :test_file_suffix, :optional

        yield :via_ACS_by, -> do

          # because a new such sub-ACS is built one per request (it's an
          # operation not a component), its stored parameters won't persist
          # in any daemon from one request to the next which would otherwise
          # be an issue (near :#here).

          File_Coverage_Operation___.new @_filesystem_p
        end
      end
    end

    class File_Coverage_Operation___

      def initialize fs_p
        @test_directory_filename = nil
        @test_file_suffix = nil
        @_filesystem_p = fs_p
      end

      def __test_directory_filename__component_association

        yield :glob

        -> st do
          x = st.gets_one
          ::Array.try_convert x or Zerk_._SANTIY
          Common_::Known_Known[ x ]
        end
      end

      def __test_file_suffix__component_association

        yield :glob

        yield :description, -> y do

          _s = Test_file_suffix_array__[].map do |s|
            ick s
          end.join ', '

          y << "the test file suffixes to use (default: #{ _s })"
        end

        -> st do
          x = st.gets_one
          ::Array.try_convert x or Zerk_._SANTIY
          Common_::Known_Known[ x ]
        end
      end

      def __path__component_association

        yield :description, -> y do
          y << "the path to any file or folder in a project"
        end

        -> st, & oes_p do

          _x = st.gets_one
          qkn = Common_::Qualified_Knownness.via_value_and_symbol _x, :path

            Home_.lib_.basic::Pathname.normalization.new_with( :absolute ).
              normalize_qualified_knownness( qkn, & oes_p )
        end
      end

      def execute & oes_p
        FileCoverageExecution___.new(
          @path,
          @test_directory_filename,
          @test_file_suffix,
          @_filesystem_p,
          & oes_p ).execute
      end
    end

    class FileCoverageExecution___

      # reasons this exists as a separate object even though it's
      # structurally almost identical to its lone client:
      #
      #    - change ivars from UI- to developer-friendly names
      #      (e.g `verbose` to `be_verbose`)
      #
      #    - the selective listener is a member here, not there
      #
      #    - let [ac] avoid unnecessarily indexing all these methods

      def initialize pa, tdf_a, tfs_a, fs_p, & oes_p

        @be_verbose = false  # may be an option one day. turning this on
        # will lead to a sub-node emitting every find command, for e.g

        @max_num_dirs = -1  # may be option one day

        @path = pa
        @test_directory_filename_array = tdf_a || Test_dir_name_array__[]
        @test_file_suffix_array = tfs_a || Test_file_suffix_array__[]

        @_filesystem_p = fs_p
        @_on_event_selectively = oes_p
        NIL
      end

      def execute
        ok = __find_the_test_directory
        ok &&= __classify_the_path
        ok &&= __resolve_name_conventions
        ok &&= __via_path_classification_resolve_the_tree
        ok && @__expressive_tree
      end

      def __find_the_test_directory  # assume @max_num_dirs and @path

        _x = Home_::Magnetics::TestDirectory_via_Path.with(
          :start_path, @path,
          :filenames, @test_directory_filename_array,
          :be_verbose, @be_verbose,
          :max_num_dirs_to_look, @max_num_dirs,
          & @_on_event_selectively )

        _ _x, :@test_dir
      end

      def __classify_the_path

        _cx = Here_::Magnetics_::Classifications_via_Path.call(
          @test_dir, @path, & @_on_event_selectively )

        _ _cx, :@classifications
      end

      def __resolve_name_conventions

        _pattern_s_a = @test_file_suffix_array.map do | s |
          "*#{ s }"
        end

        @name_conventions = Here_::Models_::NameConventions.new _pattern_s_a

        ACHIEVED_
      end

      def __via_path_classification_resolve_the_tree

        _filesystem = @_filesystem_p.call

        tree = Here_::Magnetics_::CompoundTree_via_Classifications.call(
          @classifications,
          @path,
          @test_dir,
          @name_conventions,
          _filesystem,
          & @_on_event_selectively
        )

        if tree
          @__expressive_tree = Expressive_Tree___.new tree
          ACHIEVED_
        else
          tree
        end
      end

      def _ x, ivar
        if x
          instance_variable_set ivar, x ; ACHIEVED_
        else
          x
        end
      end
    end

    class Expressive_Tree___

      def initialize tree
        @tree = tree
      end

      def name
        @___name ||= Common_::Name.via_variegated_symbol :file_coverage_tree
      end

      def express_into_under y, expag
        # ..
        Here_::Modalities::CLI::Agnostic_Text_Based_Expression.
          new( y, expag, @tree ).execute
      end

      attr_reader(
        :tree,
      )
    end

    # --

    module Magnetics_
      Autoloader_[ self ]
    end

    module Models_
      Autoloader_[ self ]
    end

    # --

    Common_ = Home_::Common_
    Lazy_ = Common_::Lazy

    Test_dir_name_array__ = Lazy_.call do
      [ TEST_DIR_FILENAME_ ].freeze
    end

    Test_file_suffix_array__ = Lazy_.call do
      [ Home_.spec_rb ].freeze
    end

    # --

    Require_zerk_ = Lazy_.call do
      Zerk_ = Home_.lib_.zerk ; nil
    end

    Tree_lib_ = -> do
      Home_.lib_.basic::Tree
    end

    # --

    Here_ = self
  end
end
