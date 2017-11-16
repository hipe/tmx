module Skylab::TestSupport::TestSupport

  module File_Coverage

    def self.[] tcc
      tcc.include self
      NIL
    end

    # -

    -> do
      cache = {}
      define_method :fixture_tree_test_dir_for_ do |sym|
        cache.fetch sym do
          x = fixture_tree sym, Home_::Init.test_directory_entry_name
          cache[ sym ] = x
          x
        end
      end
    end.call

    subsystem = nil

    define_method :name_conventions_, ( Lazy_.call do
      subsystem[]::Models_::NameConventions.new %w( *_speg.kode *_spek.kode )
    end )

    def classifications_via_path_magnetic_
      subsystem_magnetics_module_::Classifications_via_Path
    end

    def subsystem_magnetics_module_
      subsystem_::Magnetics_
    end

    subsystem = -> do
      Home_::FileCoverage
    end

    define_method :subsystem_, subsystem

    # ==

  module Compound_Tree

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>

    def against t_or_a, f_or_d, r_or_nr=nil, path

      _cx = classifications_via_path_magnetic_::Classifications___[ t_or_a, f_or_d, r_or_nr ]
      _fs = __real_filesystem
      _nc = name_conventions_
      _p = event_log.handle_event_selectively

      @tree = compound_tree_via_classifications_magnetic_.call(
        _cx,
        path,
        test_dir_for_build_compound_tree,
        _nc,
        _fs,
        & _p
      )
      NIL
    end

    def test_dir_for_build_compound_tree
      @test_dir
    end

    def compound_tree_via_classifications_magnetic_
      subsystem_magnetics_module_::CompoundTree_via_Classifications
    end

    def __real_filesystem
      Home_.lib_.system.filesystem
    end
  end

  module Want_Node_Characteristics

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>

    def want_tests_but_no_assets_ node

      _want_tests node
      _want_NO_assets node
    end

    def want_assets_but_no_tests_ node

      _want_assets node
      _want_NO_tests node
    end

    def want_assets_and_tests_ node

      _want_assets node
      _want_tests node
    end

    def _want_assets node

      node.node_payload.has_assets or fail _say_expected( :assets, node )
    end

    def _want_tests node

      node.node_payload.has_tests or fail _say_expected( :tests, node )
    end

    def _want_NO_assets node

      node.node_payload.has_assets and fail _say_expected( :no, :assets, node )
    end

    def _want_NO_tests node

      node.node_payload.has_tests and fail _say_expected( :no, :tests, node )
    end

    def _say_expected no=nil, which, node

      s = node.slug.inspect

      if no
        "expected no #{ which }, had some: #{ s }"
      else
        "expected #{ which }, had none: #{ s }"
      end
    end
  end

  Want_Stdin_Stdout = -> tcm do
    tcm.include Home_::Want_Stdout_Stderr::Test_Context_Instance_Methods
  end

  # ->

    Here_ = self
  end
end
