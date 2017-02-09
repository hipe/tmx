module Skylab::TestSupport

  module FileCoverage  # (one paragraph in [#012]. also desc at #here-2)

    # (see #spot-fc-CLI for comments about our CLI exposure)

    module API ; class << self

      def call * x_a, & oes_p

        Zerk_lib_[]::API.call x_a, Here_.__root_ACS do |_|
          oes_p
        end
      end
    end ; end  # >>

    class << self

      def __root_ACS
        # for now we're daemonizing this just because we can. it makes
        # little impact either way, but it's one less object per test to
        # build. see #here for one gotcha we don't have to worry about.
        @___daemon ||= __build_root_ACS
      end

      def __build_root_ACS
        Root_Autonomous_Component_System.via_filesystem_by do
          Home_.lib_.system.filesystem
        end
      end
    end  # >>

    class Root_Autonomous_Component_System

      class << self
        def via_filesystem_by & p
          new p
        end
        private :new
      end  # >>

      def initialize filesystem_p
        @_filesystem_p = filesystem_p
      end

      def __file_coverage__component_operation  # #public-API

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

      def self.describe_into_under y, expag

        y << "see crude unit test coverage with a left-right-middle filetree diff"
        y << "  - test files with corresponding application files appear as green."
        y << "  - application files with no corresponding test files appear as red."

        # #todo -  ideally you would get the styling descriptions from the expag
      end

      def initialize fs_p
        @test_directory_filename = nil
        @test_file_suffixes = nil
        @_filesystem_p = fs_p
      end

      def __test_directory_filename__component_association

        yield :description, -> y do

          _ = ick Test_directory_filename__[]
          y << "the name(s) used for test directories (default: #{ _ })"
        end

        -> st do
          x = st.gets_one
          ::Array.try_convert x or Zerk_._SANTIY
          Common_::Known_Known[ x ]
        end
      end

      def __test_file_suffixes__component_association
        yield :is_plural_of, :test_file_suffix
      end

      def __test_file_suffix__component_association

        yield :is_singular_of, :test_file_suffixes

        yield :description, -> y do

          _ = render_list_commonly__ Test_file_suffix_array__[]
          y << "the test file suffixes to use (default: #{ _ })"
        end

        -> st do
          x = st.gets_one
          ::Array.try_convert( x ) && Home_._SANITY
          Common_::Known_Known[ x ]
        end
      end

      def __path__component_association

        yield :description, -> y do
          y << "the path to any file or folder in a project"
        end

        -> st, & pp do
          _x = st.gets_one
          _qkn = Common_::Qualified_Knownness.via_value_and_symbol _x, :path
          _n11n = Home_.lib_.basic::Pathname.normalization.new_with :absolute
          _n11n.normalize_qualified_knownness _qkn do |*i_a, &ev_p|
            _oes_p = pp[ :_fc_hi_ ]
            _oes_p[ * i_a, & ev_p ]
          end
        end
      end

      def execute & oes_p
        FileCoverageExecution___.new(
          @path,
          @test_directory_filename,
          @test_file_suffixes,
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

      def initialize pa, tdfn, tfs_a, fs_p, & oes_p

        @be_verbose = false  # may be an option one day. turning this on
        # will lead to a sub-node emitting every find command, for e.g

        @max_num_dirs = -1  # may be option one day

        @path = pa
        @test_directory_filename = tdfn || Test_directory_filename__[]
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
          :filenames, [ @test_directory_filename ],
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

        _pattern_s_a = @test_file_suffix_array.map do |s|
          if ASTERISK_BYTE__ == s.getbyte(0)
            s
          else
            "#{ ASTERISK_ }#{ s }"
          end
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
        Here_::CLI::Agnostic_Text_Based_Expression.
          new( y, expag, @tree ).execute
      end

      attr_reader(
        :tree,
      )
    end

    # --

    module Magnetics_

      module TwoTrees_via_BigTreePattern
        Autoloader_[ self ]
      end
      Autoloader_[ self ]
    end

    module Models_

      Trees = ::Struct.new :asset, :test

      Autoloader_[ self ]
    end

    # --

    Common_ = Home_::Common_
    Lazy_ = Common_::Lazy

    Test_directory_filename__ = -> do
      Home_::Init.test_directory_entry_name
    end

    Test_file_suffix_array__ = Lazy_.call do
      [ Home_.spec_rb ].freeze
    end

    # --

    Tree_lib_ = -> do
      Home_.lib_.basic::Tree
    end

    # --

    ASTERISK_ = '*'
    ASTERISK_BYTE__ = ASTERISK_.getbyte 0
    LIB_ENTRY_ = 'lib'
    Here_ = self
  end
end
