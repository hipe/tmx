module Skylab::SubTree::TestSupport

  module Models::File_Coverage

    def self.[] tcc, * x_a

      tcc.include self

      x_a.each do | sym |
        _const = Callback_::Name.via_variegated_symbol( sym ).as_const
        Here_.const_get( _const, false )[ tcc ]
      end

      NIL_
    end

    -> do

      _FIXTURE_TREE = 'fixture-trees'

      path = -> do
        cache = {}
        -> sym do
          cache.fetch sym do

            x = ::File.join(
              TS_.dir_pathname.to_path,
              _FIXTURE_TREE,
              sym.id2name,
            ).freeze

            cache[ sym ] = x
            x
          end
        end
      end.call

      _TEST = 'test'

      define_method :fixture_tree_test_dir_for_ do | sym |
        ::File.join path[ sym ], _TEST
      end

      define_method :fixture_tree_top_dir_for_, path

    end.call

    define_method :kernel_stub_, ( -> do

      p = -> do
        x = class Kernel_Stub

          def reactive_tree_seed
            self._ONLY_for_respond_to
          end

          self
        end.new.freeze
        p = -> { x }
        x
      end
      -> do
        p[]
      end
    end ).call

    def name_conventions_
      Name_conventions__[]
    end

    def subject_
      Subject__[]
    end

    _TEST = 'test'.freeze
    define_method :_TEST do
      _TEST
    end

    # <-

  module Build_Compound_Tree

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>

    def against t_or_a, f_or_d, r_or_nr=nil, path

      o = Subject__[]

      _cx = o::Actors_::Classify_the_path::Classifications___.new(
        t_or_a, f_or_d, r_or_nr )

      @tree = o::Actors_::Build_compound_tree[
        _cx, path,
        test_dir_for_build_compound_tree,
        Name_conventions__[],
        ___real_filesystem, & handle_event_selectively ]

      NIL_
    end

    def test_dir_for_build_compound_tree
      @test_dir
    end

    def ___real_filesystem
      Home_.lib_.system.filesystem
    end
  end

  module Expect_Node_Characteristics

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>

    def expect_tests_but_no_assets_ node

      _expect_tests node
      _expect_NO_assets node
    end

    def expect_assets_but_no_tests_ node

      _expect_assets node
      _expect_NO_tests node
    end

    def expect_assets_and_tests_ node

      _expect_assets node
      _expect_tests node
    end

    def _expect_assets node

      node.node_payload.has_assets or fail _say_expected( :assets, node )
    end

    def _expect_tests node

      node.node_payload.has_tests or fail _say_expected( :tests, node )
    end

    def _expect_NO_assets node

      node.node_payload.has_assets and fail _say_expected( :no, :assets, node )
    end

    def _expect_NO_tests node

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

  Expect_Stdin_Stdout = -> tcm do

    tcm.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
    tcm.send :define_method, :expect, tcm.instance_method( :expect )  # :+#this-rspec-annoyance
  end

  Name_conventions__ = Callback_.memoize do

    Subject__[]::Models_::Name_Conventions.new %w( *_speg.rb *_spek.rb )
  end

  Subject__ = -> do
    Home_::Models_::File_Coverage
  end

  # ->

    Here_ = self
  end
end
